#!/bin/sh
# index.sh — print site/index.html, one card per row of pages.tsv, grouped.
set -eu
ROOT=$(cd "$(dirname "$0")/.." && pwd)

cat <<'HEAD'
<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<meta name="robots" content="noindex">
<title>Atlases</title>
<style>
  :root { --bg:#f6f7f9; --paper:#fff; --ink:#15181d; --muted:#5d6673; --line:#dde1e7; --accent:#2346c8; }
  @media (prefers-color-scheme: dark) { :root { --bg:#111317; --paper:#1a1d23; --ink:#e8eaee; --muted:#9aa3af; --line:#2b3039; --accent:#8ea6ff; } }
  * { box-sizing: border-box; }
  body { margin:0; background:var(--bg); color:var(--ink); font:17px/1.55 system-ui, -apple-system, "Segoe UI", sans-serif; }
  main { max-width: 860px; margin: 0 auto; padding: 40px 20px 60px; }
  h1 { font-size: 34px; line-height: 1.1; margin: 0 0 6px; }
  .lede { color: var(--muted); margin: 0 0 28px; }
  h2 { font-size: 13px; text-transform: uppercase; letter-spacing: .12em; color: var(--muted); margin: 30px 0 10px; }
  .grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(240px, 1fr)); gap: 12px; }
  a.card { display:block; background:var(--paper); border:1px solid var(--line); border-radius:12px; padding:14px 16px; color:inherit; text-decoration:none; }
  a.card:hover, a.card:focus-visible { border-color: var(--accent); outline: none; }
  .card b { display:block; font-size:17px; margin-bottom:4px; color: var(--accent); }
  .card span { color: var(--muted); font-size: 15px; }
  footer { margin-top: 40px; color: var(--muted); font-size: 13px; }
</style>
</head>
<body>
<main>
<h1>Atlases</h1>
<p class="lede">Learning atlases and study guides. Each opens as its own page and works on a phone.</p>
HEAD

tail -n +2 "$ROOT/pages.tsv" | awk -F'\t' '
  function esc(s) { gsub(/&/, "\\&amp;", s); gsub(/</, "\\&lt;", s); gsub(/>/, "\\&gt;", s); gsub(/"/, "\\&quot;", s); return s }
  $1 == "" { next }
  $2 != group { if (group != "") print "</div>"; group = $2; print "<h2>" esc(group) "</h2>"; print "<div class=\"grid\">" }
  { print "<a class=\"card\" href=\"" esc($1) "/\"><b>" esc($3) "</b><span>" esc($4) "</span></a>" }
  END { if (group != "") print "</div>" }
'

cat <<'TAIL'
<footer>Built from pages.tsv. Answers you save in a quiz stay in this browser only.</footer>
</main>
</body>
</html>
TAIL
