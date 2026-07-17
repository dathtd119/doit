//! Product role accent colors for chrome (plan D3).
//!
//! Role name slot + chatbox border use these accents. Model and policy
//! segments stay theme-neutral.
//!
//! Default primary role and per-role model pins are **config-driven**:
//! `[agent] name`, `[agents|roles].default`, and `[agents|roles.<stem>].model`
//! in `config.toml` (merged from do-harness seeds via sync). Hardcoded tables
//! are fallbacks only when config is missing.

use ratatui::style::Color;
use xai_grok_shell::agent::config::RolesConfig;
use xai_grok_shell::session::role_switch::PRODUCT_ROSTER;

/// Resolve a role accent from a TOML `color` name or product fallback table.
pub fn role_accent_from_name(color_name: Option<&str>) -> Option<Color> {
    color_name.and_then(named_role_color)
}

/// Accent for a known product role stem when TOML color is unavailable.
pub fn product_role_fallback_accent(role: &str) -> Option<Color> {
    use xai_grok_shell::session::role_switch::{agent_alias, canonical_agent_name};
    match agent_alias(canonical_agent_name(role)) {
        "intake" => Some(Color::Rgb(125, 207, 255)),
        "orchestrator" => Some(Color::Rgb(77, 121, 255)),
        "explore" | "explorer" => Some(Color::Rgb(36, 196, 116)),
        "worker" => Some(Color::Rgb(255, 219, 141)),
        "oracle" => Some(Color::Rgb(131, 113, 211)),
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

fn static_default_product_role() -> &'static str {
    PRODUCT_ROSTER.first().copied().unwrap_or("intake")
}

fn load_product_config() -> Option<xai_grok_shell::agent::config::Config> {
    xai_grok_shell::config::load_effective_config()
        .ok()
        .and_then(|root| xai_grok_shell::agent::config::Config::new_from_toml_cfg(&root).ok())
}

fn load_roles_config() -> Option<RolesConfig> {
    load_product_config().map(|c| c.roles)
}

/// Default primary-session role stem from config (chrome label form).
///
/// Priority: `[agent] name` → `[agents|roles].default` → PRODUCT_ROSTER[0].
/// Returns short alias for known product agents.
pub fn default_product_role() -> String {
    use xai_grok_shell::session::role_switch::{agent_alias, is_product_agent};
    if let Some(cfg) = load_product_config() {
        let raw = cfg
            .agent
            .name
            .as_deref()
            .map(str::trim)
            .filter(|s| !s.is_empty())
            .unwrap_or_else(|| cfg.roles.default_role());
        if is_product_agent(raw) {
            return agent_alias(raw).to_string();
        }
        return raw.to_string();
    }
    static_default_product_role().to_string()
}

pub fn product_role_model_pin(role: &str) -> Option<String> {
    if let Some(model) = load_roles_config()
        .and_then(|r| r.get(role).and_then(|c| c.model.clone()))
        .filter(|s| !s.trim().is_empty())
    {
        return Some(model);
    }
    product_role_model_pin_fallback(role).map(str::to_string)
}

fn product_role_model_pin_fallback(role: &str) -> Option<&'static str> {
    use xai_grok_shell::session::role_switch::{agent_alias, canonical_agent_name};
    match agent_alias(canonical_agent_name(role)) {
        "intake" => Some("combo-big"),
        "orchestrator" => Some("combo-big"),
        "explore" | "explorer" => Some("combo-small"),
        "worker" => Some("combo-medium"),
        "oracle" => Some("combo-big-ultra"),
        _ => None,
    }
}

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
        assert!(product_role_fallback_accent("explore").is_some());
        assert!(product_role_fallback_accent("grok-build-orchestrator").is_some());
    }

    #[test]
    fn resolve_prefers_toml_name() {
        let a = resolve_role_accent(Some("worker"), Some("cyan")).unwrap();
        let b = resolve_role_accent(Some("worker"), None).unwrap();
        assert_ne!(a, b);
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
        assert!(!role.is_empty());
    }
}
