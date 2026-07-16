# Dev container

Open this repo in VS Code / Codespaces with **Dev Containers: Reopen in Container**.

Includes:

- Rust (stable) + rustfmt/clippy
- Node 22 (for jscpd quality tooling)
- GitHub CLI
- postCreate validation of agent smoke docs

Local smoke after attach:

```sh
cargo check -p doit
```

Optional: `pre-commit install` once Python pre-commit is available.
