//! Primary-session agent switch lock (do product L1 / VAL-M1-LOCK-001).
//!
//! Binding rule: Tab / Shift+Tab product-agent cycle is allowed only while the
//! session has no user messages / no conversation content. After the first
//! user message, `role_switch_allowed` is false — L1 agent layer and model
//! re-pin from agent stay frozen for the remainder of the session.
//!
//! Pure policy (no I/O) so unit tests and both shell + pager call sites share
//! one definition of the flag and product roster.
//!
//! Naming: short aliases (chrome / legacy) map to stock-native canonical ids
//! (`grok-build-*`, `explore`). See `docs/agents-and-prompts.md`.

/// Default product roster order for primary-session cycle (aliases).
///
/// Prefer dynamic `[agents].order` from config at call sites that have
/// config. This constant is the compile-time fallback only.
///
/// Cycle wraps at ends. Canonical resolve: [`canonical_agent_name`].
pub const PRODUCT_ROSTER: &[&str] = &[
    "intake",
    "orchestrator",
    "explore",
    "worker",
    "oracle",
];

/// Alias → canonical agent id (stock-native).
///
/// Accepts already-canonical names and legacy stems (`explorer` → `explore`).
pub fn canonical_agent_name(name: &str) -> &str {
    match name {
        "intake" | "grok-build-ask-user" => "grok-build-ask-user",
        "orchestrator" | "grok-build-orchestrator" => "grok-build-orchestrator",
        "explorer" | "explore" => "explore",
        "worker" | "grok-build-worker" => "grok-build-worker",
        "oracle" | "grok-build-oracle" => "grok-build-oracle",
        "plan" => "plan",
        "general-purpose" => "general-purpose",
        "grok-build" => "grok-build",
        other => other,
    }
}

/// Canonical → preferred short alias for chrome / body file stem.
pub fn agent_alias(canonical: &str) -> &str {
    match canonical_agent_name(canonical) {
        "grok-build-ask-user" => "intake",
        "grok-build-orchestrator" => "orchestrator",
        "explore" => "explore",
        "grok-build-worker" => "worker",
        "grok-build-oracle" => "oracle",
        other => other,
    }
}

/// Body file stem under `prompts/agents/<stem>.md` for a name or alias.
pub fn agent_body_stem(name: &str) -> &str {
    agent_alias(canonical_agent_name(name))
}

/// Whether `name` is a known product agent (alias or canonical).
#[inline]
pub fn is_product_agent(name: &str) -> bool {
    matches!(
        canonical_agent_name(name),
        "grok-build-ask-user"
            | "grok-build-orchestrator"
            | "explore"
            | "grok-build-worker"
            | "grok-build-oracle"
    ) || PRODUCT_ROSTER.iter().any(|r| *r == name)
        || name == "explorer"
}

/// Legacy name for [`is_product_agent`].
#[inline]
pub fn is_product_role(name: &str) -> bool {
    is_product_agent(name)
}

/// Session flag: whether primary-session product agent switching is allowed.
///
/// Equivalent to product name `role_switch_allowed`.
///
/// `true` only when both:
/// - no completed user turns yet (`turn_count == 0`)
/// - no user conversation content present (`has_user_message_content == false`)
///
/// Either signal alone is enough to lock (defense in depth during replay /
/// mid-batch load where counters may lag content).
#[inline]
pub fn role_switch_allowed(turn_count: u32, has_user_message_content: bool) -> bool {
    turn_count == 0 && !has_user_message_content
}

/// Whether `session_mode_id` names a product agent (not plan/default/ask/etc.).
///
/// Stock ACP `session/set_mode` reuses mode ids for agent profiles when the
/// client selects a discovered agent. Product agents must freeze after lock;
/// plan/permission modes remain switchable.
#[inline]
pub fn is_product_role_mode_id(session_mode_id: &str) -> bool {
    is_product_agent(session_mode_id)
}

/// Next / previous product agent in roster order (alias form).
///
/// If `current` is not on the roster, starts from the first (forward) or last
/// (backward) entry so a fresh session can enter the cycle.
pub fn cycle_product_role(current: Option<&str>, forward: bool) -> &'static str {
    cycle_product_role_in(current, forward, PRODUCT_ROSTER)
}

/// Cycle within an explicit roster (aliases or canonical; returns same form as roster entries).
pub fn cycle_product_role_in<'a>(
    current: Option<&str>,
    forward: bool,
    roster: &[&'a str],
) -> &'a str {
    if roster.is_empty() {
        return "intake";
    }
    let idx = current.and_then(|c| {
        let can = canonical_agent_name(c);
        roster.iter().position(|r| {
            *r == c || canonical_agent_name(r) == can || agent_alias(r) == agent_alias(c)
        })
    });
    match (idx, forward) {
        (Some(i), true) => roster[(i + 1) % roster.len()],
        (Some(i), false) => {
            let n = roster.len();
            roster[(i + n - 1) % n]
        }
        (None, true) => roster[0],
        (None, false) => roster[roster.len() - 1],
    }
}

/// Toast when Tab product-agent cycle is denied after lock (F-M1-UX / M1-U01).
///
/// Points the user at a **new session** — mid-session hop is forbidden.
pub const ROLE_SWITCH_LOCKED_HINT: &str =
    "Agent locked after first message — start a new session to switch agents";

/// Toast once when the first user message freezes the product agent (F-M1-UX).
pub const ROLE_SWITCH_LOCKED_ON_FIRST_MESSAGE: &str =
    "Agent locked for this session — start a new session to change agent";

/// User-visible copy for a locked agent-cycle attempt (optional label).
pub fn role_switch_locked_toast(current_role: Option<&str>) -> String {
    match current_role {
        Some(role) if is_product_agent(role) => {
            format!(
                "Agent locked ({}) — start a new session to switch agents",
                agent_alias(role)
            )
        }
        _ => ROLE_SWITCH_LOCKED_HINT.to_string(),
    }
}

/// Outcome of a role-cycle keybind attempt.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum RoleCycleGate {
    /// Apply the cycle: switch to `next_role` (L1 rebuild allowed).
    Apply { next_role: &'static str },
    /// Flag is false — no-op (do not change active role or prompt stack).
    Locked,
}

/// Gate a Tab / Shift+Tab product-agent cycle.
///
/// `forward`: Tab (true) or Shift+Tab (false) when used as agent cycle.
pub fn gate_role_cycle(
    turn_count: u32,
    has_user_message_content: bool,
    current_role: Option<&str>,
    forward: bool,
) -> RoleCycleGate {
    if !role_switch_allowed(turn_count, has_user_message_content) {
        return RoleCycleGate::Locked;
    }
    RoleCycleGate::Apply {
        next_role: cycle_product_role(current_role, forward),
    }
}

/// Whether primary-session agent switch should re-pin the model from the new
/// agent's assignment (agent frontmatter `model:` / YAML `assignment.<role>`).
///
/// Binding product rule (L13 + L1 / F-M1-MODEL-RESOLVE):
/// - **true** only while `role_switch_allowed` — pre-message cycle re-pins
/// - **false** after lock — keep active model stack; do not re-pin mid-session
///
/// Subagent spawn resolution (spawn > role > persona > parent) is independent
/// and must not consult this flag.
#[inline]
pub fn should_repin_model_from_role(turn_count: u32, has_user_message_content: bool) -> bool {
    role_switch_allowed(turn_count, has_user_message_content)
}

/// Outcome of role→model re-resolve for a primary-session agent hop.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum RoleModelRepin {
    /// Apply the agent assignment pin (`AgentDefinition.model` Override).
    Apply,
    /// Keep the active model stack (post-lock, or Inherit pin).
    Keep,
}

/// Gate agent→model re-pin for a primary-session product agent switch.
///
/// `assignment_model_id`: registry/catalog model id from agent frontmatter
/// when the agent pins a model; `None` means Inherit / no pin.
pub fn gate_role_model_repin(
    turn_count: u32,
    has_user_message_content: bool,
    assignment_model_id: Option<&str>,
) -> RoleModelRepin {
    if !should_repin_model_from_role(turn_count, has_user_message_content) {
        return RoleModelRepin::Keep;
    }
    match assignment_model_id {
        Some(id) if !id.is_empty() => RoleModelRepin::Apply,
        _ => RoleModelRepin::Keep,
    }
}

/// Marker so identity can be re-applied on Tab without stacking.
const PRODUCT_ROLE_IDENTITY_MARKER: &str = "<!-- do-product-role-identity -->";

/// Map agent permission mode to the Identity policy label.
pub fn product_policy_label(permission_mode: &xai_grok_agent::config::PermissionMode) -> &'static str {
    use xai_grok_agent::config::PermissionMode;
    match permission_mode {
        PermissionMode::Default => "default",
        PermissionMode::AcceptEdits => "accept-edits",
        PermissionMode::Auto => "auto",
        PermissionMode::DontAsk => "dont-ask",
        PermissionMode::BypassPermissions => "bypass",
        PermissionMode::Plan => "plan",
    }
}

/// Strip a previously injected product Identity block (if any).
fn strip_product_role_identity(body: &str) -> &str {
    let trimmed = body.trim_start();
    if let Some(rest) = trimmed.strip_prefix(PRODUCT_ROLE_IDENTITY_MARKER) {
        // Drop through the first horizontal rule after the marker block.
        if let Some(idx) = rest.find("\n---\n") {
            return rest[idx + "\n---\n".len()..].trim_start();
        }
        return rest.trim_start();
    }
    body
}

/// Build the model-facing Identity + agent kernel prefix for a product agent.
///
/// Stock `base_template()` still opens with "You are Grok…". This block is
/// appended via `prompt_body` so the model can answer "what is your role?"
/// without reading chrome.
pub fn product_role_identity_block(
    role: &str,
    policy: &str,
    description: &str,
) -> String {
    let alias = agent_alias(role);
    let canonical = canonical_agent_name(role);
    let desc = description.trim();
    let desc_line = if desc.is_empty() {
        String::new()
    } else {
        format!("- Description: {desc}\n")
    };
    format!(
        "{PRODUCT_ROLE_IDENTITY_MARKER}\n\
         ## Identity\n\
         - Product agent: **do**\n\
         - Active agent: **{alias}** (`{canonical}`)\n\
         - Policy: **{policy}**\n\
         {desc_line}\n\
         You are the **{alias}** agent for this session. Follow the mission, \
         workflow, and DO/DON'T below. Do not claim a different product agent.\n\
         Agent may change only before the first user message; after conversation \
         content exists, this agent is fixed for the session.\n\
         \n\
         ## Available tools\n\
         ${{toolsList}}\n\
         ---\n"
    )
}

/// Ensure a product-agent `AgentDefinition` carries a clear Identity block in
/// `prompt_body` so Extend assembly (stock base + body) names the agent.
///
/// No-op for non-product agents. Safe to call repeatedly (replaces prior block).
pub fn ensure_product_role_identity(def: &mut xai_grok_agent::AgentDefinition) {
    if !is_product_agent(&def.name) {
        return;
    }
    let policy = product_policy_label(&def.permission_mode);
    let mission = def
        .prompt_body
        .as_deref()
        .map(strip_product_role_identity)
        .unwrap_or("")
        .to_string();
    let prefix = product_role_identity_block(&def.name, policy, &def.description);
    def.prompt_body = Some(format!("{prefix}{mission}"));
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn role_switch_allowed_true_only_pre_message() {
        assert!(role_switch_allowed(0, false));
        assert!(!role_switch_allowed(1, false));
        assert!(!role_switch_allowed(0, true));
        assert!(!role_switch_allowed(3, true));
    }

    #[test]
    fn product_role_identity_names_role() {
        let block = product_role_identity_block(
            "orchestrator",
            "default",
            "do product orchestrator — continuum + spawn specialists",
        );
        assert!(block.contains("Active agent: **orchestrator**"));
        assert!(block.contains("`grok-build-orchestrator`"));
        assert!(block.contains("Policy: **default**"));
        assert!(block.contains("You are the **orchestrator** agent"));
        assert!(block.contains(PRODUCT_ROLE_IDENTITY_MARKER));
    }

    #[test]
    fn ensure_product_role_identity_is_idempotent() {
        let mut def = xai_grok_agent::AgentDefinition::from_json(&serde_json::json!({
            "name": "orchestrator",
            "description": "test orchestrator",
            "promptBody": "## Mission\n\nOwn the continuum.\n",
            "permissionMode": "default",
        }))
        .expect("parse");
        ensure_product_role_identity(&mut def);
        let first = def.prompt_body.clone().unwrap();
        ensure_product_role_identity(&mut def);
        let second = def.prompt_body.clone().unwrap();
        assert_eq!(first, second, "identity inject must not stack");
        assert_eq!(
            first.matches(PRODUCT_ROLE_IDENTITY_MARKER).count(),
            1,
            "exactly one identity marker"
        );
        assert!(first.contains("Active agent: **orchestrator**"));
        assert!(first.contains("## Mission"));
        assert!(first.contains("Own the continuum"));
    }

    #[test]
    fn ensure_product_role_identity_skips_non_product() {
        let mut def = xai_grok_agent::AgentDefinition::from_json(&serde_json::json!({
            "name": "grok-build-plan",
            "description": "stock",
            "promptBody": "hello",
        }))
        .expect("parse");
        ensure_product_role_identity(&mut def);
        assert_eq!(def.prompt_body.as_deref(), Some("hello"));
    }

    #[test]
    fn product_roster_has_five_roles() {
        assert_eq!(PRODUCT_ROSTER.len(), 5);
        assert!(is_product_role("intake"));
        assert!(is_product_role("orchestrator"));
        assert!(is_product_role("explore"));
        assert!(is_product_role("explorer"));
        assert!(is_product_role("worker"));
        assert!(is_product_role("oracle"));
        assert!(is_product_role("grok-build-worker"));
        assert!(is_product_role("grok-build-ask-user"));
        assert!(!is_product_role("plan"));
        assert!(!is_product_role("default"));
        assert!(!is_product_role("browser_use"));
    }

    #[test]
    fn canonical_agent_name_maps_aliases() {
        assert_eq!(canonical_agent_name("worker"), "grok-build-worker");
        assert_eq!(canonical_agent_name("intake"), "grok-build-ask-user");
        assert_eq!(canonical_agent_name("explorer"), "explore");
        assert_eq!(
            canonical_agent_name("grok-build-orchestrator"),
            "grok-build-orchestrator"
        );
    }

    #[test]
    fn cycle_product_role_wraps() {
        assert_eq!(cycle_product_role(Some("intake"), true), "orchestrator");
        assert_eq!(cycle_product_role(Some("oracle"), true), "intake");
        assert_eq!(cycle_product_role(Some("intake"), false), "oracle");
        assert_eq!(cycle_product_role(Some("oracle"), false), "worker");
        assert_eq!(cycle_product_role(None, true), "intake");
        assert_eq!(cycle_product_role(None, false), "oracle");
        // Unknown current → enter roster from ends
        assert_eq!(cycle_product_role(Some("grok-build"), true), "intake");
        // Canonical current still cycles
        assert_eq!(
            cycle_product_role(Some("grok-build-worker"), true),
            "oracle"
        );
    }

    #[test]
    fn gate_role_cycle_apply_when_allowed() {
        assert_eq!(
            gate_role_cycle(0, false, Some("intake"), true),
            RoleCycleGate::Apply {
                next_role: "orchestrator"
            }
        );
        assert_eq!(
            gate_role_cycle(0, false, Some("worker"), false),
            RoleCycleGate::Apply {
                next_role: "explore"
            }
        );
    }

    #[test]
    fn gate_role_cycle_locked_is_noop() {
        assert_eq!(
            gate_role_cycle(1, false, Some("intake"), true),
            RoleCycleGate::Locked
        );
        assert_eq!(
            gate_role_cycle(0, true, Some("intake"), true),
            RoleCycleGate::Locked
        );
    }

    #[test]
    fn role_switch_locked_toast_names_role_and_new_session() {
        let named = role_switch_locked_toast(Some("worker"));
        assert!(named.contains("worker"), "{named}");
        assert!(named.contains("new session"), "{named}");
        let generic = role_switch_locked_toast(None);
        assert_eq!(generic, ROLE_SWITCH_LOCKED_HINT);
        assert!(ROLE_SWITCH_LOCKED_ON_FIRST_MESSAGE.contains("new session"));
    }

    #[test]
    fn is_product_role_mode_id_matches_roster_only() {
        assert!(is_product_role_mode_id("worker"));
        assert!(is_product_role_mode_id("grok-build-worker"));
        assert!(!is_product_role_mode_id("plan"));
        assert!(!is_product_role_mode_id("default"));
        assert!(!is_product_role_mode_id("ask"));
    }

    #[test]
    fn should_repin_model_only_while_switch_allowed() {
        assert!(should_repin_model_from_role(0, false));
        assert!(!should_repin_model_from_role(1, false));
        assert!(!should_repin_model_from_role(0, true));
    }

    #[test]
    fn gate_role_model_repin_apply_when_unlocked_with_pin() {
        assert_eq!(
            gate_role_model_repin(0, false, Some("combo-small")),
            RoleModelRepin::Apply
        );
        assert_eq!(
            gate_role_model_repin(0, false, Some("combo-big")),
            RoleModelRepin::Apply
        );
    }

    #[test]
    fn gate_role_model_repin_keep_when_locked_or_inherit() {
        assert_eq!(
            gate_role_model_repin(1, false, Some("combo-big")),
            RoleModelRepin::Keep
        );
        assert_eq!(
            gate_role_model_repin(0, true, Some("combo-big")),
            RoleModelRepin::Keep
        );
        assert_eq!(gate_role_model_repin(0, false, None), RoleModelRepin::Keep);
        assert_eq!(
            gate_role_model_repin(0, false, Some("")),
            RoleModelRepin::Keep
        );
    }
}
