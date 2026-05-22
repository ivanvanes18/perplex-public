---
name: perplex
description: Default web search via Perplexity Sonar API. Use for web search, fact checks, research, prices, news, and source-backed answers.
metadata:
  clawdbot:
    emoji: 🔎
    command: /perplex
---

# Perplex — Default Web Search

Use Perplexity Sonar API for fast web-grounded search with citations.

## Quick Usage

```bash
export PERPLEXITY_API_KEY="..."
./scripts/perplex_search.sh "your search query"
./scripts/perplex_search.sh "deep research topic" sonar-pro
```

The helper script also reads a local `.env` file from the repository root. Do not commit `.env`.

## Direct API Shape

```bash
curl -s https://api.perplexity.ai/chat/completions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $PERPLEXITY_API_KEY" \
  -d '{
    "model": "sonar",
    "messages": [{"role": "user", "content": "YOUR QUERY"}],
    "temperature": 0.2,
    "search_sources": ["social", "web"]
  }'
```

Always include:

```json
"search_sources": ["social", "web"]
```

## Models

| Model | Use case |
|-------|----------|
| `sonar` | Default fast web search |
| `sonar-pro` | Deeper research, more sources |
| `sonar-reasoning` | Multi-step reasoning |
| `sonar-reasoning-pro` | Complex research where quality matters more than cost |

Default: `sonar`.

## Prompt Templates

- `prompts/quick-search.prompt.md`
- `prompts/deep-research.prompt.md`
- `prompts/compare-options.prompt.md`
- `prompts/fact-check.prompt.md`

## Response Contract

Return:

```yaml
answer: concise grounded answer
sources: cited URLs
confirmed: what is directly supported by sources
uncertain: what still needs checking
```

## Rules

- Prefer the API/helper script over browser relay.
- Include citations in user-facing research answers.
- Separate source-backed facts from inference.
- Do not expose API keys or local `.env` content.
- Use `sonar-pro` only when the user asks for deep research or the topic has meaningful risk.
