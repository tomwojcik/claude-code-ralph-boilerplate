# Ralph - Claude Code Agentic Workflow

Ralph is a simple bash-based agentic workflow for [Claude Code](https://github.com/anthropics/claude-code). It runs Claude in a loop, allowing it to autonomously work through a task list defined in your PRD.

Based on the [Ralph Wiggum Technique](https://ghuntley.com/ralph/) by [Geoffrey Huntley](https://ghuntley.com/).

## How It Works

```
┌─────────────────────────────────────────────────────────┐
│                    ralph.sh loop                        │
│                                                         │
│   ┌──────────┐     ┌──────────┐     ┌──────────┐       │
│   │ Read PRD │ ──► │ Implement│ ──► │  Commit  │       │
│   │ & progress│     │   Task   │     │ & Update │       │
│   └──────────┘     └──────────┘     └──────────┘       │
│         ▲                                   │           │
│         └───────────────────────────────────┘           │
│                    (repeat N times)                     │
└─────────────────────────────────────────────────────────┘
```

1. Claude reads `PRD.md` to find the highest-priority incomplete task
2. Implements the task (writes code, runs tests)
3. Commits changes and updates `progress.txt`
4. Repeats for the specified number of iterations

## Prerequisites

- [Claude Code](https://github.com/anthropics/claude-code) installed and configured
- Anthropic API key set up (via `claude` CLI or environment variable)

## Quick Start

```bash
# Setup in current directory (default)
curl -fsSL https://raw.githubusercontent.com/tomwojcik/claude-code-ralph-boilerplate/main/setup-ralph.sh | bash

# Or create a new project directory
curl -fsSL https://raw.githubusercontent.com/tomwojcik/claude-code-ralph-boilerplate/main/setup-ralph.sh | bash -s -- my-project
```

This creates:

```
my-project/
├── PRD.md          # Your product requirements with task list
├── progress.txt    # Tracks completed tasks
└── ralph.sh        # The agentic loop script
```

## Usage

1. **Edit your PRD.md** with your actual tasks:

```markdown
## To Do
- Implement footer with placeholders for ToS and PP
```

2. **Run Ralph:**

```bash
cd my-project
./ralph.sh 5    # Run 5 iterations
```

Claude will work through tasks one at a time until all are complete or iterations run out.

## How Ralph Communicates Completion

When all tasks are done, Claude outputs `<promise>COMPLETE</promise>` and the script exits. This marker is checked after each iteration.

## Files Explained

| File | Purpose |
|------|---------|
| `PRD.md` | Your task list. Claude reads this to find work. |
| `progress.txt` | Log of completed tasks. Claude appends here. |
| `ralph.sh` | The loop that runs Claude repeatedly. |

## Customization

### Modify the prompt

Edit `ralph.sh` to change what Claude does each iteration:

```bash
result=$(claude --permission-mode acceptEdits -p "@PRD.md @progress.txt \
    Your custom instructions here...")
```

### Add more context files

Reference additional files with `@filename`:

```bash
result=$(claude --permission-mode acceptEdits -p "@PRD.md @progress.txt @ARCHITECTURE.md \
    ...")
```

### Change permission mode

- `acceptEdits` - Auto-approve file edits (default)
- `bypassPermissions` - Skip all permission prompts
- `default` - Ask for approval on each action

## Tips

- **Start small**: Test with 1-2 iterations first
- **Be specific**: Clear tasks in PRD.md lead to better results
- **Check progress**: Review `progress.txt` and git commits between runs
- **Iterate**: Refine your PRD based on what Claude produces

## License

MIT
