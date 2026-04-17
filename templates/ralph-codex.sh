#!/bin/bash
set -euo pipefail

export HOST_UID=$(id -u)
export HOST_GID=$(id -g)

if [ -z "${1:-}" ]; then
  echo "Usage: $0 <iterations>"
  echo "  iterations: number of task cycles to run"
  exit 1
fi

cd "$(dirname "$0")"

echo "Starting Ralph Codex workflow with $1 iteration(s)..."
echo

for ((i=1; i<=$1; i++)); do
  if ! grep -q '^\- \[ \]' PRD.md; then
    echo "No remaining empty tasks in PRD.md — stopping early."
    break
  fi

  echo "=== Iteration $i of $1 === $(date '+%Y-%m-%d %H:%M:%S') ==="
  echo

  IMPLEMENT_PROMPT="$(cat .claude/commands/implement.md)"
  IMPLEMENT_PROMPT+=$'

RULES FOR THIS NON-INTERACTIVE SESSION:
'
  IMPLEMENT_PROMPT+=$'- You are running in a NON-INTERACTIVE automated loop. There is NO human to answer questions.
'
  IMPLEMENT_PROMPT+=$'- Never ask the user questions. Always pick the simplest/default option.
'
  IMPLEMENT_PROMPT+=$'- When blocked by ambiguity, update the PRD item with BLOCKED prefix and skip it.
'
  IMPLEMENT_PROMPT+=$'- NEVER work on BLOCKED tasks.
'
  IMPLEMENT_PROMPT+=$'- If all tasks are complete, output <promise>COMPLETE</promise>.
'

  docker compose -f docker-compose.codex.yml run --rm -T codex     exec     --dangerously-bypass-approvals-and-sandbox     -C /workspace     "$IMPLEMENT_PROMPT"

  echo
  echo "=== Review for iteration $i === $(date '+%Y-%m-%d %H:%M:%S') ==="
  echo

  REVIEW_PROMPT="$(cat .claude/commands/review.md)"
  REVIEW_PROMPT+=$'

RULES FOR THIS NON-INTERACTIVE SESSION:
'
  REVIEW_PROMPT+=$'- You are running in a NON-INTERACTIVE automated loop. There is NO human to answer questions.
'
  REVIEW_PROMPT+=$'- Never ask the user questions. Always pick the simplest/default option.
'

  docker compose -f docker-compose.codex.yml run --rm -T codex     exec     review     --dangerously-bypass-approvals-and-sandbox     "$REVIEW_PROMPT"

  echo
  push_ok=false
  for attempt in 1 2 3; do
    if git push 2>/dev/null; then
      push_ok=true
      break
    fi
    echo "  git push attempt $attempt failed, retrying in 10s..."
    sleep 10
  done
  if [ "$push_ok" = false ]; then
    echo "  WARNING: git push failed after 3 attempts — skipping, will retry next iteration"
  fi
done

echo "Completed $1 iteration(s)."
