//! Product role definitions from config contracts + prompt bodies.
//!
//! Stock product roles no longer ship as `do-harness/agents/*.md` or install into
//! `.doit/agents/` / `~/.config/doit/agents/`. Those agent dirs are **user override
//! only** (empty by default).
//!
//! Resolve order for a product roster stem:
//! 1. Optional user agent file (project `.doit/agents/<stem>.md`, then user home)
//! 2. Built-in body from `do-harness/prompts/roles/<stem>.md` (compile-time) +
//!    contract from `RolesConfig` / hardcoded product floors when config is thin
//!
//! Prompt bodies may also be overridden without agent frontmatter:
//! - `.doit/prompts/roles/<stem>.md`
//! - `~/.config/doit/prompts/roles/<stem>.md`

use std::path::{Path, PathBuf};

use xai_grok_agent::config::{
    AgentColor, AgentDefinition, AgentScope, ModelOverride, PermissionMode, PromptMode,
};

use crate::agent::config::{RoleContract, RolesConfig};
use crate::session::role_switch::{PRODUCT_ROSTER, is_product_role};

/// Compile-time product mission bodies (do-harness/prompts/roles SoT).
fn bundled_role_body(stem: &str) -> Option<&'static str> {
    match stem {
        "intake" => Some(include_str!(
            "../../../../../do-harness/prompts/roles/intake.md"
        )),
        "orchestrator" => Some(include_str!(
            "../../../../../do-harness/prompts/roles/orchestrator.md"
        )),
        "explorer" => Some(include_str!(
            "../../../../../do-harness/prompts/roles/explorer.md"
        )),
        "worker" => Some(include_str!(
            "../../../../../do-harness/prompts/roles/worker.md"
        )),
        "oracle" => Some(include_str!(
            "../../../../../do-harness/prompts/roles/oracle.md"
        )),
        _ => None,
    }
}

/// Hardcoded product floors when `[roles.<stem>]` is missing from config
/// (matches `do-harness/config.roles.toml` seed).
fn product_floor_contract(stem: &str) -> Option<RoleContract> {
    match stem {
        "intake" => Some(RoleContract {
            description: Some("do product intake — clarify intent; no implementation".into()),
            model: Some("combo-big".into()),
            color: Some("cyan".into()),
            permission_mode: Some("plan".into()),
            discover_skills: Some(false),
            tools: vec![
                "read_file".into(),
                "list_dir".into(),
                "grep".into(),
                "run_terminal_cmd".into(),
                "ask_user_question".into(),
                "Agent(explore)".into(),
            ],
            disallowed_tools: vec![
                "search_replace".into(),
                "write".into(),
                "image_gen".into(),
                "image_edit".into(),
                "image_to_video".into(),
                "reference_to_video".into(),
                "enter_plan_mode".into(),
                "exit_plan_mode".into(),
                "update_goal".into(),
                "todo_write".into(),
            ],
            effort: None,
        }),
        "orchestrator" => Some(RoleContract {
            description: Some(
                "do product orchestrator — continuum + spawn specialists; no bulk write".into(),
            ),
            model: Some("combo-big".into()),
            color: Some("blue".into()),
            permission_mode: Some("default".into()),
            discover_skills: Some(false),
            tools: vec![
                "read_file".into(),
                "list_dir".into(),
                "grep".into(),
                "run_terminal_cmd".into(),
                "ask_user_question".into(),
                "update_goal".into(),
                "todo_write".into(),
                "enter_plan_mode".into(),
                "exit_plan_mode".into(),
                "task".into(),
                "Agent(explore)".into(),
                "Agent(explorer)".into(),
                "Agent(worker)".into(),
                "Agent(oracle)".into(),
                "Agent(intake)".into(),
            ],
            disallowed_tools: vec![
                "write".into(),
                "search_replace".into(),
                "image_gen".into(),
                "image_edit".into(),
                "image_to_video".into(),
                "reference_to_video".into(),
            ],
            effort: None,
        }),
        "explorer" => Some(RoleContract {
            description: Some("do product explorer — read-only scout / maps / citations".into()),
            model: Some("combo-small".into()),
            color: Some("green".into()),
            permission_mode: Some("plan".into()),
            discover_skills: Some(false),
            tools: vec![
                "read_file".into(),
                "list_dir".into(),
                "grep".into(),
                "run_terminal_cmd".into(),
                "lsp".into(),
                "search_tool".into(),
                "use_tool".into(),
            ],
            disallowed_tools: vec![
                "search_replace".into(),
                "write".into(),
                "image_gen".into(),
                "image_edit".into(),
                "image_to_video".into(),
                "reference_to_video".into(),
                "enter_plan_mode".into(),
                "exit_plan_mode".into(),
                "update_goal".into(),
                "todo_write".into(),
                "Agent(worker)".into(),
                "Agent(oracle)".into(),
                "Agent(orchestrator)".into(),
            ],
            effort: None,
        }),
        "worker" => Some(RoleContract {
            description: Some(
                "do product worker — implement + verify; prefer search_replace/write".into(),
            ),
            model: Some("combo-medium".into()),
            color: Some("yellow".into()),
            permission_mode: Some("default".into()),
            discover_skills: Some(false),
            tools: vec![
                "read_file".into(),
                "list_dir".into(),
                "grep".into(),
                "run_terminal_cmd".into(),
                "search_replace".into(),
                "write".into(),
                "lsp".into(),
                "todo_write".into(),
                "update_goal".into(),
                "Agent(explore)".into(),
                "Agent(explorer)".into(),
            ],
            disallowed_tools: vec![
                "Agent(oracle)".into(),
                "Agent(orchestrator)".into(),
                "image_gen".into(),
                "image_edit".into(),
                "image_to_video".into(),
                "reference_to_video".into(),
            ],
            effort: None,
        }),
        "oracle" => Some(RoleContract {
            description: Some("do product oracle — architecture / trade-offs; no bulk edit".into()),
            model: Some("combo-big-ultra".into()),
            color: Some("purple".into()),
            permission_mode: Some("plan".into()),
            discover_skills: Some(false),
            tools: vec![
                "read_file".into(),
                "list_dir".into(),
                "grep".into(),
                "run_terminal_cmd".into(),
                "lsp".into(),
                "ask_user_question".into(),
                "search_tool".into(),
                "use_tool".into(),
                "Agent(explore)".into(),
                "Agent(explorer)".into(),
            ],
            disallowed_tools: vec![
                "search_replace".into(),
                "write".into(),
                "image_gen".into(),
                "image_edit".into(),
                "image_to_video".into(),
                "reference_to_video".into(),
                "enter_plan_mode".into(),
                "exit_plan_mode".into(),
                "update_goal".into(),
                "todo_write".into(),
                "Agent(worker)".into(),
                "Agent(orchestrator)".into(),
            ],
            effort: None,
        }),
        _ => None,
    }
}

fn parse_permission_mode(raw: &str) -> PermissionMode {
    match raw.trim() {
        "plan" => PermissionMode::Plan,
        "acceptEdits" | "accept-edits" | "accept_edits" => PermissionMode::AcceptEdits,
        "auto" => PermissionMode::Auto,
        "dontAsk" | "dont-ask" | "dont_ask" => PermissionMode::DontAsk,
        "bypassPermissions" | "bypass" | "bypass_permissions" => PermissionMode::BypassPermissions,
        _ => PermissionMode::Default,
    }
}

fn parse_color(raw: &str) -> Option<AgentColor> {
    match raw.trim().to_ascii_lowercase().as_str() {
        "red" => Some(AgentColor::Red),
        "blue" => Some(AgentColor::Blue),
        "green" => Some(AgentColor::Green),
        "yellow" => Some(AgentColor::Yellow),
        "purple" | "magenta" => Some(AgentColor::Purple),
        "orange" => Some(AgentColor::Orange),
        "pink" => Some(AgentColor::Pink),
        "cyan" => Some(AgentColor::Cyan),
        _ => None,
    }
}

/// Resolve mission body: project prompts → user prompts → compile-time harness.
pub fn load_role_body(stem: &str, cwd: &Path) -> Option<String> {
    for dir in role_body_search_dirs(cwd) {
        let path = dir.join(format!("{stem}.md"));
        if path.is_file() {
            match std::fs::read_to_string(&path) {
                Ok(text) => {
                    let body = text.trim_start_matches('\u{feff}').trim_start().to_string();
                    if !body.is_empty() {
                        return Some(body);
                    }
                }
                Err(e) => {
                    tracing::warn!(
                        path = %path.display(),
                        error = %e,
                        "failed to read product role body override"
                    );
                }
            }
        }
    }
    bundled_role_body(stem).map(|s| s.trim_start().to_string())
}

fn role_body_search_dirs(cwd: &Path) -> Vec<PathBuf> {
    let mut dirs = Vec::new();
    // Project: walk cwd → git root for `.doit/prompts/roles`
    let chain = xai_grok_agent::repo::RepoDirChain::resolve(cwd);
    for dir in &chain.dirs {
        let p = dir.join(".doit").join("prompts").join("roles");
        if p.is_dir() {
            dirs.push(p);
        }
    }
    if let Some(home) = xai_grok_config::user_grok_home() {
        let p = home.join("prompts").join("roles");
        if p.is_dir() {
            dirs.push(p);
        }
    }
    dirs
}

/// Optional user agent-file override (project then user). Empty by default —
/// product does **not** install stock roles here.
fn try_user_agent_override(stem: &str, cwd: &Path) -> Option<AgentDefinition> {
    xai_grok_agent::discovery::by_name_in_cwd(stem, cwd).filter(|def| {
        // Only honor file-backed definitions (project/user/bundled), not built-ins
        // with the same name.
        matches!(
            def.scope,
            AgentScope::Project | AgentScope::User | AgentScope::Bundled
        ) && def.source_path.is_some()
    })
}

/// Build product role definition from contract + body (no agents/*.md required).
pub fn definition_from_contract(
    stem: &str,
    contract: &RoleContract,
    body: String,
) -> AgentDefinition {
    let description = contract
        .description
        .clone()
        .unwrap_or_else(|| format!("do product {stem} role"));
    let mut def = AgentDefinition::builtin_defaults(stem, &description);
    def.prompt_mode = PromptMode::Extend;
    def.permission_mode = contract
        .permission_mode
        .as_deref()
        .map(parse_permission_mode)
        .unwrap_or(PermissionMode::Default);
    def.discover_skills = contract.discover_skills.unwrap_or(false);
    def.skills = vec![];
    def.tools = contract.tools.clone();
    def.disallowed_tools = contract.disallowed_tools.clone();
    def.color = contract.color.as_deref().and_then(parse_color);
    def.model = match contract.model.as_deref() {
        Some(m) if !m.is_empty() => ModelOverride::Override(m.to_string()),
        _ => ModelOverride::Inherit,
    };
    def.prompt_body = Some(body);
    def.scope = AgentScope::BuiltIn;
    def.source_path = None;
    def
}

/// Resolve a product roster role for primary session or subagent spawn.
///
/// Returns `None` for non-product names (caller falls through to stock discovery).
pub fn resolve_product_role(
    stem: &str,
    cwd: &Path,
    roles: Option<&RolesConfig>,
) -> Option<AgentDefinition> {
    if !is_product_role(stem) {
        return None;
    }

    // 1. Explicit user override agent file (optional; dirs empty by product default)
    if let Some(def) = try_user_agent_override(stem, cwd) {
        tracing::info!(
            role = %stem,
            path = ?def.source_path,
            "using user agent override for product role"
        );
        return Some(def);
    }

    // 2. Contract from config, else product floors
    let contract_owned;
    let contract = if let Some(c) = roles.and_then(|r| r.get(stem)) {
        c
    } else if let Some(c) = product_floor_contract(stem) {
        contract_owned = c;
        &contract_owned
    } else {
        return None;
    };

    let body = load_role_body(stem, cwd).unwrap_or_else(|| {
        tracing::warn!(role = %stem, "missing product role body; empty mission");
        String::new()
    });

    Some(definition_from_contract(stem, contract, body))
}

/// Resolve product role when only stem is known (loads effective roles config).
pub fn resolve_product_role_in_cwd(stem: &str, cwd: &Path) -> Option<AgentDefinition> {
    let roles = load_effective_roles_config();
    resolve_product_role(stem, cwd, roles.as_ref())
}

fn load_effective_roles_config() -> Option<RolesConfig> {
    crate::config::load_effective_config()
        .ok()
        .and_then(|root| crate::agent::config::Config::new_from_toml_cfg(&root).ok())
        .map(|c| c.roles)
}

/// Whether every product roster stem can resolve without agent files.
#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn all_roster_stems_have_bundled_bodies() {
        for stem in PRODUCT_ROSTER {
            assert!(
                bundled_role_body(stem).is_some_and(|b| b.contains("## Mission")),
                "{stem} bundled body must include ## Mission"
            );
        }
    }

    #[test]
    fn resolve_without_agents_dir() {
        let tmp = tempfile::tempdir().unwrap();
        let def = resolve_product_role("intake", tmp.path(), None).expect("intake");
        assert_eq!(def.name, "intake");
        assert_eq!(def.prompt_mode, PromptMode::Extend);
        assert_eq!(def.permission_mode, PermissionMode::Plan);
        assert!(
            def.prompt_body
                .as_deref()
                .is_some_and(|b| b.contains("Intent Pack") || b.contains("Intake")),
            "body from prompts/roles"
        );
        assert!(def.tools.iter().any(|t| t == "read_file"));
        assert!(def.disallowed_tools.iter().any(|t| t == "write"));
    }

    #[test]
    fn non_product_returns_none() {
        let tmp = tempfile::tempdir().unwrap();
        assert!(resolve_product_role("explore", tmp.path(), None).is_none());
        assert!(resolve_product_role("grok-build", tmp.path(), None).is_none());
    }

    #[test]
    fn user_agent_override_wins() {
        let tmp = tempfile::tempdir().unwrap();
        let agents = tmp.path().join(".doit").join("agents");
        std::fs::create_dir_all(&agents).unwrap();
        std::fs::write(
            agents.join("worker.md"),
            r#"---
name: worker
description: custom override worker
promptMode: extend
permissionMode: default
---
## Mission

CUSTOM_OVERRIDE_BODY
"#,
        )
        .unwrap();
        let def = resolve_product_role("worker", tmp.path(), None).expect("worker");
        assert_eq!(def.name, "worker");
        assert!(
            def.prompt_body
                .as_deref()
                .is_some_and(|b| b.contains("CUSTOM_OVERRIDE_BODY")),
            "user agent file must win"
        );
    }

    #[test]
    fn prompt_body_override_without_agent_file() {
        let tmp = tempfile::tempdir().unwrap();
        let roles = tmp
            .path()
            .join(".doit")
            .join("prompts")
            .join("roles");
        std::fs::create_dir_all(&roles).unwrap();
        std::fs::write(roles.join("oracle.md"), "## Mission\n\nPROMPT_ONLY_OVERRIDE\n").unwrap();
        let def = resolve_product_role("oracle", tmp.path(), None).expect("oracle");
        assert!(
            def.prompt_body
                .as_deref()
                .is_some_and(|b| b.contains("PROMPT_ONLY_OVERRIDE")),
            "prompts/roles override without agents/"
        );
    }
}
