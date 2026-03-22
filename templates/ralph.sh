#!/bin/bash
set -e

if [ -z "$1" ]; then
  echo "Usage: $0 <iterations>"
  echo "  iterations: number of task cycles to run"
  exit 1
fi

# Ensure we're in the project directory
cd "$(dirname "$0")"

echo "Starting Ralph workflow with $1 iteration(s)..."
echo

for ((i=1; i<=$1; i++)); do
  if ! grep -q '^\- \[ \]' PRD.md; then
    echo "No remaining empty tasks in PRD.md — stopping early."
    break
  fi

  echo "=== Iteration $i of $1 === $(date '+%Y-%m-%d %H:%M:%S') ==="
  echo

  echo "
RULES FOR THIS NON-INTERACTIVE SESSION:
- You are running in a NON-INTERACTIVE automated loop. There is NO human to answer questions.
- NEVER use AskUserQuestion. Always pick the simplest/default option.
- When blocked by ambiguity, update the PRD item with BLOCKED prefix and skip it.
- NEVER work on BLOCKED tasks.
- If all tasks are complete, output <promise>COMPLETE</promise>.

/implement" | docker compose -f docker-compose.claude.yml run --rm -T claude
  echo
  echo "=== Review for iteration $i === $(date '+%Y-%m-%d %H:%M:%S') ==="
  echo
  echo "
RULES FOR THIS NON-INTERACTIVE SESSION:
- You are running in a NON-INTERACTIVE automated loop. There is NO human to answer questions.
- NEVER use AskUserQuestion. Always pick the simplest/default option.

/review" | docker compose -f docker-compose.claude.yml run --rm -T claude
  echo
  # Retry git push up to 3 times; skip gracefully if GitHub is unreachable
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
