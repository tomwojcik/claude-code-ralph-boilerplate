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
  echo "=== Iteration $i of $1 ==="
  echo

  result=$(claude --permission-mode acceptEdits -p "@PRD.md @progress.txt \
    1. Find the highest-priority incomplete task from PRD and implement it.
    2. Run tests and type checks.
    3. Commit the changes.
    4. Append the completed task to progress.txt.
    ONLY WORK ON A SINGLE TASK.
    If all tasks are complete, output <promise>COMPLETE</promise>.")

  echo "$result"
  echo

  if [[ "$result" == *"<promise>COMPLETE</promise>"* ]]; then
    echo "All tasks complete!"
    exit 0
  fi
done

echo "Completed $1 iteration(s)."
