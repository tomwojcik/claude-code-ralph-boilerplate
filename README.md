# Ralph - Claude Code Agentic Workflow

Ralph is a dual-mode bash-based agentic workflow for [Claude Code](https://github.com/anthropics/claude-code). It provides both an autonomous loop (`ralph.sh`) and an interactive human-in-the-loop mode (`run.sh`) for working through tasks defined in your PRD. All agents run inside Docker containers for isolation.

Based on the [Ralph Wiggum Technique](https://ghuntley.com/ralph/) by [Geoffrey Huntley](https://ghuntley.com/).

> **Warning**: These scripts run AI agents with `--dangerously-skip-permissions`. This means agents can execute arbitrary code, modify files, and run commands without asking for approval. Use at your own risk.

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
- Stops early when no unchecked tasks remain in the PRD.

### Interactive Mode (`run.sh`)

```
┌────────────────────┐     ┌────────────────────┐
│  claude "/implement"│ ──► │  claude "/review"   │
│  (implement task)  │     │  (code review + push)│
└────────────────────┘     └─────────────────────┘
```

- Human-in-the-loop. Claude asks you when something is unclear.
- `/implement` orchestrates a plugin-powered workflow:
  - **superpowers:brainstorming** — designs the approach before writing code
  - **superpowers:writing-plans** — breaks multi-step tasks into plans
  - **superpowers:test-driven-development** — writes tests first
  - **superpowers:systematic-debugging** — investigates before guessing
  - **superpowers:verification-before-completion** — runs tests

### Codex Mode (optional)

If you opted into the Codex setup, you also get containerized [OpenAI Codex](https://github.com/openai/codex) equivalents:

```bash
# Autonomous: run 5 iterations via Codex in Docker
./ralph-codex.sh 5

# Single iteration via Codex in Docker
./run-codex.sh
```

## Prerequisites

- [Docker](https://docs.docker.com/get-docker/) installed and running
- [Claude Code](https://github.com/anthropics/claude-code) installed and configured (`~/.claude` directory)
- (Optional) [OpenAI Codex](https://github.com/openai/codex) configured (`~/.codex` directory) for Codex mode

### Claude Token Setup

The Docker container needs an explicit OAuth token. To set it up:

1. Run `claude setup-token` and follow the prompts
2. Create a `.env.claude` file in your project root:
   ```
   CLAUDE_CODE_OAUTH_TOKEN=your-token-here
   ```

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
├── PRD.md                          # Your product requirements with task list
├── progress.txt                    # Tracks completed tasks
├── ralph.sh                        # Autonomous loop (no human input)
├── run.sh                          # Interactive (human-in-the-loop)
├── Dockerfile.agent                # Multi-stage Docker image (Claude + Codex)
├── docker-compose.claude.yml       # Docker Compose for Claude agent
├── .claude/
│   ├── settings.json               # Permission defaults
│   └── commands/
│       ├── implement.md            # /implement slash command
│       └── review.md               # /review slash command
│
│  (if Codex setup accepted)
├── docker-compose.codex.yml        # Docker Compose for Codex agent
├── ralph-codex.sh                  # Autonomous loop via Codex
└── run-codex.sh                    # Single iteration via Codex
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
| `ralph.sh` | Autonomous loop — runs Claude N times with no interaction. |
| `run.sh` | Interactive mode — runs `/implement` then `/review` with human input. |
| `Dockerfile.agent` | Multi-stage Docker image with Claude and Codex targets. |
| `docker-compose.claude.yml` | Docker Compose config for the Claude agent container. |
| `docker-compose.codex.yml` | Docker Compose config for the Codex agent container (optional). |
| `ralph-codex.sh` | Autonomous loop via Codex in Docker (optional). |
| `run-codex.sh` | Single iteration via Codex in Docker (optional). |
| `.claude/settings.json` | Pre-approved and denied shell commands. |
| `.claude/commands/implement.md` | `/implement` slash command — implements the next task. |
| `.claude/commands/review.md` | `/review` slash command — reviews unpushed commits. |

## Customization

### Modify the prompt

Edit `ralph.sh` to change what Claude does each autonomous iteration, or edit `.claude/commands/implement.md` and `.claude/commands/review.md` to customize the interactive slash commands.

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
