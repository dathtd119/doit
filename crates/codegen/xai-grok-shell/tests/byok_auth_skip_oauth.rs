//! Integration tests for F-PRIV-AUTH / VAL-PRIV-AUTH-001 / P-AUTH-01.
//!
//! Lives outside the lib so it does not depend on unrelated `cfg(test)` seams
//! in the shell crate (pre-existing). Exercises the same public helpers that
//! `workspace_start` uses to skip interactive grok.com OAuth for BYOK.

use serial_test::serial;
use xai_grok_shell::agent::auth_method::{
    AuthMethodKind, AuthMethodsBuildInputs, XAI_API_KEY_ENV_VAR, build_auth_methods,
    config_satisfies_api_key_auth, should_advertise_xai_api_key, should_require_interactive_oauth,
};
use xai_grok_shell::agent::config::{Config, resolve_model_list};
use xai_grok_shell::auth::PreferredAuthMethod;
use xai_grok_test_support::EnvGuard;

#[test]
#[serial]
fn preferred_method_api_key_skips_interactive_oauth() {
    let toml: toml::Value = toml::from_str(
        r#"
        [auth]
        preferred_method = "api_key"
        "#,
    )
    .unwrap();
    let cfg = Config::new_from_toml_cfg(&toml).expect("config should parse");
    assert_eq!(
        cfg.grok_com_config.preferred_method,
        Some(PreferredAuthMethod::ApiKey)
    );
    assert!(
        !should_require_interactive_oauth(&cfg),
        "preferred_method=api_key must never force interactive grok.com OAuth"
    );
}

#[test]
#[serial]
fn byok_custom_model_skips_interactive_oauth() {
    const TEST_ENV_VAR: &str = "TEST_PAUTH_BYOK_TOKEN";
    let _global = EnvGuard::unset(XAI_API_KEY_ENV_VAR);
    let _set = EnvGuard::set(TEST_ENV_VAR, "byok-product-secret");

    let toml: toml::Value = toml::from_str(&format!(
        r#"
        [models]
        default = "my-custom"

        [model.my-custom]
        model = "provider-model-id"
        base_url = "https://api.example.com/v1"
        env_key = "{TEST_ENV_VAR}"
        context_window = 128000
        "#,
    ))
    .unwrap();
    let cfg = Config::new_from_toml_cfg(&toml).expect("config should parse");
    assert!(
        config_satisfies_api_key_auth(&cfg),
        "resolved [model.*] env_key must satisfy API-key / BYOK auth"
    );
    assert!(
        !should_require_interactive_oauth(&cfg),
        "BYOK custom models must not force interactive grok.com OAuth"
    );

    let models = resolve_model_list(&cfg, None);
    let has_external = should_advertise_xai_api_key(false, models.values());
    let built = build_auth_methods(AuthMethodsBuildInputs {
        has_external_api_key: has_external,
        has_cached_token: false,
        has_enterprise_oidc: false,
        enterprise_oidc_issuer: None,
        login_label: None,
        has_auth_provider_command: false,
        preferred_method: None,
    });
    let first = built.methods.first().expect("BYOK must advertise a method");
    assert_eq!(
        AuthMethodKind::from_id(first.id()),
        AuthMethodKind::XaiApiKey
    );
    assert!(!AuthMethodKind::from_id(first.id()).needs_interactive_login());
}

#[test]
#[serial]
fn stock_config_without_byok_still_requires_interactive_oauth() {
    let _global = EnvGuard::unset(XAI_API_KEY_ENV_VAR);
    let _legacy = EnvGuard::unset(xai_grok_shell::agent::auth_method::LEGACY_XAI_API_KEY_ENV_VAR);
    let toml: toml::Value = toml::from_str("").unwrap();
    let cfg = Config::new_from_toml_cfg(&toml).expect("empty config should parse");
    assert!(
        should_require_interactive_oauth(&cfg),
        "stock defaults with no BYOK must still allow interactive OAuth gate"
    );
}
