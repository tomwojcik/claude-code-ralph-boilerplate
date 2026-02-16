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

  result=$(claude --permission-mode acceptEdits -p "@PRD.md @progress.txt

RULES FOR THIS NON-INTERACTIVE SESSION:
- You are running in a NON-INTERACTIVE automated loop. There is NO human to answer questions.
- NEVER use AskUserQuestion. NEVER ask the user anything. NEVER prompt for input.
- NEVER ask which approach to use. Always pick the simplest/recommended/default option.
- When you have a design choice, pick the simplest option that matches CLAUDE.md architecture decisions.
- When you run into something that can't be implemented due to ambiguity or just lack of information, update the PRD item with BLOCKED prefix.
- NEVER work on BLOCKED tasks, skip them entirely

TASK:
1. Read progress.txt to see what is already done.
2. Find the highest-priority incomplete task in the PRD, that's not BLOCKED.
3. Implement it fully (write code + tests where applicable).
4. Run tests
5. Run type checks
6. If both pass, commit the changes with a descriptive commit message.
7. Append the completed task to progress.txt and commit that too.

ONLY WORK ON A SINGLE TASK. Do not start a second task.
If all tasks are complete, output <promise>COMPLETE</promise>.")

  echo "$result"
  echo

  if [[ "$result" == *"<promise>COMPLETE</promise>"* ]]; then
    echo "All tasks complete!"
    exit 0
  fi
done

echo "Completed $1 iteration(s)."
