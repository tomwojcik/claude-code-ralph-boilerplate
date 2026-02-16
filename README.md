# Ralph - Claude Code Agentic Workflow

Ralph is a dual-mode bash-based agentic workflow for [Claude Code](https://github.com/anthropics/claude-code). It provides both an autonomous loop (`ralph.sh`) and an interactive human-in-the-loop mode (`run.sh`) for working through tasks defined in your PRD.

Based on the [Ralph Wiggum Technique](https://ghuntley.com/ralph/) by [Geoffrey Huntley](https://ghuntley.com/).

## How It Works

### Autonomous Mode (`ralph.sh`)

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

- No human input required. Claude picks the simplest/default approach for every decision.
- Tasks that can't be completed due to ambiguity are marked **BLOCKED** and skipped.
- Permissions are controlled via `.claude/settings.json` (no `--permission-mode` flag).

### Interactive Mode (`run.sh`)

```
┌────────────────────┐     ┌────────────────────┐
│  claude "/run"     │ ──► │  claude "/review"   │
│  (implement task)  │     │  (code review + push)│
└────────────────────┘     └─────────────────────┘
```

- Human-in-the-loop. Claude asks you when something is unclear.
- `/run` is not just a simple task runner — it orchestrates a full plugin-powered workflow:
  - **superpowers:brainstorming** — designs the approach before writing code
  - **superpowers:writing-plans** — breaks multi-step tasks into plans
  - **superpowers:test-driven-development** — writes tests first
  - **superpowers:systematic-debugging** — investigates before guessing
  - **superpowers:verification-before-completion** — runs tests + Playwright MCP visual checks
  - **Playwright MCP** — navigates to your app, takes snapshots, clicks through UI
  - **Schema-first rule** — defines TypeScript interfaces before spawning subagents
- Review step runs with `--model opus` for thorough code review.

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
project/
├── PRD.md                      # Your product requirements with task list
├── progress.txt                # Tracks completed tasks
├── ralph.sh                    # Autonomous (no human input)
├── run.sh                      # Interactive (human-in-the-loop)
└── .claude/
    ├── settings.json           # Permission defaults
    └── commands/
        ├── run.md              # /run slash command
        └── review.md           # /review slash command
```

## Usage

1. **Edit your PRD.md** with your actual tasks:

```markdown
## To Do
- Implement footer with placeholders for ToS and PP
```

2. **Pick a mode:**

```bash
# Autonomous: run 5 iterations with no human input
./ralph.sh 5

# Interactive: implement one task, then review and push
./run.sh
```

## BLOCKED Tasks

In autonomous mode, when Claude encounters a task that can't be implemented due to ambiguity or missing information, it marks the task as **BLOCKED** in the PRD and moves on. BLOCKED tasks are always skipped.

Review BLOCKED tasks manually, clarify the requirements, remove the BLOCKED prefix, and run again.

## Completion Detection

When all tasks are done, Claude outputs `<promise>COMPLETE</promise>` and `ralph.sh` exits early. This marker is checked after each iteration.

## Files

| File | Purpose |
|------|---------|
| `PRD.md` | Your task list. Claude reads this to find work. |
| `progress.txt` | Log of completed tasks. Claude appends here. |
| `ralph.sh` | Autonomous loop - runs Claude N times with no interaction. |
| `run.sh` | Interactive mode - runs `/run` then `/review` with human input. |
| `.claude/settings.json` | Pre-approved and denied shell commands. |
| `.claude/commands/run.md` | `/run` slash command - implements the next task. |
| `.claude/commands/review.md` | `/review` slash command - reviews unpushed commits and pushes. |

## Customization

### Settings & Permissions

Edit `.claude/settings.json` to pre-approve commands for your stack:

```json
{
  "permissions": {
    "allow": [
      "Bash(cargo build:*)",
      "Bash(docker compose:*)",
      "WebFetch(domain:docs.your-framework.dev)"
    ],
    "deny": [
      "Bash(rm -rf:*)"
    ]
  }
}
```

The defaults include git, npm/npx/node, and common shell tools. Add your framework-specific commands as needed.

### Modify the prompt

Edit `ralph.sh` to change what Claude does each autonomous iteration, or edit `.claude/commands/run.md` and `.claude/commands/review.md` to customize the interactive slash commands.

### Add more context files

Reference additional files with `@filename` in `ralph.sh` or the slash commands:

```
@PRD.md @progress.txt @ARCHITECTURE.md
```

## Tips

- **Start small**: Test with 1-2 iterations of `ralph.sh` first
- **Be specific**: Clear tasks in PRD.md lead to better results
- **Check progress**: Review `progress.txt` and git commits between runs
- **Use interactive mode for complex tasks**: When tasks need human judgment, use `run.sh`
- **Review BLOCKED tasks**: They indicate where your PRD needs more detail

## License

MIT
