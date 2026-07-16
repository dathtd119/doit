# Generated smoke commands

Extracted from README.md by `scripts/generate-docs.sh`.

```sh
# do
cargo install dotslash                       # once; enables bin/protoc
cargo check -p xai-grok-pager-bin            # smoke (VAL-FORK-002)
cargo run -p xai-grok-pager-bin              # build + launch TUI
cargo build -p xai-grok-pager-bin --release  # release binary
# optional: pip install pre-commit && pre-commit install
```
