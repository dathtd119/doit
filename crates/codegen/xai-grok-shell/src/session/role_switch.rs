//! Primary-session role switch lock (do product L1 / VAL-M1-LOCK-001).
//!
//! Binding rule: Tab / Shift+Tab product-role cycle is allowed only while the
//! session has no user messages / no conversation content. After the first
//! user message, `role_switch_allowed` is false — L1 role layer and model
//! re-pin from role stay frozen for the remainder of the session.
//!
//! Pure policy (no I/O) so unit tests and both shell + pager call sites share
//! one definition of the flag and product roster.

/// Product roster order for primary-session role cycle (do M1).
///
/// Matches `do-harness/agents/` discovery names. Cycle wraps at ends.
pub const PRODUCT_ROSTER: &[&str] = &["intake", "orchestrator", "explorer", "worker", "oracle"];

/// Session flag: whether primary-session product role switching is allowed.
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

/// Whether `name` is a do product roster role (case-sensitive agent file stem).
#[inline]
pub fn is_product_role(name: &str) -> bool {
    PRODUCT_ROSTER.iter().any(|r| *r == name)
}

/// Whether `session_mode_id` names a product role (not plan/default/ask/etc.).
///
/// Stock ACP `session/set_mode` reuses mode ids for agent profiles when the
/// client selects a discovered agent. Product roles must freeze after lock;
/// plan/permission modes remain switchable.
#[inline]
pub fn is_product_role_mode_id(session_mode_id: &str) -> bool {
    is_product_role(session_mode_id)
}

/// Next / previous product role in roster order.
///
/// If `current` is not on the roster, starts from the first (forward) or last
/// (backward) entry so a fresh session can enter the cycle.
pub fn cycle_product_role(current: Option<&str>, forward: bool) -> &'static str {
    let idx = current.and_then(|c| PRODUCT_ROSTER.iter().position(|r| *r == c));
    match (idx, forward) {
        (Some(i), true) => PRODUCT_ROSTER[(i + 1) % PRODUCT_ROSTER.len()],
        (Some(i), false) => {
            let n = PRODUCT_ROSTER.len();
            PRODUCT_ROSTER[(i + n - 1) % n]
        }
        (None, true) => PRODUCT_ROSTER[0],
        (None, false) => PRODUCT_ROSTER[PRODUCT_ROSTER.len() - 1],
    }
}

/// Toast when Tab product-role cycle is denied after lock (F-M1-UX / M1-U01).
///
/// Points the user at a **new session** — mid-session hop is forbidden.
pub const ROLE_SWITCH_LOCKED_HINT: &str =
    "Role locked after first message — start a new session to switch roles";

/// Toast once when the first user message freezes the product role (F-M1-UX).
pub const ROLE_SWITCH_LOCKED_ON_FIRST_MESSAGE: &str =
    "Role locked for this session — start a new session to change role";

/// User-visible copy for a locked role-cycle attempt (optional role label).
pub fn role_switch_locked_toast(current_role: Option<&str>) -> String {
    match current_role {
        Some(role) if is_product_role(role) => {
            format!("Role locked ({role}) — start a new session to switch roles")
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

/// Gate a Tab / Shift+Tab product-role cycle.
///
/// `forward`: Tab (true) or Shift+Tab (false) when used as role cycle.
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

/// Whether primary-session role switch should re-pin the model from the new
/// role's assignment (agent frontmatter `model:` / YAML `assignment.<role>`).
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

/// Outcome of role→model re-resolve for a primary-session role hop.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum RoleModelRepin {
    /// Apply the role assignment pin (`AgentDefinition.model` Override).
    Apply,
    /// Keep the active model stack (post-lock, or Inherit pin).
    Keep,
}

/// Gate role→model re-pin for a primary-session product role switch.
///
/// `assignment_model_id`: registry/catalog model id from agent frontmatter
/// when the role pins a model; `None` means Inherit / no pin.
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
    fn product_roster_has_five_roles() {
        assert_eq!(PRODUCT_ROSTER.len(), 5);
        assert!(is_product_role("intake"));
        assert!(is_product_role("orchestrator"));
        assert!(is_product_role("explorer"));
        assert!(is_product_role("worker"));
        assert!(is_product_role("oracle"));
        assert!(!is_product_role("plan"));
        assert!(!is_product_role("default"));
        assert!(!is_product_role("browser_use"));
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
                next_role: "explorer"
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
