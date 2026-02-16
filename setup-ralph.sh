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

if [ -f .claude/commands/run.md ]; then
    warn ".claude/commands/run.md already exists, skipping"
else
    curl -fsSL "$REPO_RAW_URL/templates/.claude/commands/run.md" -o .claude/commands/run.md
    success "Created .claude/commands/run.md"
fi

if [ -f .claude/commands/review.md ]; then
    warn ".claude/commands/review.md already exists, skipping"
else
    curl -fsSL "$REPO_RAW_URL/templates/.claude/commands/review.md" -o .claude/commands/review.md
    success "Created .claude/commands/review.md"
fi

# Merge settings.json: combine allow/deny lists without duplicates
info "Setting up .claude/settings.json..."
if [ -f .claude/settings.json ]; then
    info "Existing settings.json found, merging permissions..."
    TEMPLATE_SETTINGS=$(curl -fsSL "$REPO_RAW_URL/templates/.claude/settings.json")

    # Use python3 to deep-merge the settings (available on virtually all systems)
    MERGED=$(python3 -c "
import json, sys

existing = json.load(open('.claude/settings.json'))
template = json.loads('''$TEMPLATE_SETTINGS''')

# Merge permissions.allow and permissions.deny as sets (no duplicates)
for key in ('allow', 'deny'):
    existing_list = existing.get('permissions', {}).get(key, [])
    template_list = template.get('permissions', {}).get(key, [])
    merged = list(dict.fromkeys(existing_list + template_list))
    existing.setdefault('permissions', {})[key] = merged

json.dump(existing, sys.stdout, indent=2)
print()
")
    echo "$MERGED" > .claude/settings.json
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
echo "Two execution modes:"
echo "  ./ralph.sh 5    # Autonomous: 5 iterations, no human input"
echo "  ./run.sh        # Interactive: human-in-the-loop + code review"
echo
