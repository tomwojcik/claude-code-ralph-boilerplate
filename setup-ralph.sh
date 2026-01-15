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
info "Downloading PRD.md..."
curl -fsSL "$REPO_RAW_URL/templates/PRD.md" -o PRD.md
sed -i "s/PROJECT_NAME_PLACEHOLDER/$PROJECT_NAME/g" PRD.md
success "Created PRD.md"

info "Downloading progress.txt..."
curl -fsSL "$REPO_RAW_URL/templates/progress.txt" -o progress.txt
success "Created progress.txt"

info "Downloading ralph.sh..."
curl -fsSL "$REPO_RAW_URL/templates/ralph.sh" -o ralph.sh
chmod +x ralph.sh
success "Created ralph.sh (executable)"

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
    echo "  3. Run: ./ralph.sh <iterations>"
else
    echo "  1. Edit PRD.md with your tasks"
    echo "  2. Run: ./ralph.sh <iterations>"
fi
echo
echo "Example:"
echo "  ./ralph.sh 5    # Run 5 iterations"
echo
