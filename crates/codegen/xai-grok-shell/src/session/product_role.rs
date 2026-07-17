//! Product agent definitions from config contracts + prompt bodies.
//!
//! Stock product agents no longer ship as `do-harness/agents/*.md` or install into
//! `.doit/agents/` / `~/.config/doit/agents/`. Those agent dirs are **user override
//! only** (empty by default).
//!
//! Resolve order for a product agent (alias or canonical):
//! 1. Optional user agent file (project `.doit/agents/<name>.md`, then user home)
//! 2. Built-in body from `do-harness/prompts/agents/<stem>.md` (compile-time) +
//!    contract from `RolesConfig` / hardcoded product floors when config is thin
//!
//! Prompt bodies may also be overridden without agent frontmatter:
//! - `.doit/prompts/agents/<stem>.md`
//! - `~/.config/doit/prompts/agents/<stem>.md`
//!
//! Naming: see `docs/agents-and-prompts.md` — short aliases map to stock-native
//! canonical ids (`grok-build-worker`, `explore`, …).

use std::path::{Path, PathBuf};

use xai_grok_agent::config::{
    AgentColor, AgentDefinition, AgentScope, ModelOverride, PermissionMode, PromptMode,
};

use crate::agent::config::{RoleContract, RolesConfig};
use crate::session::role_switch::{
    PRODUCT_ROSTER, agent_body_stem, canonical_agent_name, is_product_agent,
};

/// Compile-time product mission bodies (do-harness/prompts/agents SoT).
fn bundled_role_body(stem: &str) -> Option<&'static str> {
    let body_stem = agent_body_stem(stem);
    match body_stem {
        "intake" => Some(include_str!(
            "../../../../../do-harness/prompts/agents/intake.md"
        )),
        "orchestrator" => Some(include_str!(
            "../../../../../do-harness/prompts/agents/orchestrator.md"
        )),
        "explore" | "explorer" => Some(include_str!(
            "../../../../../do-harness/prompts/agents/explore.md"
        )),
        "worker" => Some(include_str!(
            "../../../../../do-harness/prompts/agents/worker.md"
        )),
        "oracle" => Some(include_str!(
            "../../../../../do-harness/prompts/agents/oracle.md"
        )),
        _ => None,
    }
}

/// Hardcoded product floors when config contract is missing
/// (matches `do-harness/config.agents.toml` seed).
fn product_floor_contract(stem: &str) -> Option<RoleContract> {
    let canonical = canonical_agent_name(stem);
    match canonical {
        "grok-build-ask-user" => Some(RoleContract {
            alias: Some("intake".into()),
            name: Some("grok-build-ask-user".into()),
            description: Some("do product intake — clarify intent; no implementation".into()),
            model: Some("combo-big".into()),
            color: Some("cyan".into()),
            permission_mode: Some("plan".into()),
            discover_skills: Some(false),
            base: Some("grok-build-ask-user".into()),
            allowed_subagents: vec!["explore".into()],
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
        "grok-build-orchestrator" => Some(RoleContract {
            alias: Some("orchestrator".into()),
            name: Some("grok-build-orchestrator".into()),
            description: Some(
                "do product orchestrator — continuum + spawn specialists; no bulk write".into(),
            ),
            model: Some("combo-big".into()),
            color: Some("blue".into()),
            permission_mode: Some("default".into()),
            discover_skills: Some(false),
            base: Some("grok-build-orchestrator".into()),
            allowed_subagents: vec![
                "explore".into(),
                "plan".into(),
                "grok-build-worker".into(),
                "grok-build-oracle".into(),
                "general-purpose".into(),
                "grok-build-ask-user".into(),
            ],
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
                "Agent(plan)".into(),
                "Agent(grok-build-worker)".into(),
                "Agent(grok-build-oracle)".into(),
                "Agent(general-purpose)".into(),
                "Agent(grok-build-ask-user)".into(),
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
        "explore" => Some(RoleContract {
            alias: Some("explorer".into()),
            name: Some("explore".into()),
            description: Some("do product explorer — read-only scout / maps / citations".into()),
            model: Some("combo-small".into()),
            color: Some("green".into()),
            permission_mode: Some("plan".into()),
            discover_skills: Some(false),
            base: Some("explore".into()),
            allowed_subagents: vec![],
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
                "Agent(grok-build-worker)".into(),
                "Agent(grok-build-oracle)".into(),
                "Agent(grok-build-orchestrator)".into(),
            ],
            effort: None,
        }),
        "grok-build-worker" => Some(RoleContract {
            alias: Some("worker".into()),
            name: Some("grok-build-worker".into()),
            description: Some(
                "do product worker — implement + verify; prefer search_replace/write".into(),
            ),
            model: Some("combo-medium".into()),
            color: Some("yellow".into()),
            permission_mode: Some("default".into()),
            discover_skills: Some(false),
            base: Some("grok-build".into()),
            allowed_subagents: vec!["explore".into()],
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
            ],
            disallowed_tools: vec![
                "Agent(grok-build-oracle)".into(),
                "Agent(grok-build-orchestrator)".into(),
                "image_gen".into(),
                "image_edit".into(),
                "image_to_video".into(),
                "reference_to_video".into(),
            ],
            effort: None,
        }),
        "grok-build-oracle" => Some(RoleContract {
            alias: Some("oracle".into()),
            name: Some("grok-build-oracle".into()),
            description: Some("do product oracle — architecture / trade-offs; no bulk edit".into()),
            model: Some("combo-big-ultra".into()),
            color: Some("purple".into()),
            permission_mode: Some("plan".into()),
            discover_skills: Some(false),
            base: Some("grok-build".into()),
            allowed_subagents: vec!["explore".into()],
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
                "Agent(grok-build-worker)".into(),
                "Agent(grok-build-orchestrator)".into(),
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
    let body_stem = agent_body_stem(stem);
    let candidates = [body_stem, stem, canonical_agent_name(stem)];
    for dir in role_body_search_dirs(cwd) {
        for name in candidates {
            let path = dir.join(format!("{name}.md"));
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
                            "failed to read product agent body override"
                        );
                    }
                }
            }
        }
    }
    bundled_role_body(stem).map(|s| s.trim_start().to_string())
}

fn role_body_search_dirs(cwd: &Path) -> Vec<PathBuf> {
    let mut dirs = Vec::new();
    // Project: walk cwd → git root for `.doit/prompts/agents` (and legacy `roles`)
    let chain = xai_grok_agent::repo::RepoDirChain::resolve(cwd);
    for dir in &chain.dirs {
        for sub in ["agents", "roles"] {
            let p = dir.join(".doit").join("prompts").join(sub);
            if p.is_dir() {
                dirs.push(p);
            }
        }
    }
    if let Some(home) = xai_grok_config::user_grok_home() {
        for sub in ["agents", "roles"] {
            let p = home.join("prompts").join(sub);
            if p.is_dir() {
                dirs.push(p);
            }
        }
    }
    dirs
}

/// Optional user agent-file override (project then user). Empty by default —
/// product does **not** install stock agents here.
fn try_user_agent_override(stem: &str, cwd: &Path) -> Option<AgentDefinition> {
    let names = [
        stem.to_string(),
        canonical_agent_name(stem).to_string(),
        agent_body_stem(stem).to_string(),
    ];
    for name in names {
        if let Some(def) = xai_grok_agent::discovery::by_name_in_cwd(&name, cwd).filter(|def| {
            matches!(
                def.scope,
                AgentScope::Project | AgentScope::User | AgentScope::Bundled
            ) && def.source_path.is_some()
        }) {
            return Some(def);
        }
    }
    None
}

/// Build product agent definition from contract + body (no agents/*.md required).
pub fn definition_from_contract(
    stem: &str,
    contract: &RoleContract,
    body: String,
) -> AgentDefinition {
    let canonical = contract
        .name
        .as_deref()
        .filter(|s| !s.is_empty())
        .unwrap_or_else(|| canonical_agent_name(stem))
        .to_string();
    let description = contract
        .description
        .clone()
        .unwrap_or_else(|| format!("do product {canonical} agent"));
    let mut def = AgentDefinition::builtin_defaults(&canonical, &description);
    def.name = canonical;
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
    if !contract.allowed_subagents.is_empty() {
        def.allowed_subagent_types = Some(contract.allowed_subagents.clone());
    } else if contract
        .tools
        .iter()
        .any(|t| t.starts_with("Agent(") || t == "task")
    {
        // Derive from Agent(...) tool floors when allowed_subagents omitted
        let derived: Vec<String> = contract
            .tools
            .iter()
            .filter_map(|t| {
                t.strip_prefix("Agent(")
                    .and_then(|s| s.strip_suffix(')'))
                    .map(|s| s.to_string())
            })
            .collect();
        if !derived.is_empty() {
            def.allowed_subagent_types = Some(derived);
        }
    }
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

/// Resolve a product agent for primary session or subagent spawn.
///
/// Returns `None` for non-product names (caller falls through to stock discovery).
pub fn resolve_product_role(
    stem: &str,
    cwd: &Path,
    roles: Option<&RolesConfig>,
) -> Option<AgentDefinition> {
    if !is_product_agent(stem) {
        // Still allow any name that has a config contract (dynamic custom agents).
        if roles.and_then(|r| r.get(stem)).is_none() {
            return None;
        }
    }

    // 1. Explicit user override agent file (optional; dirs empty by product default)
    if let Some(def) = try_user_agent_override(stem, cwd) {
        tracing::info!(
            agent = %stem,
            path = ?def.source_path,
            "using user agent override for product agent"
        );
        return Some(def);
    }

    // 2. Contract from config, else product floors
    let contract_owned;
    let contract = if let Some(c) = roles.and_then(|r| r.get(stem)) {
        c
    } else if let Some(c) = roles.and_then(|r| r.get(canonical_agent_name(stem))) {
        c
    } else if let Some(c) = product_floor_contract(stem) {
        contract_owned = c;
        &contract_owned
    } else {
        return None;
    };

    let body = load_role_body(stem, cwd).unwrap_or_else(|| {
        tracing::warn!(agent = %stem, "missing product agent body; empty mission");
        String::new()
    });

    Some(definition_from_contract(stem, contract, body))
}

/// Resolve product agent when only stem is known (loads effective roles/agents config).
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
        assert_eq!(def.name, "grok-build-ask-user");
        assert_eq!(def.prompt_mode, PromptMode::Extend);
        assert_eq!(def.permission_mode, PermissionMode::Plan);
        assert!(
            def.prompt_body
                .as_deref()
                .is_some_and(|b| b.contains("Intent Pack") || b.contains("Intake")),
            "body from prompts/agents"
        );
        assert!(def.tools.iter().any(|t| t == "read_file"));
        assert!(def.disallowed_tools.iter().any(|t| t == "write"));
        assert_eq!(
            def.allowed_subagent_types.as_deref(),
            Some(["explore".to_string()].as_slice())
        );
    }

    #[test]
    fn resolve_worker_canonical_name() {
        let tmp = tempfile::tempdir().unwrap();
        let def = resolve_product_role("worker", tmp.path(), None).expect("worker");
        assert_eq!(def.name, "grok-build-worker");
        assert!(def.tools.iter().any(|t| t == "search_replace"));
    }

    #[test]
    fn resolve_explore_stock_name() {
        let tmp = tempfile::tempdir().unwrap();
        let def = resolve_product_role("explore", tmp.path(), None).expect("explore");
        assert_eq!(def.name, "explore");
        let via_alias = resolve_product_role("explorer", tmp.path(), None).expect("explorer");
        assert_eq!(via_alias.name, "explore");
    }

    #[test]
    fn non_product_returns_none() {
        let tmp = tempfile::tempdir().unwrap();
        assert!(resolve_product_role("grok-build", tmp.path(), None).is_none());
        assert!(resolve_product_role("browser_use", tmp.path(), None).is_none());
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
        let agents = tmp.path().join(".doit").join("prompts").join("agents");
        std::fs::create_dir_all(&agents).unwrap();
        std::fs::write(
            agents.join("oracle.md"),
            "## Mission\n\nPROMPT_ONLY_OVERRIDE\n",
        )
        .unwrap();
        let def = resolve_product_role("oracle", tmp.path(), None).expect("oracle");
        assert!(
            def.prompt_body
                .as_deref()
                .is_some_and(|b| b.contains("PROMPT_ONLY_OVERRIDE")),
            "prompts/agents override without agents/"
        );
        assert_eq!(def.name, "grok-build-oracle");
    }
}
