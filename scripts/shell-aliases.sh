# doit product CLI aliases — source from ~/.bashrc if desired:
#   [ -f "$HOME/.config/doit/shell-aliases.sh" ] && . "$HOME/.config/doit/shell-aliases.sh"
# Repo copy of the same snippet installed under ~/.config/doit/shell-aliases.sh.
#
# Prefer PATH install of `doit` (and external `do` / `do-it`) over aliases.
# bash keyword `do` only applies in `do ... done` compounds; typed command `do` resolves via PATH.

if command -v doit >/dev/null 2>&1; then
  # Optional short mnemonic (bang avoids keyword confusion in some shells)
  alias 'do!'='doit'
fi

# Product: disable media generation tools.
# image_gen / image_edit are env-gated only (GROK_IMAGE_*); not [features].
export GROK_IMAGE_GEN=0
export GROK_IMAGE_EDIT=0
