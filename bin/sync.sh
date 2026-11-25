#!/bin/sh
# sync.sh — copy every page listed in pages.tsv from the local deliverables
# folder into docs/<slug>/index.html, refuse the lot if the guard finds
# anything, then rebuild docs/index.html. Nothing outside pages.tsv is copied.
set -eu

ROOT=$(cd "$(dirname "$0")/.." && pwd)
SRC=${ATLASES_SRC:-$HOME/Deliverables}
STAGE=$(mktemp -d "${TMPDIR:-/tmp}/atlases-stage.XXXXXX")
trap 'rm -rf "$STAGE"' EXIT

tail -n +2 "$ROOT/pages.tsv" | while IFS='	' read -r slug group title blurb source; do
  [ -n "$slug" ] || continue
  [ -f "$SRC/$source" ] || { echo "sync: missing source $SRC/$source" >&2; exit 1; }
  mkdir -p "$STAGE/$slug"
  cp "$SRC/$source" "$STAGE/$slug/index.html"
done

# The guard reads the staged copies, so a refused file never reaches docs/.
sh "$ROOT/bin/guard.sh" "$STAGE"/*/index.html

sh "$ROOT/bin/index.sh" > "$STAGE/index.html"
rm -rf "$ROOT/docs"
mkdir -p "$ROOT/docs"
cp -R "$STAGE"/. "$ROOT/docs/"
: > "$ROOT/docs/.nojekyll"
echo "sync: $(ls -d "$ROOT"/docs/*/ | wc -l | tr -d ' ') page(s) in docs/"
