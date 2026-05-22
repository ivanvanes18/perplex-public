#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

if [[ -f "$REPO_DIR/.env" ]]; then
  set -a
  # shellcheck disable=SC1091
  source "$REPO_DIR/.env"
  set +a
elif [[ -f "/opt/clawd-workspace/.env" ]]; then
  set -a
  # shellcheck disable=SC1091
  source /opt/clawd-workspace/.env
  set +a
fi

if [[ -z "${PERPLEXITY_API_KEY:-}" ]]; then
  echo "ERROR: PERPLEXITY_API_KEY is not set. Export it or create a local .env file." >&2
  exit 1
fi

QUERY="${1:?Usage: perplex_search.sh \"query\" [model]}"
MODEL="${2:-${PERPLEXITY_MODEL:-sonar}}"

python3 - "$QUERY" "$MODEL" <<'PY'
import json, os, sys, urllib.request, urllib.error
query = sys.argv[1]
model = sys.argv[2]
payload = {
    "model": model,
    "messages": [{"role": "user", "content": query}],
    "temperature": 0.2,
    "search_sources": ["social", "web"],
}
req = urllib.request.Request(
    "https://api.perplexity.ai/chat/completions",
    data=json.dumps(payload).encode("utf-8"),
    headers={
        "Content-Type": "application/json",
        "Authorization": f"Bearer {os.environ['PERPLEXITY_API_KEY']}",
    },
    method="POST",
)
try:
    with urllib.request.urlopen(req, timeout=60) as resp:
        data = json.loads(resp.read().decode("utf-8"))
except urllib.error.HTTPError as e:
    print(f"ERROR: HTTP {e.code}: {e.read().decode('utf-8', errors='ignore')}")
    raise SystemExit(1)

if "error" in data:
    print("ERROR:", data["error"])
    raise SystemExit(1)

print(data["choices"][0]["message"]["content"])
print()
for i, citation in enumerate(data.get("citations", []), 1):
    print(f"[{i}] {citation}")

cost = data.get("usage", {}).get("cost", {}).get("total_cost", 0)
print(f"\n--- Cost: ${cost:.4f} | Model: {data.get('model')} ---")
PY
