# Dependency update policy

## Minimum release age

**Rule:** Do not adopt a brand-new crates.io (or GitHub Action) release until it is **at least 7 days old**, unless the update is an emergency security fix.

Rationale: supply-chain delay reduces exposure to compromised fresh releases.

### Enforcement

1. **Dependabot** (`.github/dependabot.yml`) uses `cooldown.default-days: 7` for Cargo and `3` for GitHub Actions so automated PRs wait after upstream publication.
2. **Human / agent PRs** that bump versions must include in the PR body:
   - crates.io publish date (or `cargo info <crate>`) showing age ≥ 7 days, **or**
   - link to a security advisory justifying immediate upgrade.
3. Prefer pin upgrades already present in `Cargo.lock` over floating to the absolute newest.

## Review checklist for dependency PRs

- [ ] Age ≥ 7 days **or** security exception cited
- [ ] `cargo check -p doit` still passes
- [ ] No new network/crypto sinks without review
- [ ] Changelog / release notes of the dependency skimmed for breaking changes
