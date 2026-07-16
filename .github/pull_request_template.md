## Summary
<!-- What changed and why? -->

## Testing done
- [ ] `cargo check -p xai-grok-pager-bin`
- [ ] Targeted tests: `cargo test -p <crate>`
- [ ] Pre-commit / quality scripts (if touching agent docs or large files)

## Placement
- [ ] do-harness (agents/hooks/skills/prompts/YAML)
- [ ] Config / plugin
- [ ] Tool pack
- [ ] Surgical crate patch (documented in `docs/patch-matrix.md`)

## Agent notes
- Role switch lock: no mid-session role hop after first user message
- Prefer extension-before-deep-fork
- No secrets in this PR (use env keys / `.env.example`)

## Risk / rollback
<!-- How do we reverse this if needed? -->
