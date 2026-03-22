#!/bin/bash
set -euo pipefail

cd "$(dirname "$0")"

IMPLEMENT_PROMPT="$(cat .claude/commands/implement.md)"
REVIEW_PROMPT="$(cat .claude/commands/review.md)"

docker compose -f docker-compose.codex.yml run --rm -T codex   exec   --dangerously-bypass-approvals-and-sandbox   -C /workspace   "$IMPLEMENT_PROMPT"

docker compose -f docker-compose.codex.yml run --rm -T codex   exec   review   --dangerously-bypass-approvals-and-sandbox   "$REVIEW_PROMPT"
