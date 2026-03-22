#!/bin/bash
set -euo pipefail

# GitHub raw content URL - update this with your username
REPO_RAW_URL="https://raw.githubusercontent.com/tomwojcik/claude-code-ralph-boilerplate/main"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Print functions
info() { echo -e "${BLUE}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}[OK]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }

# Banner
echo -e "${BLUE}"
echo "  ____       _       _     "
echo " |  _ \ __ _| |_ __ | |__  "
echo " | |_) / _\` | | '_ \| '_ \ "
echo " |  _ < (_| | | |_) | | | |"
echo " |_| \_\__,_|_| .__/|_| |_|"
echo "              |_|          "
echo -e "${NC}"
echo "Claude Code Agentic Workflow Setup"
echo "-----------------------------------"
echo
echo -e "${YELLOW}WARNING: These scripts run AI agents with --dangerously-skip-permissions.${NC}"
echo -e "${YELLOW}This means agents can execute arbitrary code, modify files, and run commands${NC}"
echo -e "${YELLOW}without asking for approval. Use at your own risk.${NC}"
echo
read -rp "$(echo -e "${BLUE}[?]${NC}") Do you accept the risk and want to continue? (y/n) " ACCEPT_RISK
echo
if [[ ! "$ACCEPT_RISK" =~ ^[Yy]$ ]]; then
    info "Setup cancelled."
    exit 0
fi

# Project name: use argument or current directory
if [ -z "${1:-}" ]; then
    PROJECT_NAME="$(basename "$(pwd)")"
    info "Setting up Ralph in current directory: $PROJECT_NAME"
else
    PROJECT_NAME="$1"
    # Check if directory already exists
    if [ -d "$PROJECT_NAME" ]; then
        error "Directory '$PROJECT_NAME' already exists. Choose a different name or remove it first."
    fi
    info "Creating project: $PROJECT_NAME"
    mkdir -p "$PROJECT_NAME"
    cd "$PROJECT_NAME"
fi

# Download templates
if [ -f PRD.md ]; then
    warn "PRD.md already exists, skipping"
else
    info "Downloading PRD.md..."
    curl -fsSL "$REPO_RAW_URL/templates/PRD.md" -o PRD.md
    sed -i "s/PROJECT_NAME_PLACEHOLDER/$PROJECT_NAME/g" PRD.md
    success "Created PRD.md"
fi

info "Downloading progress.txt..."
curl -fsSL "$REPO_RAW_URL/templates/progress.txt" -o progress.txt
success "Created progress.txt"

info "Downloading ralph.sh..."
curl -fsSL "$REPO_RAW_URL/templates/ralph.sh" -o ralph.sh
chmod +x ralph.sh
success "Created ralph.sh (executable)"

info "Downloading run.sh..."
curl -fsSL "$REPO_RAW_URL/templates/run.sh" -o run.sh
chmod +x run.sh
success "Created run.sh (executable)"

info "Setting up .claude/commands..."
mkdir -p .claude/commands

if [ -f .claude/commands/implement.md ]; then
    warn ".claude/commands/implement.md already exists, skipping"
else
    curl -fsSL "$REPO_RAW_URL/templates/.claude/commands/implement.md" -o .claude/commands/implement.md
    success "Created .claude/commands/implement.md"
fi

if [ -f .claude/commands/review.md ]; then
    warn ".claude/commands/review.md already exists, skipping"
else
    curl -fsSL "$REPO_RAW_URL/templates/.claude/commands/review.md" -o .claude/commands/review.md
    success "Created .claude/commands/review.md"
fi

# Docker setup (always included)
info "Downloading Dockerfile.agent..."
curl -fsSL "$REPO_RAW_URL/templates/Dockerfile.agent" -o Dockerfile.agent
success "Created Dockerfile.agent"

info "Downloading docker-compose.claude.yml..."
curl -fsSL "$REPO_RAW_URL/templates/docker-compose.claude.yml" -o docker-compose.claude.yml
success "Created docker-compose.claude.yml"

# Optional Codex setup
echo
read -rp "$(echo -e "${BLUE}[?]${NC}") Copy Codex setup as well? (y/n) " COPY_CODEX
echo

if [[ "$COPY_CODEX" =~ ^[Yy]$ ]]; then
    info "Downloading docker-compose.codex.yml..."
    curl -fsSL "$REPO_RAW_URL/templates/docker-compose.codex.yml" -o docker-compose.codex.yml
    success "Created docker-compose.codex.yml"

    info "Downloading ralph-codex.sh..."
    curl -fsSL "$REPO_RAW_URL/templates/ralph-codex.sh" -o ralph-codex.sh
    chmod +x ralph-codex.sh
    success "Created ralph-codex.sh (executable)"

    info "Downloading run-codex.sh..."
    curl -fsSL "$REPO_RAW_URL/templates/run-codex.sh" -o run-codex.sh
    chmod +x run-codex.sh
    success "Created run-codex.sh (executable)"
fi

# Merge settings.json: combine allow/deny lists without duplicates
info "Setting up .claude/settings.json..."
if [ -f .claude/settings.json ]; then
    info "Existing settings.json found, merging permissions..."
    TEMPLATE_SETTINGS_TMP=$(mktemp)
    curl -fsSL "$REPO_RAW_URL/templates/.claude/settings.json" -o "$TEMPLATE_SETTINGS_TMP"

    MERGE_SCRIPT_TMP=$(mktemp)
    curl -fsSL "$REPO_RAW_URL/merge_settings.py" -o "$MERGE_SCRIPT_TMP"

    python3 "$MERGE_SCRIPT_TMP" .claude/settings.json "$TEMPLATE_SETTINGS_TMP" > .claude/settings.json.tmp
    mv .claude/settings.json.tmp .claude/settings.json
    rm -f "$TEMPLATE_SETTINGS_TMP" "$MERGE_SCRIPT_TMP"
    success "Merged permissions into existing .claude/settings.json"
else
    curl -fsSL "$REPO_RAW_URL/templates/.claude/settings.json" -o .claude/settings.json
    success "Created .claude/settings.json"
fi

# Final success message
echo
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  Ralph project created successfully!  ${NC}"
echo -e "${GREEN}========================================${NC}"
echo
echo "Next steps:"
if [ -n "${1:-}" ]; then
    echo "  1. cd $PROJECT_NAME"
    echo "  2. Edit PRD.md with your tasks"
    echo "  3. Customize .claude/settings.json for your stack"
else
    echo "  1. Edit PRD.md with your tasks"
    echo "  2. Customize .claude/settings.json for your stack"
fi
echo
echo "Claude Code execution modes (containerized):"
echo "  ./ralph.sh 5    # Autonomous: 5 iterations, no human input"
echo "  ./run.sh        # Interactive: human-in-the-loop + code review"
if [[ "$COPY_CODEX" =~ ^[Yy]$ ]]; then
    echo
    echo "Codex modes (containerized):"
    echo "  ./ralph-codex.sh 5  # Autonomous via Codex in Docker"
    echo "  ./run-codex.sh      # Single iteration via Codex in Docker"
fi
echo
