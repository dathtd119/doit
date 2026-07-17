//! Product role accent colors for chrome (plan D3).
//!
//! Role name slot + chatbox border use these accents. Model and policy
//! segments stay theme-neutral.
//!
//! Default primary role and per-role model pins are **config-driven**:
//! `[roles].default` and `[roles.<stem>].model` in `config.toml` (merged
//! from `do-harness/config.roles.toml` via sync). Hardcoded tables are
//! fallbacks only when config is missing.

use ratatui::style::Color;
use xai_grok_shell::agent::config::RolesConfig;
use xai_grok_shell::session::role_switch::PRODUCT_ROSTER;

/// Resolve a role accent from a TOML `color` name or product fallback table.
///
/// Priority:
/// 1. Named color string (`cyan`, `blue`, …) matching product/AgentColor names
/// 2. Fixed product roster table (pi-ness-style defaults)
/// 3. Theme secondary gray via caller when this returns `None`
pub fn role_accent_from_name(color_name: Option<&str>) -> Option<Color> {
    color_name.and_then(named_role_color)
}

/// Accent for a known product role stem when TOML color is unavailable.
pub fn product_role_fallback_accent(role: &str) -> Option<Color> {
    match role {
        "intake" => Some(Color::Rgb(125, 207, 255)),      // cyan
        "orchestrator" => Some(Color::Rgb(77, 121, 255)), // blue
        "explorer" => Some(Color::Rgb(36, 196, 116)),     // green
        "worker" => Some(Color::Rgb(255, 219, 141)),      // yellow
        "oracle" => Some(Color::Rgb(131, 113, 211)),      // purple
        _ => None,
    }
}

/// Best-effort accent for `role`: optional TOML color, then product table.
pub fn resolve_role_accent(role: Option<&str>, toml_color: Option<&str>) -> Option<Color> {
    if let Some(c) = role_accent_from_name(toml_color) {
        return Some(c);
    }
    role.and_then(product_role_fallback_accent)
}

/// Map AgentColor / role contract color strings to RGB (TokyoNight-aligned).
fn named_role_color(name: &str) -> Option<Color> {
    match name.trim().to_ascii_lowercase().as_str() {
        "red" => Some(Color::Rgb(248, 114, 122)),
        "blue" => Some(Color::Rgb(77, 121, 255)),
        "green" => Some(Color::Rgb(36, 196, 116)),
        "yellow" => Some(Color::Rgb(255, 219, 141)),
        "purple" | "magenta" => Some(Color::Rgb(131, 113, 211)),
        "orange" => Some(Color::Rgb(255, 158, 100)),
        "pink" => Some(Color::Rgb(255, 0, 124)),
        "cyan" => Some(Color::Rgb(125, 207, 255)),
        _ => None,
    }
}

/// Compile-time last resort when no config is loaded (`roles.default` unset).
fn static_default_product_role() -> &'static str {
    PRODUCT_ROSTER.first().copied().unwrap_or("intake")
}

/// Load merged `[roles]` from effective config (user + project layers).
fn load_roles_config() -> Option<RolesConfig> {
    xai_grok_shell::config::load_effective_config()
        .ok()
        .and_then(|root| xai_grok_shell::agent::config::Config::new_from_toml_cfg(&root).ok())
        .map(|c| c.roles)
}

/// Default primary-session role stem from config.
///
/// Source of truth: `config.toml` `[roles] default = "…"`.
/// When that key is absent, [`RolesConfig::default_role`] returns product
/// `intake`. When config cannot be loaded at all, falls back to
/// [`PRODUCT_ROSTER`]`[0]`.
///
/// Users change cold-start role by editing:
/// ```toml
/// [roles]
/// default = "worker"   # or intake / orchestrator / explorer / oracle
///
/// [agent]
/// name = "worker"      # optional explicit pin; sync-user-config aligns this
/// ```
pub fn default_product_role() -> String {
    load_roles_config()
        .map(|r| r.default_role().to_string())
        .unwrap_or_else(|| static_default_product_role().to_string())
}

/// Product role → model id for optimistic chrome re-pin on Tab.
///
/// Prefers `[roles.<stem>].model` from effective config; falls back to the
/// product pin table (matches `do-harness/config.roles.toml` defaults).
/// Shell also re-pins via ACP `session/set_mode` from agent frontmatter.
pub fn product_role_model_pin(role: &str) -> Option<String> {
    if let Some(model) = load_roles_config()
        .and_then(|r| r.get(role).and_then(|c| c.model.clone()))
        .filter(|s| !s.trim().is_empty())
    {
        return Some(model);
    }
    product_role_model_pin_fallback(role).map(str::to_string)
}

/// Hardcoded model pins when config has no `[roles.<stem>].model`.
fn product_role_model_pin_fallback(role: &str) -> Option<&'static str> {
    match role {
        "intake" => Some("combo-big"),
        "orchestrator" => Some("combo-big"),
        "explorer" => Some("combo-small"),
        "worker" => Some("combo-medium"),
        "oracle" => Some("combo-big-ultra"),
        _ => None,
    }
}

/// Lookup TOML role color from agent config if present.
pub fn role_color_from_config(roles: &RolesConfig, role: &str) -> Option<String> {
    roles.get(role).and_then(|c| c.color.clone())
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn named_colors_map() {
        assert!(named_role_color("cyan").is_some());
        assert!(named_role_color("YELLOW").is_some());
        assert!(named_role_color("not-a-color").is_none());
    }

    #[test]
    fn product_fallback_covers_roster() {
        for r in PRODUCT_ROSTER {
            assert!(
                product_role_fallback_accent(r).is_some(),
                "missing fallback for {r}"
            );
        }
    }

    #[test]
    fn resolve_prefers_toml_name() {
        let a = resolve_role_accent(Some("worker"), Some("cyan")).unwrap();
        let b = resolve_role_accent(Some("worker"), None).unwrap();
        assert_ne!(a, b); // cyan vs yellow worker default
    }

    #[test]
    fn static_default_is_roster_first() {
        assert_eq!(static_default_product_role(), "intake");
    }

    #[test]
    fn model_pin_fallback_covers_roster() {
        for r in PRODUCT_ROSTER {
            assert!(
                product_role_model_pin_fallback(r).is_some(),
                "missing model pin fallback for {r}"
            );
        }
    }

    #[test]
    fn default_product_role_is_non_empty() {
        let role = default_product_role();
        assert!(!role.is_empty(), "default product role must not be empty");
    }
}
