# Generated smoke commands

Extracted from README.md by `scripts/generate-docs.sh`.

```sh
# do
  cargo install dotslash
  # or: prebuilt packages — https://dotslash-cli.com/docs/installation/
cargo install dotslash                       # once; enables bin/protoc
cargo check -p doit                          # smoke (product package)
cargo run -p doit                            # build + launch TUI
cargo build -p doit --release                # release binary
# optional: pip install pre-commit && pre-commit install
```
