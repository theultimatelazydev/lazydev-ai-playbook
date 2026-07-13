#!/usr/bin/env bash
# Validates the marketplace + plugin manifests and skill layout.
# Dependency-light: bash + jq only. Exits non-zero on any problem so it can
# gate CI. Run from anywhere — it resolves the repo root itself.
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$root"

fail() { echo "❌ $*" >&2; exit 1; }
ok()   { echo "✓ $*"; }

command -v jq >/dev/null || fail "jq is required but not installed"

# 1. Every JSON file parses.
while IFS= read -r -d '' f; do
  jq empty "$f" 2>/dev/null || fail "invalid JSON: $f"
done < <(find . -name '*.json' -not -path './.git/*' -not -path './node_modules/*' -print0)
ok "all JSON files parse"

# 2. marketplace.json has the required shape.
mkt=".claude-plugin/marketplace.json"
[ -f "$mkt" ] || fail "missing $mkt"
jq -e '.name and (.plugins | type == "array" and length > 0)' "$mkt" >/dev/null \
  || fail "$mkt must have a name and a non-empty plugins[]"
ok "marketplace.json has name + plugins[]"

# 3. Every listed plugin resolves to a real, well-formed plugin.json.
count=$(jq '.plugins | length' "$mkt")
for i in $(seq 0 $((count - 1))); do
  src=$(jq -r ".plugins[$i].source" "$mkt")
  name=$(jq -r ".plugins[$i].name" "$mkt")
  pj="$src/.claude-plugin/plugin.json"
  [ -f "$pj" ] || fail "plugin '$name': $pj not found (bad source '$src')"
  jq -e '.name and .version and .description' "$pj" >/dev/null \
    || fail "$pj must have name, version, and description"
  ok "plugin '$name' → $pj (name/version/description present)"

  # 4. Every skill directory under the plugin carries a SKILL.md.
  if [ -d "$src/skills" ]; then
    shopt -s nullglob
    for d in "$src"/skills/*/; do
      [ -f "${d}SKILL.md" ] || fail "skill '${d}' has no SKILL.md"
    done
    ok "every skill dir under '$name' has SKILL.md"
  fi
done

echo "✅ plugin validation passed"
