//! Integration tests for primary-session role switch lock (VAL-M1-LOCK-001).
//!
//! Lives outside the lib so it does not depend on unrelated `cfg(test)` seams
//! in the shell crate (pre-existing). Pure policy is public on the lib.

use xai_grok_shell::session::role_switch::{
    PRODUCT_ROSTER, RoleCycleGate, cycle_product_role, gate_role_cycle, is_product_role,
    is_product_role_mode_id, role_switch_allowed,
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
