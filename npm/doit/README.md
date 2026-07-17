# @dathtd119/doit

Prebuilt **doit** CLI (coding-agent harness). This package installs the native binary for your platform.

```sh
npm install -g @dathtd119/doit
doit --version
```

## Other install paths

| Method | Command |
|--------|---------|
| **npm** (this package) | `npm i -g @dathtd119/doit` |
| **cargo-binstall** | `cargo binstall --git https://github.com/dathtd119/doit.git doit` |
| **cargo from git** | `cargo install --git https://github.com/dathtd119/doit.git --package doit --locked` |
| **GitHub Release** | https://github.com/dathtd119/doit/releases |

Not published to crates.io. Product version tracks the repo-root `VERSION` file.

## Requirements

- Node.js ≥ 20 (for the npm trampoline only; the CLI itself is a native binary)
- Optional deps must be enabled (do not use `--no-optional`)

## Layout

- Meta package: `@dathtd119/doit` (bin trampoline + postinstall)
- Platform packages: `@dathtd119/doit-<os>-<arch>` (brotli-compressed binary)

Source: [github.com/dathtd119/doit](https://github.com/dathtd119/doit)
