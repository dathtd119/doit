# Progressive skill / MCP catalog (L4) — M2 advanced

**Status:** M2 **product default** (F-M2-SKILL / VAL-M2-SKILL-001 / M2-S02).  
**Prior:** M1 start (F-M1-SKILL / VAL-M1-SKILL-001 / M1-S01).  
**Limitation:** [limitations.md § L4](./limitations.md#l4--progressive-skill--mcp-catalog)  
**Patch path:** [patch-matrix.md § L4](./patch-matrix.md#l4--progressive-skill--mcp-catalog)  
**Product config:** [`do-harness/config.skills.yaml`](../do-harness/config.skills.yaml)

## Intent

Stock grok discovers skills from many roots (product `.doit/`, `.agents/`, `.claude/`, `.cursor/`, user home, custom `paths`) and can inject a **large skill listing** into the system / user-message surface. That is a **firehose** relative to pi-ness progressive retrieval (`skill_search` / `skill_load` + compact intents).

**do** does **not** invent a second skill runtime or a parallel MCP client. Product policy:

1. **Default** skill surface is **progressive** or **heavily curated** for every product roster role.  
2. **Firehose** (full multi-root discovery) is **opt-in only** for debug/operators.  
3. **MCP** stays progressive via stock **`search_tool`** then **`use_tool`** (no reinvent).  
4. Prefer mid-session **SkillDiscoveryReminder** and explicit loads over always-on full skill body dumps.

BM25 `skill_search` / `skill_load` product parity with pi-ness remains a **future** extension path (optional crate on skill prompt builder only if stock seams stay insufficient). M2 seals the progressive/curated **default** without that crate.

## Stock grok seams (fork evidence)

| Surface | Path / mechanism | Effect |
|---------|------------------|--------|
| Agent `discoverSkills` | `AgentDefinition.discover_skills` (`xai-grok-agent` config) | Default **true**: list + seed discovery. **false**: empty skill list, no CWD discovery seed |
| Agent `skills` | Frontmatter `skills: [name, …]` | Explicit preload / inject **only** those skills (curated allowlist) |
| `[skills] ignore` | `~/.config/doit/config.toml` (and SkillsConfig) | Path prefixes **hidden** entirely from discovery |
| `[skills] disabled` | same | Named skills stay listed but **out of prompt + invocation** |
| `[skills] paths` | same | Extra scan roots (increases firehose — use sparingly) |
| Compat vendor skills | `[compat.claude]` / `[compat.cursor]` `skills` | Turn off vendor trees when not needed |
| Skill listing | `prompt/skills.rs` + `SkillDiscoveryReminder` | Listing + mid-session reminders (prefer reminders over full dump) |
| MCP | `search_tool` / `use_tool` | Progressive tool discovery — keep this pattern |

User guide: `crates/codegen/xai-grok-pager/docs/user-guide/08-skills.md`.

## Product policy (M2)

### Presentation modes

| Mode | Product stance | Behavior |
|------|----------------|----------|
| **progressive** | **Default** for clarify / scout / analysis roles | `discoverSkills: false`. No bulk CWD skill dump. Load skills **on demand** (explicit frontmatter `skills:` if named, slash skill, skill tool, or human request). Prefer `SkillDiscoveryReminder` when discovery is temporarily enabled. |
| **curated** | **Default** for coordinate / implement roles | `discoverSkills: false` **plus** a short optional `skills: […]` allowlist of known project/workflow skills. Empty allowlist = progressive (no preload). Operators grow the list deliberately — not “discover everything”. |
| **firehose** | **Opt-in only** | `discoverSkills: true` (and often broad `paths` / vendor skills). Full multi-root scan + listing seed. **Not** the product long-term default. Use for debugging skill install trees or packing demos. |

### Role defaults (do roster — M2)

| Role | Mode | `discoverSkills` | `skills` allowlist | Rationale |
|------|------|------------------|--------------------|-----------|
| **intake** | progressive | **false** | `[]` | Clarify-only; skill dump wastes context before Intent Pack exists |
| **explorer** | progressive | **false** | `[]` | Read-only scout; maps via read/grep/lsp (+ MCP search/use), not skill catalog |
| **oracle** | progressive | **false** | `[]` | Analysis; load a skill only if the question names one |
| **orchestrator** | curated | **false** | `[]` (grow on purpose) | Coordinate workflows; add named workflow skills when known, never full firehose |
| **worker** | curated | **false** | `[]` (grow on purpose) | Implement with explicit project skills; avoid multi-root dump into every turn |

Stock default remains `discoverSkills: true`. Product roster **overrides all five** to false (progressive or curated). That is the M2 reduced-firehose surface vs M0 stock and vs M1 partial (M1 left orchestrator/worker open).

### Config / ignore lists (operator)

Product overlay (policy, not a second runtime registry):

- [`do-harness/config.skills.yaml`](../do-harness/config.skills.yaml) — presentation mode, role table, allowlists, recommended TOML ignore/disabled fragments, MCP policy.

Merge recommended `[skills]` / compat cells into stock `~/.config/doit/config.toml` (or project `.doit/config.toml` when used). **Do not** invent a competing skills engine.

Recommended ignore themes (tune per machine):

- WIP / scratch skill trees under team paths  
- Duplicate vendor trees when using only product `.do` / harness skills  
- Noisy third-party skill packs not used in this repo  

Recommended disabled (keep listed, block auto-invoke): experimental skill names.

### Reminder tuning

- Prefer **SkillDiscoveryReminder** (mid-session, path-triggered) over stuffing every skill description into always-on system text.  
- Soft budget discipline: L4 listing should stay lean — see [prompt-system.md](./prompt-system.md) L4 row.  
- Do **not** paste full skill bodies into L0/L1; use the skill tool / explicit load when needed.

### MCP (progressive; no reinvent)

Keep stock progressive MCP only:

| Step | Stock tool | Use |
|------|------------|-----|
| 1. Discover | **`search_tool`** | Find matching MCP tools by intent / keywords |
| 2. Invoke | **`use_tool`** | Call a chosen tool with arguments |

**Do not** invent a do-harness MCP client, dump every MCP schema every turn, or replace these with a parallel catalog tool.

Product roster **explorer** and **oracle** expose `search_tool` / `use_tool` in their tool floors for external docs / graph-ish MCP. Other roles may receive them via parent spawn or future floor expansion; the **policy** is always search-then-use.

Parallel to skills: treat MCP as progressive discovery, not firehose catalog inject.

### Firehose opt-in (retained for debug)

When an operator **explicitly** needs stock-like dump:

1. Set the target agent frontmatter `discoverSkills: true` under `do-harness/agents/<role>.md` (or a local override agent).  
2. Optionally expand `[skills] paths` and re-enable vendor skill trees in `~/.config/doit/config.toml`.  
3. Re-install / symlink agents into `~/.config/doit/agents` or project `.doit/agents` per [do-harness/README.md](../do-harness/README.md).  
4. Revert before product demos or shared machines — firehose is **not** the M2 product default.

Record in `config.skills.yaml`: `presentation.firehose_mode: opt_in`.

## Evidence (VAL-M2-SKILL-001)

| Check | Location |
|-------|----------|
| Advanced policy documented | This file (M2 progressive/curated default + firehose opt-in + MCP search/use) |
| Config surface | `do-harness/config.skills.yaml` (`default_mode: progressive`, `firehose_mode: opt_in`, all five roles, MCP policy) |
| Default not firehose | All five roster agents: `discoverSkills: false` (curated allowlists empty until operators expand) |
| MCP progressive | Policy + explorer/oracle floors use `search_tool` / `use_tool`; no custom MCP client |
| Verify | `bash do-harness/scripts/verify-progressive-skills.sh` → exit 0 (`VAL-M2-SKILL-001: PASS`) |

### M1 residual (still held)

| Check | Location |
|-------|----------|
| Policy start | This file history / M1 needles still present in doc |
| Reduced clarify roles | intake / explorer / oracle remain progressive |

## What M2 does **not** do

- BM25 `skill_search` / `skill_load` product tools (future optional extension / crate)  
- Crate patch to skill prompt builder (only if progressive default proves insufficient)  
- A second skill or MCP runtime outside stock discovery + agent frontmatter  
- Full-repo skill pack installation automation  

## Related

- [prompt-system.md](./prompt-system.md) — L4 layer map  
- [capability-map.md](./capability-map.md) — skill-catalog / mcp-client rows  
- [backlog-m1-m3.md](./backlog-m1-m3.md) — M1-S01 / M2-S02  
- [do-harness/README.md](../do-harness/README.md) — enablement + verify  
- pi-ness (read-only): `~/code/pi-ness/docs/skill-catalog.md`
