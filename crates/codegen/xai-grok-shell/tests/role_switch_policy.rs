//! Integration tests for primary-session role switch lock (VAL-M1-LOCK-001).
//!
//! Lives outside the lib so it does not depend on unrelated `cfg(test)` seams
//! in the shell crate (pre-existing). Pure policy is public on the lib.

use xai_grok_shell::session::role_switch::{
    PRODUCT_ROSTER, ROLE_SWITCH_LOCKED_HINT, ROLE_SWITCH_LOCKED_ON_FIRST_MESSAGE, RoleCycleGate,
    RoleModelRepin, cycle_product_role, gate_role_cycle, gate_role_model_repin, is_product_role,
    is_product_role_mode_id, role_switch_allowed, role_switch_locked_toast,
    should_repin_model_from_role,
};

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
    assert!(!should_repin_model_from_role(3, true));
}

#[test]
fn gate_role_model_repin_apply_pre_message_with_assignment() {
    // Pre-message role cycle re-pins from YAML/agent assignment.
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
fn gate_role_model_repin_keep_post_lock_or_inherit() {
    // Post-message: no re-pin even if assignment would change.
    assert_eq!(
        gate_role_model_repin(1, false, Some("combo-big")),
        RoleModelRepin::Keep
    );
    assert_eq!(
        gate_role_model_repin(0, true, Some("combo-small")),
        RoleModelRepin::Keep
    );
    // Inherit / empty pin: keep stack (subagent spawn path unchanged).
    assert_eq!(gate_role_model_repin(0, false, None), RoleModelRepin::Keep);
    assert_eq!(
        gate_role_model_repin(0, false, Some("")),
        RoleModelRepin::Keep
    );
}

#[test]
fn role_switch_locked_toast_points_to_new_session() {
    // F-M1-UX: lock affordance must name new-session escape hatch.
    let named = role_switch_locked_toast(Some("explorer"));
    assert!(named.contains("explorer"), "{named}");
    assert!(named.contains("new session"), "{named}");
    assert_eq!(role_switch_locked_toast(None), ROLE_SWITCH_LOCKED_HINT);
    assert!(ROLE_SWITCH_LOCKED_HINT.contains("new session"));
    assert!(ROLE_SWITCH_LOCKED_ON_FIRST_MESSAGE.contains("new session"));
    // Non-product label falls back to generic copy.
    assert_eq!(
        role_switch_locked_toast(Some("plan")),
        ROLE_SWITCH_LOCKED_HINT
    );
}
