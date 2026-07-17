# Prompt placeholders (operator catalog)

**Audience:** harness authors — not model-facing text.

Product templates use simple `${name}`. Stock crate templates still use MiniJinja
`${{ name }}` / `${%- if %}`. Expand simple `${name}` first, then MiniJinja for tools.

Unrecognized `${name}` stays literal.

---

## Stack (name ↔ file)

| Placeholder | File | Content |
|-------------|------|---------|
| `${l0_general}` | `l0-general.md` | Stock general (safety, tools, style) |
| `${l0_kernel}` | `l0-kernel.md` | Product harness rules + gates (once) |
| `${role_body}` | `roles/<stem>.md` | Role-static mission / workflow / style |

Shell that composes them: `l0-system.md`.

```text
l0-system.md
  ├── ${l0_general}   ← l0-general.md
  ├── ${l0_kernel}    ← l0-kernel.md
  ├── Identity        ← ${agent} ${role} ${policy}   (no model)
  ├── ${role_body}    ← roles/<stem>.md
  └── Session         ← ${date} ${cwd} ${os} ${shell}
```

Underscore in the placeholder (`l0_general`) matches the stem; filenames keep
hyphens (`l0-general.md`) for readability on disk.

---

## Identity / session scalars

| `${}` | Where | Meaning |
|-------|-------|---------|
| `${agent}` | Identity | Product name (default `do`) |
| `${role}` | Identity | Active role stem |
| `${policy}` | Identity | Permission label (`ask`, `plan`, `yolo`, …) |
| `${date}` | Session | Session date |
| `${cwd}` | Session | Working directory |
| `${os}` / `${shell}` | Session | Host facts |

**Not in Identity:** `${model}` — model pin is config/chrome, not prompt identity.

**Shipped (Phase B):** `${toolsList}` expands to concise bullets for the active, model-callable **built-in** tools after role allowlist/denylist, file toolset, and media gates. Source is the finalized toolset (`FinalizedToolset::format_tools_list_markdown`), not a hand-written TOML list. Optional `${toolGuidelines}` is still deferred (not implemented).

Skills are **not** embedded in these files — progressive skill inject is a separate system path. Full tool contracts remain in `tools[]`; prompt lists are summaries only.

Stock MiniJinja (inside `l0-general.md` only): `${{ tools.by_kind.read }}`, etc.

### `${toolsList}` (live)

| Detail | Behavior |
|--------|----------|
| Format | `- \`name\` — first line of description` (≤120 chars); sorted by client name |
| Source | Finalized built-ins only (excludes MCP `server__tool` names) |
| Expand paths | MiniJinja `${{ toolsList }}` via placeholders; product simple `${toolsList}` post-render in `ToolBridge::render_prompt` |
| Rebuild | Same agent rebuild lifecycle as role switch / tool filter (pre-message only for primary role Tab) |
| Contracts | Full schemas stay in API `tools[]`; prompt list is navigation only |

Product identity block (`ensure_product_role_identity`) embeds `## Available tools` + `${toolsList}` so Extend assembly shows the list without waiting for full L0 expander.

---

## Layer ownership (no duplication)

| Layer | Owns | Does not own |
|-------|------|--------------|
| **l0-general** | Stock safety, tool-calling, output style | Product gates, role mission |
| **l0-kernel** | Harness rules, gates, continuum priority, role-lock | Role-specific workflow |
| **Identity** | Who is speaking (agent/role/policy); product roles also inject `## Available tools` + `${toolsList}` | Model id |
| **role_body** | Identity sentence, can/cannot, workflow, style, DO/DON'T | Gate catalog, skills dump, model id |
| **Session** | date / cwd / os / shell | Everything else |

Identity path: general (stock product label) + Identity block + role Mission.
Roles **may** open with `You are **{Role}** — …` and negative identity; they do
**not** re-list gates or embed skill catalogs.

---

## Authoring rules

1. Model-facing files: harness behavior only — no layer diagrams or wire notes.
2. Operator docs (this file, `README.md`, `docs/prompt-system.md`): assembly detail.
3. Config (tools, model, color, policy floors): TOML `[roles.*]`, never prompt YAML.
4. Prompts SoT: `do-harness/prompts/` — not synced to `~/.config/doit`.
