#!/bin/bash
set -e

cd "$(dirname "$0")"

# Activate nvm if .nvmrc exists
if [ -f ".nvmrc" ]; then
  export NVM_DIR="${NVM_DIR:-$HOME/.nvm}"
  [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
  nvm use
fi

claude --permission-mode acceptEdits "/run"

claude --permission-mode acceptEdits --model opus "/review"
