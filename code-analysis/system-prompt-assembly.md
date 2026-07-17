# Code Analysis: System prompt assembly (stock grok → do roles)

## Related Files

| Path | Role |
|------|------|
| `crates/codegen/xai-grok-agent/templates/prompt.md` | **Primary base system template** (source of truth) |
| `crates/codegen/xai-grok-agent/src/prompt/template.rs` | XOR decrypt → `base_template()` |
| `crates/codegen/xai-grok-agent/src/prompt/context.rs` | `PromptContext::render` — Extend / Full |
| `crates/codegen/xai-grok-agent/src/builder.rs` | Builds `Agent` + first render of system string |
| `crates/codegen/xai-grok-agent/src/config.rs` | `AgentDefinition`, `PromptMode`, `prompt_body` |
| `crates/codegen/xai-grok-agent/src/discovery.rs` | Load `agents/*.md` → frontmatter + body |
| `crates/codegen/xai-grok-shell/.../session_mode.rs` | Role Tab → re-render system head from new def |
| `crates/codegen/xai-grok-shell/.../session_setup.rs` | AGENTS.md as **conversation** item, not system |
| `crates/codegen/xai-grok-agent/src/prompt/user_message.rs` | First-user-message prefix (`user_info`, git) |
| `do-harness/agents/*.md` | Product role: frontmatter + **body appended** today |
| `do-harness/prompts/l0-general.md` | `${l0_general}` — product copy of stock `prompt.md`; wire phase 02 |
| `do-harness/prompts/l0-system.md` | Stack shell: `${l0_general}` + `${l0_kernel}` + Identity + `${role_body}` + Session |
| `do-harness/prompts/l0-kernel.md` | `${l0_kernel}` harness rules + gates — not in render until phase 02 |
| `do-harness/prompts/placeholders.md` | Operator `${}` catalog |
| `do-harness/prompts/roles/*.md` | `${role_body}` mission/workflow — twin of agent body until wire |

## Summary

Stock **do/grok** does **not** assemble a pi-ness stack of “GENERAL + role body as base.”  
The **core system prompt is always** (for product agents with `promptMode: extend`):

1. **Base template** from `templates/prompt.md` via `base_template()`  
2. **Plus** `AgentDefinition.prompt_body` (markdown body of the agent file) appended with `\n\n`

Everything else (AGENTS.md, skills listing, user_info, git status) lands as **user / project_instructions / reminders**, not as a rewrite of that core system string.

`do-harness/prompts/l0-kernel.md` and inventing a “thin L0” that **replaces** `prompt.md` would be **making up a second kernel** unless we deliberately wire it. That is the wrong default. Product work must **start from the real base** and only **extend** (or carefully inject into known slots).

## Details — real assembly path

### 1. Core base (always, unless Full / Custom / Codex)

```text
AgentBuilder::build
  → PromptContext { prompt_mode, prompt_body, system_prompt: None, … }
  → PromptContext::render(tool_bridge)
```

**Extend** (`context.rs`):

```text
base = match system_prompt {
  None     → base_template()     // decrypt templates/prompt.md
  Custom(s)→ s
  Codex    → apply_patch_template()
}
rendered_base = tool_bridge.render_prompt(base, placeholders)  // MiniJinja + tools.by_kind.*
if prompt_body:
  rendered_base += "\n\n" + render_prompt(prompt_body)
return rendered_base   // this IS agent.system_prompt()
```

**Full**:

```text
system = render_prompt(prompt_body only)   // DROPS base_template entirely
```

Product roster agents today use **`promptMode: extend`** → base is **always** stock `prompt.md`.

### 2. What `templates/prompt.md` actually contains (~4.6 KiB source)

Not a mega “do kernel.” Sections:

| Block | Content |
|-------|---------|
| Identity | `You are ${{ system_prompt_label }} released by xAI…` (default label `"Grok"`) |
| `<action_safety>` | Confirm before irreversible / shared-state actions |
| `<tool_calling>` | Prefer specialized tools over bash; resolve `${{ tools.by_kind.* }}` |
| `<background_tasks>` | Optional if monitor tool present |
| `<output_efficiency>` | Prose quality |
| `<formatting>` | GFM |
| `<user_guide>` | Interactive only — points at `~/.grok/docs/user-guide/` |

**Not in base:** role mission, AGENTS.md, tool allowlists, guided-gate catalog, continuum rules, product identity “do”.

Placeholders available (`PromptContext::placeholders`):  
`system_prompt_label`, `is_non_interactive`, `os_name`, `shell_path`, `working_directory`, `current_date`, `memory_*`, `role_instructions`, `persona_instructions`.

**Critical:** primary `prompt.md` does **not** reference `${{ role_instructions }}`.  
That placeholder is only used in **`subagent_prompt.md`**. For primary session, role text must come from **`prompt_body` append** (or a future template change / Custom override).

### 3. Where product role text goes today

```text
do-harness/agents/intake.md
  --- frontmatter (tools, model, color, promptMode: extend) ---
  # Role: intake …          ← becomes prompt_body
```

Discovery: `AgentDefinition::from_file` → `prompt_body = markdown after ---`.  
On Tab role cycle (`session_mode.rs`):

```text
def = discovery::by_name_in_cwd(role)
new_prompt = agent.render_prompt_for_definition(def)
→ rewrite ConversationItem::System content
```

So **role switch only swaps the appended body** (and tools/model via definition). Base `prompt.md` stays unless mode is Full.

`prompts/roles/*.md` and `l0-kernel.md` are **not** loaded by `PromptContext::render`. They are product authoring / docs unless something else injects them (nothing in the render path does).

### 4. What is *not* the system prompt (easy to confuse)

| Surface | Where it goes |
|---------|----------------|
| AGENTS.md | `agents_md_user_reminder` → conversation **project_instructions** item (`session_setup`) |
| `<user_info>` / git | First **user** message prefix (`user_message.rs` / shell `build_user_message_prefix`) |
| Skills catalog | User-side announcements / skill injection into body when preloaded |
| Tool **schemas** | Separate API tool list — not prose in system (floors filter which tools exist) |
| Guided gates | Hook **deny reasons** at tool time, not always-on system text |
| Compact after compaction | Fixed short string `COMPACT_SYSTEM_PROMPT` in `template.rs` |

### 5. Modes that *would* throw away the core (avoid for product)

| Mode | Effect |
|------|--------|
| `promptMode: full` | System = **only** agent body — **no** stock `prompt.md` |
| `TemplateOverride::Custom` | Replaces base template string |
| Codex agent | Different base (`apply_patch_prompt.md`) |

Using Full for “role-as-system” **replaces** the core system prompt. That is not “get the core out and extend” — it is a full rewrite. **Do not default product roles to Full** unless we intentionally fork the entire system string and re-include stock content.

### 6. Diagram (truth)

```text
                    ┌─────────────────────────────────────┐
                    │  templates/prompt.md  (CORE BASE)   │
                    │  identity + action_safety + tools…  │
                    └─────────────────┬───────────────────┘
                                      │ MiniJinja + tools.by_kind
                                      ▼
                    ┌─────────────────────────────────────┐
                    │  SYSTEM message (API)               │
                    │  base + "\n\n" + agent prompt_body  │
                    │  (product role mission lives here)  │
                    └─────────────────┬───────────────────┘
                                      │
         ┌────────────────────────────┼────────────────────────────┐
         ▼                            ▼                            ▼
  project_instructions         user prefix                  tool schemas
  (AGENTS.md)                  (user_info, git)             (allow/deny floors)
```

### 7. Implication for plan 260716-2010 (correct the mental model)

| Earlier plan language | Actual stock behavior | Correct product approach |
|----------------------|----------------------|---------------------------|
| “Thin L0 kernel replaces mega default” | Default is already a **short** stock `prompt.md` | **Keep** `base_template()`; do not invent parallel L0 as system |
| “Role body is primary system” | Role is **append** under Extend | Keep Extend; put mission in `prompt_body` (from prompts or agent body) |
| `l0-kernel.md` in assembly | **Not wired** | Either inject **into** append (after base) or leave as docs — never **replace** base |
| `promptMode: full` for roles | Drops core | **Reject** as default for product roster |
| pi-ness GENERAL + ROLE | Different product | Map: GENERAL ≈ stock `prompt.md`; ROLE ≈ `prompt_body` |

**Correct role-as-system for do:**

```text
system = render(prompt.md) + "\n\n" + render(role_body)
tools  = from [roles.*] TOML (schema filter — separate from prompt text)
```

Not:

```text
system = invent(l0) + invent(role)     # wrong
system = role_only (Full)              # drops core
```

### 8. Input / output example (conceptual)

**Input:** agent `intake` with `promptMode: extend`, body = “You are intake…”

**Output system string shape:**

```text
You are Grok released by xAI. You are an interactive CLI tool...
<action_safety>...</action_safety>
...
<user_guide>...</user_guide>

You are intake for do — clarify intent...
## Mission
...
```

**Input:** same agent with `promptMode: full`  
**Output:** only the intake body — **no** action_safety / tool_calling from stock. Bad for product default.

## Potential Issues

1. **Docs lie:** `prompt-system.md` / plan text that treat `l0-kernel.md` as always-on system are aspirational, not runtime.
2. **Twin bodies:** agent.md body vs `prompts/roles/*.md` — only agent body hits system today; prompts can drift.
3. **Full mode temptation:** “role kernel” wording pushes Full → silent loss of stock safety/tool conventions.
4. **Primary has no `role_instructions` slot** in `prompt.md` — subagent template does; primary must use append (or patch template).
5. **Label:** identity is still “Grok” unless `system_prompt_label` / `[agent] system_prompt_label` overrides — product “do” identity is not in base unless configured.

## Recommendations

1. **Seal assembly rule in plan:** core system = stock `base_template()` only; product content = **append** under Extend (or explicit template placeholder later). Never Full for default roster.
2. **Phase 02 rewrite:** “role-as-system” = **swap `prompt_body`** on Tab (already partly true) + optional single append of product L0 **after** base if needed — not replace base.
3. **Source of role body:** prefer one body (prompts tree or agent) that becomes `prompt_body`; TOML owns tools/model/color only.
4. **Do not** treat `l0-kernel.md` as live system until a deliberate inject is implemented and tested against a dumped `system_prompt()`.
5. **Verify with dump:** after any change, assert rendered system **starts with** “You are … released by xAI” (or configured label) and **contains** role mission; never only role mission.

## Open questions (for product, not invent)

1. Should product L0 (guided gates / continuum) be **second append** after role, or stay only in AGENTS.md / hooks?
2. Override `system_prompt_label` to “do” / “Grok” for branding?
3. Patch `prompt.md` to include `${{ role_instructions }}` (subagent-style) vs keep append-only?

---

**Status:** analysis only — no assembly code change in this writeup.  
**Evidence date:** 2026-07-16, tree `/home/datht/code/doit`.
