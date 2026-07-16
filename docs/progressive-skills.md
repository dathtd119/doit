# Progressive skill presentation (L4) — M1 start

**Status:** M1 **policy start** (F-M1-SKILL / VAL-M1-SKILL-001 / M1-S01).  
**Deepen:** M2 (M2-S02 / VAL-M2-SKILL-001) — progressive default product-wide; firehose opt-in only.  
**Limitation:** [limitations.md § L4](./limitations.md#l4--progressive-skill--mcp-catalog)  
**Patch path:** [patch-matrix.md § L4](./patch-matrix.md#l4--progressive-skill--mcp-catalog)  
**Product config:** [`do-harness/config.skills.yaml`](../do-harness/config.skills.yaml)

## Intent

Stock grok discovers skills from many roots (product `.do/`, `.agents/`, `.claude/`, `.cursor/`, user home, custom `paths`) and can inject a **large skill listing** into the system / user-message surface. That is a **firehose** relative to pi-ness dynamic mode (`skill_search` / `skill_load` + compact intents).

**do** does **not** invent a second skill runtime in M1. We:

1. **Document** a progressive presentation policy (this file).  
2. **Reduce dump vs stock default** via do-harness agent + config surfaces (see Evidence).  
3. Keep MCP progressive via stock `search_tool` / `use_tool` (no parallel MCP client).  
4. Defer BM25 `skill_search` / `skill_load` product parity to **M2** (optional crate on skill prompt builder only if extension fails).

## Stock grok seams (fork evidence)

| Surface | Path / mechanism | Effect |
|---------|------------------|--------|
| Agent `discoverSkills` | `AgentDefinition.discover_skills` (`xai-grok-agent` config) | Default **true**: list + seed discovery. **false**: empty skill list, no CWD discovery seed |
| Agent `skills` | Frontmatter `skills: [name, …]` | Explicit preload / inject only those skills |
| `[skills] ignore` | `~/.config/do/config.toml` (and SkillsConfig) | Path prefixes **hidden** entirely from discovery |
| `[skills] disabled` | same | Named skills stay listed but **out of prompt + invocation** |
| `[skills] paths` | same | Extra scan roots (can increase firehose — use sparingly) |
| Compat vendor skills | `[compat.claude]` / `[compat.cursor]` `skills` | Turn off vendor trees when not needed |
| Skill listing | `prompt/skills.rs` + `SkillDiscoveryReminder` | Listing + mid-session reminders (prefer reminders over full dump) |
| MCP | `search_tool` / `use_tool` | Progressive tool discovery — keep this pattern |

User guide: `crates/codegen/xai-grok-pager/docs/user-guide/08-skills.md`.

## Product policy (M1)

### Presentation modes

| Mode | When | Behavior |
|------|------|----------|
| **progressive** (product default direction) | Clarify/scout roles; preferred product stance | Suppress bulk discovery; load skills **on demand** (explicit `skills:` list, slash skill, or human request). Prefer `SkillDiscoveryReminder` over always-on full listing when discovery is on. |
| **curated** | Worker / orchestrator when a short allowlist is known | `discoverSkills: true` **or** false + explicit `skills: […]` allowlist only |
| **firehose** (stock-like) | Debug / operator opt-in only | Full discovery from all roots; document as **opt-in**, not product default long-term (M2 hardens) |

M1 does **not** yet force progressive for every role. It **starts** the policy and ships **at least one reduced surface** vs stock default.

### Role defaults (do roster)

| Role | `discoverSkills` (M1) | Rationale |
|------|----------------------|-----------|
| **intake** | **false** | Clarify-only; skill dump wastes context before Intent Pack exists |
| **explorer** | **false** | Read-only scout; maps via read/grep/lsp, not skill catalog |
| **oracle** | **false** | Analysis; load a skill only if the question names one |
| **orchestrator** | **true** (curated direction) | May need workflow skills; prefer short allowlists in M2 |
| **worker** | **true** (curated direction) | Implementation often needs project skills; still use ignore lists |

Stock default for agents is `discoverSkills: true`. Setting **false** on intake / explorer / oracle is the primary **reduced-firehose** product surface for VAL-M1-SKILL-001.

### Config / ignore lists (operator)

Product overlay (policy, not a second runtime registry):

- [`do-harness/config.skills.yaml`](../do-harness/config.skills.yaml) — presentation mode, role table, recommended TOML ignore/disabled fragments.

Merge recommended `[skills]` / compat cells into stock `~/.config/do/config.toml` (or project `.do/config.toml` when used). **Do not** invent a competing skills engine.

Recommended ignore themes (tune per machine):

- WIP / scratch skill trees under team paths  
- Duplicate vendor trees when using only `.grok` skills  
- Noisy third-party skill packs not used in this repo  

Recommended disabled (keep listed, block auto-invoke): experimental skill names.

### Reminder tuning

- Prefer **SkillDiscoveryReminder** (mid-session, path-triggered) over stuffing every skill description into always-on system text.  
- Soft budget discipline: L4 listing should stay lean — see [prompt-system.md](./prompt-system.md) L4 row.  
- Do **not** paste full skill bodies into L0/L1; use the skill tool / explicit load when needed.

### MCP

Keep stock progressive MCP:

1. `search_tool` for discovery  
2. `use_tool` for invocation  

No do-harness MCP client. Product policy: treat MCP like skills — search then use, not dump every tool schema every turn when stock already progressive.

## Evidence (VAL-M1-SKILL-001)

| Check | Location |
|-------|----------|
| Policy documented | This file + prompt-system L4 pointer |
| Config surface | `do-harness/config.skills.yaml` |
| Reduced dump vs stock | `discoverSkills: false` on intake, explorer, oracle under `do-harness/agents/` |
| Verify | `bash do-harness/scripts/verify-progressive-skills.sh` → exit 0 |

## What M1 does **not** do

- BM25 `skill_search` / `skill_load` product tools (M2 direction)  
- Crate patch to skill prompt builder (only if extension fails)  
- Forcing progressive for worker/orchestrator (M2 may tighten)  
- Dual skill registry outside stock discovery + agent frontmatter  

## Related

- [prompt-system.md](./prompt-system.md) — L4 layer map  
- [capability-map.md](./capability-map.md) — skill-catalog row  
- [backlog-m1-m3.md](./backlog-m1-m3.md) — M1-S01 / M2-S02  
- [do-harness/README.md](../do-harness/README.md) — enablement  
- pi-ness (read-only): `~/code/pi-ness/docs/skill-catalog.md`
