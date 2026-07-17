//! Session/plan-mode concern for `SessionActor` (`handle_session_mode`,
//! plan-mode reminders and persistence, active-template detection).
use super::*;
pub(super) fn prompt_mode_from_session_mode_id(session_mode_id: &acp::SessionModeId) -> PromptMode {
    use xai_grok_tools::types::SessionMode;
    match SessionMode::from_id(session_mode_id.0.as_ref()) {
        SessionMode::Plan => PromptMode::Plan,
        SessionMode::Ask => PromptMode::Ask,
        SessionMode::Default => PromptMode::Agent,
    }
}
/// Pass-through twin: no toolset in this build carries a plan-gated tool.
pub(super) fn filter_cursor_tools_by_plan_mode(
    defs: Vec<ToolDefinition>,
    _plan_active: bool,
) -> Vec<ToolDefinition> {
    defs
}
impl SessionActor {
    pub(super) fn apply_prompt_modes_to_snapshot(&self, snapshot: &mut TurnDeltaSnapshot) {
        snapshot.start_prompt_mode = Some(self.turn_start_prompt_mode.lock().to_string());
        snapshot.end_prompt_mode = Some(self.turn_prompt_mode.lock().to_string());
    }
    /// `false` twin: this template integration is not compiled into this
    /// build, so no session runs it. Keeps ungated call sites compiling in
    /// both configurations.
    pub(super) fn is_cursor_harness(&self) -> bool {
        false
    }
    pub(super) async fn handle_session_mode(&self, session_mode_id: acp::SessionModeId) {
        use xai_grok_tools::types::SessionMode;
        let prompt_mode = prompt_mode_from_session_mode_id(&session_mode_id);
        *self.current_prompt_mode.lock() = prompt_mode;
        let mode = SessionMode::from_id(session_mode_id.0.as_ref());
        if mode.is_plan() {
            let entered = self.plan_mode.lock().enter_pending();
            if entered {
                self.persist_plan_mode_state();
                self.enqueue_current_mode_update(acp::SessionModeId::new(
                    SessionMode::Plan.as_id(),
                ));
            }
            tracing::info!(
                session_id = % self.session_info.id.0, entered,
                "Plan mode toggled ON (Pending)"
            );
            let turn_in_flight = self.state.lock().await.running_task.is_some();
            if entered && turn_in_flight {
                self.activate_plan_mode_mid_turn().await;
            }
            xai_grok_telemetry::session_ctx::log_event(
                xai_grok_telemetry::events::PlanModeToggled {
                    enabled: true,
                    trigger: xai_grok_telemetry::events::PlanModeTrigger::User,
                    turn_in_flight,
                    was_previously_active: !entered,
                },
            );
            if entered {
                tracing::info_span!(
                    "session.permission_mode_changed",
                    from_mode =
                        super::telemetry::permission_mode_label(self.permissions.is_yolo_mode()),
                    to_mode = "plan",
                    trigger = "user",
                    enabled = true,
                )
                .in_scope(|| {});
            }
            return;
        }
        let was_plan = {
            let tracker = self.plan_mode.lock();
            tracker.state() != crate::session::plan_mode::PlanModeState::Inactive
        };
        if was_plan {
            let turn_in_flight = self.state.lock().await.running_task.is_some();
            self.plan_mode.lock().user_exit(turn_in_flight);
            self.persist_plan_mode_state();
            self.enqueue_current_mode_update(session_mode_id.clone());
            tracing::info!(
                session_id = % self.session_info.id.0, new_mode = % session_mode_id.0,
                turn_in_flight, "Plan mode toggled OFF"
            );
            xai_grok_telemetry::session_ctx::log_event(
                xai_grok_telemetry::events::PlanModeToggled {
                    enabled: false,
                    trigger: xai_grok_telemetry::events::PlanModeTrigger::User,
                    turn_in_flight,
                    was_previously_active: true,
                },
            );
            tracing::info_span!(
                "session.permission_mode_changed", from_mode = "plan", to_mode = %
                session_mode_id.0, trigger = "user", enabled = false,
            )
            .in_scope(|| {});
        }
        let mode_id = session_mode_id.0.as_ref();
        // Product L1 freeze (VAL-M1-LOCK-001): after first user message /
        // conversation content, refuse product-role hops so the system/role
        // prompt stack stays frozen. Plan/default/ask and non-product modes
        // remain switchable.
        if crate::session::role_switch::is_product_role_mode_id(mode_id) {
            let turn_count = self
                .signals_handle()
                .snapshot()
                .await
                .map(|s| s.turn_count)
                .unwrap_or(0);
            // turn_count is the session signal for completed user turns; zero
            // means pre-message (or restored empty). Content scan is not
            // available here — shell gate uses turn_count; pager also gates
            // on scrollback user prompts.
            if !crate::session::role_switch::role_switch_allowed(turn_count, false) {
                tracing::info!(
                    session_id = % self.session_info.id.0,
                    requested_role = % mode_id,
                    turn_count,
                    "role_switch_allowed=false: ignoring product role mode (L1 freeze)"
                );
                return;
            }
        }
        let mut agent_def = match mode_id {
            "browser_use" => Some(AgentDefinition::browser_use()),
            name => {
                let cwd = self.tool_context.cwd.as_path();
                crate::session::product_role::resolve_product_role_in_cwd(name, cwd)
                    .or_else(|| xai_grok_agent::discovery::by_name_in_cwd(name, cwd))
            }
        };
        if let Some(ref mut def) = agent_def {
            // Product L1: inject Identity so model knows active role after Tab.
            crate::session::role_switch::ensure_product_role_identity(def);
            tracing::info!(
                session_id = % self.session_info.id.0, agent_name = % def.name,
                agent_scope = % def.scope, prompt_mode = ? def.prompt_mode,
                has_completion_req = def.completion_requirement.is_some(), tool_configs =
                def.tool_config.tools.len(), "Resolved AgentDefinition for session mode"
            );
            self.agent
                .borrow()
                .update_policies_from_definition(def)
                .await;
            *self.active_agent_type.lock() = Some(def.name.clone());
        }
        if let Some(ref def) = agent_def {
            // L1 prompt stack: rewrite system head only when switch was allowed
            // (product roles already gated above; other modes still rebuild).
            let new_prompt = self.agent.borrow().render_prompt_for_definition(def).await;
            let mut conversation = self.chat_state_handle.get_conversation().await;
            for item in conversation.iter_mut() {
                if let ConversationItem::System(sys) = item {
                    sys.content = std::sync::Arc::<str>::from(new_prompt);
                    break;
                }
            }
            self.chat_state_handle.replace_conversation(conversation);
        }
        // F-M1-MODEL-RESOLVE: re-pin model from role assignment (agent
        // frontmatter `model:` written by apply-models from YAML) only while
        // role_switch_allowed. Post-lock keeps the active model stack.
        // Subagent spawn overrides are independent (spawn > role > persona >
        // parent) and never go through this path.
        if let Some(ref def) = agent_def {
            let assignment_model_id = match &def.model {
                xai_grok_agent::config::ModelOverride::Override(id) => Some(id.as_str()),
                xai_grok_agent::config::ModelOverride::Inherit => None,
            };
            let turn_count = self
                .signals_handle()
                .snapshot()
                .await
                .map(|s| s.turn_count)
                .unwrap_or(0);
            match crate::session::role_switch::gate_role_model_repin(
                turn_count,
                false,
                assignment_model_id,
            ) {
                crate::session::role_switch::RoleModelRepin::Keep => {
                    tracing::debug!(
                        session_id = % self.session_info.id.0,
                        agent = % def.name,
                        turn_count,
                        "role model re-pin kept (locked or inherit)"
                    );
                }
                crate::session::role_switch::RoleModelRepin::Apply => {
                    if let Some(model_id) = assignment_model_id {
                        self.repin_model_from_role_assignment(model_id, def.effort.as_ref())
                            .await;
                    }
                }
            }
        }
    }

    /// Apply agent frontmatter model pin to the primary session (YAML
    /// assignment via apply-models). Only called when
    /// `gate_role_model_repin` returns Apply (pre-message unlock).
    pub(super) async fn repin_model_from_role_assignment(
        &self,
        model_id: &str,
        effort: Option<&xai_grok_agent::config::Effort>,
    ) {
        use crate::agent::config::{
            find_model_by_id, resolve_credentials, sampling_config_for_model,
        };

        let models = self.models_manager.models();
        let Some(entry) = find_model_by_id(&models, model_id) else {
            tracing::warn!(
                session_id = % self.session_info.id.0,
                model_id,
                "role model re-pin: assignment model not in catalog — keeping stack"
            );
            return;
        };
        let session_key = self
            .auth_manager
            .as_ref()
            .and_then(|am| am.current_or_expired().map(|a| a.key));
        let credentials = resolve_credentials(entry, session_key.as_deref());
        // SamplerConfig is built without full MvpAgent preferred-method
        // gymnastics; session credentials + catalog entry match set_session_model
        // for custom [model.*] pins from assignment YAML.
        let mut sampling = sampling_config_for_model(entry, credentials, None, None, None, None);
        if let Some(eff) = effort {
            let token = match eff {
                xai_grok_agent::config::Effort::Low => "low",
                xai_grok_agent::config::Effort::Medium => "medium",
                xai_grok_agent::config::Effort::High => "high",
                xai_grok_agent::config::Effort::XHigh => "xhigh",
                xai_grok_agent::config::Effort::Max => "max",
            };
            if let Ok(re) = token.parse::<xai_grok_sampling_types::ReasoningEffort>() {
                if entry.info().supports_reasoning_effort {
                    sampling.reasoning_effort = Some(re);
                }
            }
        }
        let use_concise = entry.info().use_concise;
        let auto_compact = {
            // Prefer a conservative default when util resolve is unavailable
            // without agent Config; handle_set_session_model updates threshold.
            self.compaction.threshold_percent.get()
        };
        match self
            .handle_set_session_model(sampling, use_concise, true, false, auto_compact)
            .await
        {
            Ok(applied) => {
                tracing::info!(
                    session_id = % self.session_info.id.0,
                    model_id = % applied.0,
                    "role model re-pin applied from assignment (pre-message)"
                );
            }
            Err(e) => {
                tracing::warn!(
                    session_id = % self.session_info.id.0,
                    model_id,
                    error = ? e,
                    "role model re-pin failed — keeping prior model stack"
                );
            }
        }
    }
    /// Bring the plan-mode tracker into agreement with the prompt's mode.
    ///
    /// Mirrors `handle_session_mode` but driven from `_meta.mode` on the
    /// prompt — the only signal the client sends. Both transitions are
    /// idempotent, so `set_mode`-driven flows are unaffected.
    pub(super) fn reconcile_plan_mode_with_prompt(&self, prompt_mode: PromptMode) {
        use crate::session::plan_mode::PlanModeState;
        *self.current_prompt_mode.lock() = prompt_mode;
        match prompt_mode {
            PromptMode::Plan => {
                let entered = self.plan_mode.lock().enter_pending();
                if entered {
                    self.persist_plan_mode_state();
                }
            }
            PromptMode::Agent | PromptMode::Ask => {
                let was_plan = {
                    let tracker = self.plan_mode.lock();
                    tracker.state() != PlanModeState::Inactive
                };
                if was_plan {
                    self.plan_mode.lock().user_exit(false);
                    self.persist_plan_mode_state();
                }
            }
        }
    }
    /// Inject plan mode system-reminders into the conversation.
    ///
    /// Called once per turn from `handle_prompt()`, before the user's actual
    /// message is pushed. Handles three mutually-ordered cases:
    ///
    /// 1. **Pending → Active**: First prompt after user toggled plan mode on.
    ///    Injects the full (or reentry) reminder and transitions to Active.
    /// 2. **Already Active**: Subsequent prompts while plan mode is on.
    ///    Injects an alternating full/sparse per-turn reminder.
    /// 3. **Exit reminder**: One-shot reminder after plan mode was exited.
    ///    Injected once, then the flag is cleared.
    ///
    /// All reminders are pushed as `<system-reminder>`-wrapped user messages
    /// so the model sees them in the same turn as the user's prompt.
    /// Tool names are resolved at render time via `TemplateRenderer`.
    pub(super) async fn inject_plan_mode_reminders(&self) {
        use crate::session::plan_mode::{
            PlanModeState, plan_mode_exit_reminder_template, plan_mode_reminder_full_template,
            plan_mode_reminder_sparse_template,
        };
        let use_cursor_reminders = self.is_cursor_harness();
        let push_reminder = |this: &Self, content: &str| {
            this.push_system_reminder_with_tag(content, this.reminder_wrapper_tag());
        };
        let mut injected_this_turn = false;
        let activation = {
            let tracker = self.plan_mode.lock();
            (tracker.state() == PlanModeState::Pending)
                .then(|| (tracker.is_reentry(), tracker.plan_file_path().to_path_buf()))
        };
        if let Some((is_reentry, plan_path)) = activation {
            self.plan_mode.lock().activate();
            self.persist_plan_mode_state();
            let plan_has_content =
                crate::session::plan_mode::plan_file_has_content(&plan_path).await;
            let template = self.plan_activation_template(is_reentry);
            if let Some(rendered) = self
                .render_plan_template(template, &plan_path, plan_has_content)
                .await
            {
                push_reminder(self, &rendered);
                injected_this_turn = true;
                self.plan_mode.lock().record_reminder_injected();
                self.persist_plan_mode_state();
                tracing::info!(
                    session_id = % self.session_info.id.0, is_reentry,
                    uses_template_reminders = use_cursor_reminders,
                    "Plan mode activated: injected system-reminder"
                );
            }
        }
        if !injected_this_turn {
            let per_turn = {
                let tracker = self.plan_mode.lock();
                tracker.is_active().then(|| {
                    (
                        tracker.should_use_full_reminder(),
                        tracker.plan_file_path().to_path_buf(),
                    )
                })
            };
            if let Some((use_full, plan_path)) = per_turn {
                let plan_has_content =
                    crate::session::plan_mode::plan_file_has_content(&plan_path).await;
                let template = if use_full {
                    plan_mode_reminder_full_template()
                } else {
                    plan_mode_reminder_sparse_template()
                };
                if let Some(rendered) = self
                    .render_plan_template(template, &plan_path, plan_has_content)
                    .await
                {
                    push_reminder(self, &rendered);
                    self.plan_mode.lock().record_reminder_injected();
                    self.persist_plan_mode_state();
                }
            }
        }
        if self.plan_mode.lock().has_pending_exit_reminder() {
            let plan_path = self.plan_mode.lock().plan_file_path().to_path_buf();
            let template = plan_mode_exit_reminder_template();
            if let Some(rendered) = self.render_plan_template(template, &plan_path, false).await {
                push_reminder(self, &rendered);
            }
            self.plan_mode.lock().clear_pending_exit_reminder();
            self.persist_plan_mode_state();
        }
    }
    /// Activate plan mode for a turn that is already running.
    ///
    /// Mid-turn counterpart of `inject_plan_mode_reminders` case 1: the user
    /// toggled plan mode ON (Shift+Tab) while the model was thinking, so the
    /// tracker sits in `Pending` and the running turn would otherwise proceed
    /// without any plan-mode instruction. Activate immediately (so
    /// `is_active()` tool gating applies to subsequent calls) and buffer the
    /// activation reminder on the tracker; `flush_pending_skill_reminders`
    /// delivers it at the running turn's next safe point (loop top / after
    /// each tool batch) — or, if the turn ends first, the cancel/idle flush
    /// lands it for the next turn. Buffering (vs a direct conversation push)
    /// keeps the in-flight batch's tool_result blocks adjacent, and lets a
    /// toggle-off withdraw an undelivered reminder (`user_exit`).
    ///
    /// No-op unless the tracker is `Pending`: `enter_pending`'s
    /// `ExitPending → Active` re-entry needs no reminder (the model already
    /// has plan-mode context and no exit reminder was injected yet).
    ///
    /// A failed template render still activates (without a buffer), keeping
    /// gating in lockstep with the turn-start path.
    pub(super) async fn activate_plan_mode_mid_turn(&self) {
        use crate::session::plan_mode::PlanModeState;
        let activation = {
            let tracker = self.plan_mode.lock();
            (tracker.state() == PlanModeState::Pending)
                .then(|| (tracker.is_reentry(), tracker.plan_file_path().to_path_buf()))
        };
        let Some((is_reentry, plan_path)) = activation else {
            return;
        };
        let plan_has_content = crate::session::plan_mode::plan_file_has_content(&plan_path).await;
        let template = self.plan_activation_template(is_reentry);
        let rendered = self
            .render_plan_template(template, &plan_path, plan_has_content)
            .await;
        let tag = self.reminder_wrapper_tag();
        let buffered = rendered.is_some();
        let activated = match rendered {
            Some(rendered) => self
                .plan_mode
                .lock()
                .activate_mid_turn(format!("<{tag}>\n{rendered}\n</{tag}>")),
            None => {
                tracing::warn!(
                    session_id = % self.session_info.id.0,
                    "Mid-turn plan activation: reminder render failed; \
                     activating without a buffered reminder"
                );
                self.plan_mode.lock().activate()
            }
        };
        if !activated {
            return;
        }
        self.persist_plan_mode_state();
        tracing::info!(
            session_id = % self.session_info.id.0, is_reentry, buffered,
            "Plan mode activated mid-turn"
        );
    }
    /// The activation reminder template for the active template (no
    /// first-entry/reentry distinction), or grok's reentry/full variant.
    /// Shared by turn-start injection (`inject_plan_mode_reminders` case 1)
    /// and the mid-turn toggle (`activate_plan_mode_mid_turn`).
    fn plan_activation_template(&self, is_reentry: bool) -> &'static str {
        use crate::session::plan_mode::{
            plan_mode_reentry_reminder_template, plan_mode_reminder_full_template,
        };
        if is_reentry {
            plan_mode_reentry_reminder_template()
        } else {
            plan_mode_reminder_full_template()
        }
    }
    /// Render a plan mode template via the tool bridge's `TemplateRenderer`.
    ///
    /// Passes `plan_path` and `plan_has_content` as extra context alongside the
    /// registry's `tools.by_kind.*` mappings.
    pub(super) async fn render_plan_template(
        &self,
        template: &str,
        plan_path: &std::path::Path,
        plan_has_content: bool,
    ) -> Option<String> {
        let extra = serde_json::json!(
            { "plan_path" : plan_path.display().to_string(), "plan_has_content" :
            plan_has_content, }
        );
        self.agent
            .borrow()
            .tool_bridge()
            .render_prompt(template, &extra)
            .await
    }
    /// Persist the current plan mode state to disk.
    ///
    /// Called after every state transition so plan mode survives
    /// session reload/resume/reconnect.
    pub(super) fn persist_plan_mode_state(&self) {
        let snapshot = self.plan_mode.lock().snapshot();
        let _ = self
            .notifications
            .persistence_tx
            .send(PersistenceMsg::PlanModeState(snapshot));
    }
}
