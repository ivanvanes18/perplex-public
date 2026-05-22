# perplex

OpenClaw skill for Perplexity Sonar web search.

Package contents:
- `SKILL.md`
- `scripts/perplex_search.sh`
- `prompts/*.prompt.md`

## Setup

Export your API key before running the helper script:

```bash
export PERPLEXITY_API_KEY="..."
```

Optional:

```bash
export PERPLEXITY_MODEL="sonar"
```

You can also place these variables in a local `.env` file in the repository root. Do not commit `.env`.

## Usage

```bash
./scripts/perplex_search.sh "latest OpenClaw release"
./scripts/perplex_search.sh "deep research topic" sonar-pro
```

No secrets are included in this repository.
