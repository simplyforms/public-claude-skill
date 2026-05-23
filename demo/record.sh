#!/usr/bin/env bash
# Record the SimplyForms Claude Code demo and convert it to docs/demo.gif.
#
# Requires: asciinema (https://asciinema.org) and agg (https://github.com/asciinema/agg)
#   macOS:    brew install asciinema agg
#   Linux:    pipx install asciinema  &&  cargo install --git https://github.com/asciinema/agg
#
# Usage (run from the repo root):
#   ./demo/record.sh
#
# What it does:
#   1. Copies demo/contact-form.html into a fresh /tmp working dir.
#   2. Starts asciinema in that dir — you do the demo (see demo/STORYBOARD.md),
#      then `exit` the sub-shell.
#   3. Converts the cast to docs/demo.gif via agg (sharp text, small file).
#   4. Prints the resulting size + a preview command.

set -euo pipefail

# Resolve repo root from this script's location so the script works
# regardless of cwd.
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$HERE/.." && pwd)"
SRC="$HERE/contact-form.html"
OUT_DIR="$ROOT/docs"
OUT_GIF="$OUT_DIR/demo.gif"
CAST="$(mktemp -t sf-demo.XXXXXX.cast)"
WORK="$(mktemp -d -t sf-demo-XXXXXX)"

bail() { echo "ERROR: $*" >&2; exit 1; }

command -v asciinema >/dev/null || bail "asciinema not found — brew install asciinema"
command -v agg       >/dev/null || bail "agg not found — brew install agg"
[[ -f "$SRC" ]] || bail "demo source missing: $SRC"

mkdir -p "$OUT_DIR"
cp "$SRC" "$WORK/contact-form.html"

cat <<EOF

  SimplyForms Claude Code — demo recording

  Working dir: $WORK
  Cast file:   $CAST
  Output GIF:  $OUT_GIF

  Read demo/STORYBOARD.md for the three-act script.
  When you're done with the demo, type 'exit' in the sub-shell.

EOF

read -r -p "Press ENTER to start recording…"

# Idle compression keeps the GIF tight without losing pacing.
# 120x32 is a comfortable 16:9-ish terminal aspect; resize your window
# to match before recording for crisp output.
( cd "$WORK" && asciinema rec \
    --idle-time-limit=2 \
    --cols 120 --rows 32 \
    "$CAST" )

echo
echo "Converting cast → GIF (this can take 10–30s)…"
# --speed 1.4 = real-time recording feels a bit snappier without losing
# legibility. --font-size 16 = legible at default GitHub display width.
agg --speed 1.4 --font-size 16 "$CAST" "$OUT_GIF"

size=$(du -h "$OUT_GIF" | cut -f1)
echo
echo "✓ $OUT_GIF ($size)"
echo "  Preview: open '$OUT_GIF'"
echo
echo "If the GIF is > 2 MB, re-run with a smaller font / faster speed:"
echo "  agg --speed 1.7 --font-size 14 '$CAST' '$OUT_GIF'"

# Leave the working dir + cast around in case you want to re-convert.
echo "  (cast kept at $CAST; working dir $WORK — safe to delete)"
