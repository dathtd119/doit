# Patterns to adopt from grok-build

Reusable behaviors **do should build on**, not reimplement. Evidence from the forked tree.

## 1. Plan mode

| Pattern | Evidence | Adopt how |
|---------|----------|-----------|
| Enter/exit as a **paired** mode | `enter_plan_mode`, `exit_plan_mode` under `implementations/grok_build/`; Claude aliases keep them paired (`claude_alias.rs`) | Use tools; do not invent a second plan mode |
| Tool hints in prompts | `EnterPlanMode` output hints default to `ask_user_question` + `exit_plan_mode` (`types/output.rs` tests) | Keep guided next-steps in product prompts |
| Plan file on disk | Session plan probing in tools output types | Map pi-ness workspace continuum onto session plan layout (L9) |

## 2. `update_goal` + classifier

| Pattern | Evidence | Adopt how |
|---------|----------|-----------|
| Model-driven goal progress | `implementations/grok_build/update_goal/` | Use `update_goal` for continuum; do not dual-write goals |
| Completed/blocked ack flow | Goal update handle + session actor; deferred completed; “do not re-call until verdict” reminders | Teach agents via prompts + reminders |
| Telemetry / events | File-utils / sampling-types events around goal completion | Observability without a parallel goal bus |

**Gap (L5):** no single continuation coordinator — compose plan + goal + todo carefully in product policy until M2.

## 3. Subagent resolution

| Pattern | Evidence | Adopt how |
|---------|----------|-----------|
| Precedence | `xai-grok-subagent-resolution`: **override > role > persona > parent** | Role→model assignment must respect this chain |
| Pure resolution crate | No session/transport deps — reusable | Keep policy in resolution + agent defs; avoid shell-only forks |
| Resume identity | Type/persona checks; model soft-ignored on resume | Document resume semantics for workers |

Spawn surface: `task` tool (`implementations/grok_build/task/`).

## 4. Hashline edits

| Pattern | Evidence | Adopt how |
|---------|----------|-----------|
| Hashline namespace | `ToolNamespace::GrokBuildHashline`, `implementations/grok_build_hashline/` | Prefer hashline for precise multi-hunk edits when enabled |
| Anchor / scheme / mutate | `anchor.rs`, `scheme.rs`, `mutate.rs`, `edit/` | Product default policy is M3 backlog — document first, then enable |

## 5. Skill discovery reminders

| Pattern | Evidence | Adopt how |
|---------|----------|-----------|
| Cross-cutting reminders | `Reminder` trait + `SkillDiscoveryReminder` in tools registry | Progressive catalog (L4): reminders over full dump |
| Skills on SessionContext | `SessionContext.skills: Vec<SkillInfo>` | Install do skills onto discovery paths |
| Bundled examples | `xai-grok-shell/skills/` | Follow same skill layout conventions |

## 6. Permissions + hooks

| Pattern | Evidence | Adopt how |
|---------|----------|-----------|
| PreToolUse gate | `HookEvent::PreToolUse`; telemetry deny outcomes | Guided blocks: name gate + **Do this instead** |
| Permission subsystem | `xai-grok-workspace/src/permission/` (policy, auto_mode, rules, shell_access) | Layer hooks **with** permission rules, not instead of |
| Plan-mode auto allowlist | `auto_mode.rs` references `enter_plan_mode` etc. | Align dangerous-tool policy with plan mode |

## 7. Tool registry composition

| Pattern | Evidence | Adopt how |
|---------|----------|-----------|
| Tool packs | `register_tool_pack` before first builder | Startup registration only |
| ToolServerConfig | Explicit tool ID lists + behavior_preset | Config-driven toolsets per role/capability |
| Kind-based capability filters | `ToolKind` on `ToolConfig` | Prefer kind filters over ID hardcoding for new tools |
| Version presets | `behavior_preset` / `versions.rs` | Pin behavior for regression safety |

## 8. MCP dispatch

| Pattern | Evidence | Adopt how |
|---------|----------|-----------|
| Discover then call | `search_tool` → `use_tool` | External tools via MCP |
| Mis-route detection | Native tools through `use_tool` → corrective error | Teach models in tool error text (same spirit as guided gates) |

## 9. Scheduler / monitor

| Pattern | Evidence | Adopt how |
|---------|----------|-----------|
| Scheduler tools | `grok_build/scheduler` create/delete/list; parent scheduler handle on SessionContext | Long-running / loop tasks without reinventing timers |
| Monitor tool | `ToolKind::Monitor`, `grok_build/monitor` | Background observation patterns |
| Task survival across toolset swap | Workspace tests: tasks survive `ToolServerConfig` rebuild | Design product toolset swaps carefully |

## 10. ACP

| Pattern | Evidence | Adopt how |
|---------|----------|-----------|
| ACP library linked from pager-bin | `xai-acp-lib` | IDE/client integration via ACP, not a second wire protocol |

## 11. Multi-model (stock)

| Pattern | Evidence | Adopt how |
|---------|----------|-----------|
| Many named models + default | config / models crates; product docs L13 | Keep TOML runtime; YAML assignment overlay for UX |
| Subagent model chain | subagent-resolution crate | Wire do role pins into this chain in M1 |

## Anti-patterns (do not adopt)

- Bare permission denials without gate name + alternative
- Mid-session primary role hops (product rule: lock after first user message)
- Competing model registry at runtime
- Deep TUI fork before hooks/plugins/tool packs fail
- Inventing tools that already exist under GrokBuild / Hashline / MCP

## TODO expand (workers)

- [ ] Sequence diagrams: plan enter → work → exit; goal complete → classifier verdict
- [ ] Example agent frontmatter with model + tools
- [ ] Example PreToolUse hook JSON/config from hooks tests
- [ ] Hashline edit walkthrough with file paths

## See also

- [native-tools.md](./native-tools.md)
- [extension-seams.md](./extension-seams.md)
- [hard-limits.md](./hard-limits.md)
- [../workspace.md](../workspace.md), [../prompt-system.md](../prompt-system.md)
