#!/bin/sh
# guard-test.sh — the guard must go red on each planted leak and green on a
# clean file. A guard that cannot fail is worse than none.
set -u
ROOT=$(cd "$(dirname "$0")/.." && pwd)
T=$(mktemp -d "${TMPDIR:-/tmp}/atlases-test.XXXXXX")
trap 'rm -rf "$T"' EXIT
fails=0

mkdir -p "$T/roster"
printf 'name = "Acmebank"\n' > "$T/roster/acme.toml"
printf 'name = "GO3"\n' > "$T/roster/go3.toml"

expect() {  # expect <exit code> <label> <file content>
  printf '%s\n' "$3" > "$T/page.html"
  ATLASES_ROSTER="$T/roster" sh "$ROOT/bin/guard.sh" "$T/page.html" > "$T/out" 2>&1
  rc=$?
  if [ "$rc" -eq "$1" ]; then echo "PASS $2"; else echo "FAIL $2 (exit $rc, wanted $1)"; cat "$T/out"; fails=$((fails + 1)); fi
}

expect 0 "clean page"              "<p>Cloud storage tiers and the CAP theorem.</p>"
expect 1 "absolute home path"      "<p>see /Users/someone/Deliverables/x.html</p>"
expect 1 "claude config path"      "<p>~/.claude/skills/x</p>"
expect 1 "email address"           "<p>write to person@example.com</p>"
expect 1 "GTM container id"        "<code>GTM-ABC1234</code>"
expect 1 "GA4 measurement id"      "<code>G-ABCDEFGH12</code>"
expect 1 "client name"             "<p>Acmebank tracking audit</p>"
expect 0 "client name inside word" "<p>Acmebanking is not a hit</p>"
expect 1 "short client name"       "<p>the GO3 campaign</p>"
expect 0 "short name in lowercase" "<p>go3 is not a hit</p>"

# The roster must be read: an empty roster dir refuses to run blind.
mkdir -p "$T/empty"
printf '<p>x</p>\n' > "$T/page.html"
ATLASES_ROSTER="$T/empty" sh "$ROOT/bin/guard.sh" "$T/page.html" > /dev/null 2>&1
[ $? -eq 2 ] && echo "PASS empty roster refuses" || { echo "FAIL empty roster ran"; fails=$((fails + 1)); }

echo "failures: $fails"
[ "$fails" -eq 0 ]
