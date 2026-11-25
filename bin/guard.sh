#!/bin/sh
# guard.sh FILE... — refuse any file that would leak private or work data onto
# this public site. Exit 0 clean, 1 on any hit, 2 on usage error.
#
# Generic patterns run everywhere, CI included. Client names run only where the
# private roster exists (ATLASES_ROSTER, default ~/port/azimuth/roster): the
# list itself is confidential, so it is read at run time and never committed.
set -u

[ "$#" -gt 0 ] || { echo "usage: guard.sh FILE..." >&2; exit 2; }

# Extended regexes, case-insensitive. Each line is one rule.
GENERIC='/Users/[A-Za-z]
/home/[a-z]
\.claude/
[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.(com|lt|lv|ee|org|net|io|eu)\b
\bmbd\.lt\b
\bGTM-[A-Z0-9]{5,}\b
\bG-[A-Z0-9]{8,}\b
\bAW-[0-9]{6,}\b
app\.clickup\.com
\bharbor\b'

ROSTER=${ATLASES_ROSTER:-$HOME/port/azimuth/roster}
names=""
if [ -d "$ROSTER" ]; then
  # Whole-word, case-sensitive: short names such as GO3 must not match prose.
  names=$(sed -n 's/^name = "\(.*\)"$/\1/p' "$ROSTER"/*.toml 2>/dev/null | sort -u)
  [ -n "$names" ] || { echo "guard: roster at $ROSTER has no names; refusing to run blind" >&2; exit 2; }
else
  echo "guard: no client roster at $ROSTER, generic patterns only" >&2
fi

hits=0
for f in "$@"; do
  [ -f "$f" ] || { echo "guard: not a file: $f" >&2; exit 2; }
  printf '%s\n' "$GENERIC" | while IFS= read -r re; do
    [ -n "$re" ] || continue
    n=$(grep -c -i -E -- "$re" "$f" 2>/dev/null || true)
    [ "${n:-0}" -gt 0 ] && echo "HIT  $f  rule: $re  ($n lines)"
  done
  if [ -n "$names" ]; then
    printf '%s\n' "$names" | while IFS= read -r nm; do
      [ -n "$nm" ] || continue
      n=$(grep -c -w -F -- "$nm" "$f" 2>/dev/null || true)
      [ "${n:-0}" -gt 0 ] && echo "HIT  $f  rule: client name  ($n lines)"
    done
  fi
done > "${TMPDIR:-/tmp}/atlases-guard.$$"

if [ -s "${TMPDIR:-/tmp}/atlases-guard.$$" ]; then
  cat "${TMPDIR:-/tmp}/atlases-guard.$$"
  hits=1
fi
rm -f "${TMPDIR:-/tmp}/atlases-guard.$$"
[ "$hits" -eq 0 ] && echo "guard: clean ($# file(s))"
exit "$hits"
