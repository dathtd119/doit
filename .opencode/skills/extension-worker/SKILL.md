---
name: extension-worker
description: Create do-harness agents and guided PreToolUse hooks following grok discovery conventions; verify end-to-end discovery with real binary or scripted path check.
---

# extension-worker

You own the **M0 proof extension path**: intake agent profile + guided PreToolUse hook + discovery verification. Prefer **extension seams** over crate patches.

## Constraints (hard)

- Working directory: `/home/datht/code/do`
- **NEVER modify** `/home/datht/code/pi-ness` or `/home/datht/code/grok-build`
- Prefer `do-harness/` under do; link/copy onto `~/.grok` or project `.grok/` discovery paths as needed for M0
- Config root for M0: **`~/.grok` conventions**
- No OpenTUI port; no mock-only “works” for VAL-EXT-003
- Document enablement and verification commands in `do-harness/README.md`

## Work Procedure

1. **Read context** — `mission.md`, `architecture.md`, `AGENTS.md`, VAL-EXT-* assertions. Scout grok user-guide / agent/hook discovery in the **forked** tree under do (e.g. `.grok/agents`, hooks PreToolUse).
2. **F-EXT-001 — Intake agent**  
   - Create `do-harness/agents/` (or install into `.grok/agents/`) with an **intake** (or equivalent) agent profile matching grok agent discovery conventions (frontmatter/format as stock expects).  
   - Keep profile minimal: role = intake/default session control proof, not full M1 roster.
3. **F-EXT-002 — Guided PreToolUse hook**  
   - Create `do-harness/hooks/` (or `.grok/hooks`) with at least one PreToolUse-style hook.  
   - Behavior: on a **dangerous pattern** (e.g. destructive rm/pkill-style), **deny or guide** with a clear **“Do this instead”** message (guided-block style).  
   - Document how to enable the hook.
4. **F-EXT-003 — End-to-end discovery**  
   - Prefer (a) headless/CLI listing on the forked binary showing the agent/hook, or (b) a **scripted** verification command that exits 0 confirming files sit on the **real discovery path** used by grok.  
   - Mocks alone are **insufficient**.  
   - Document commands in `do-harness/README.md`.
5. **Self-check** — VAL-EXT-001/002/003 file layout + verification evidence.
6. **Handoff** — Include exact verification commands and observed output snippets.

## Acceptance criteria

| Feature | Done when |
|---------|-----------|
| F-EXT-001 | Intake agent profile exists under do-harness or `.grok/agents` and matches discovery conventions |
| F-EXT-002 | Guided PreToolUse hook exists; enablement documented |
| F-EXT-003 | Real discovery evidence (binary list or scripted path check exit 0); `do-harness/README.md` documents commands |

## Example Handoff JSON

```json
{
  "successState": "success",
  "returnToOrchestrator": true,
  "validatorsPassed": true,
  "handoff": {
    "salientSummary": "Installed intake agent and guided PreToolUse hook; discovery script exited 0.",
    "whatWasImplemented": "do-harness agents/hooks + README verification commands.",
    "whatWasLeftUndone": "Full role roster (M1).",
    "verification": {
      "commandsRun": [
        {
          "command": "test -f /home/datht/code/do/do-harness/agents/intake.md",
          "exitCode": 0,
          "observation": "intake profile present"
        },
        {
          "command": "bash /home/datht/code/do/do-harness/scripts/verify-discovery.sh",
          "exitCode": 0,
          "observation": "discovery path check passed"
        }
      ]
    },
    "tests": { "added": [], "coverage": "scripted discovery verification" },
    "discoveredIssues": [],
    "skillFeedback": {
      "followedProcedure": true,
      "deviations": [],
      "suggestedChanges": []
    }
  }
}
```

## When to Return to Orchestrator

- Grok discovery conventions cannot be determined from the forked tree after thorough search
- Proof requires crate patches beyond a documented one-line hook registration (escalate; document in patch-matrix)
- Binary not buildable (depends on F-FORK-002) and no scripted discovery path is viable
- Would need to change auth, TUI, or kill host processes to “prove” discovery
