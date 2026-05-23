#!/usr/bin/env bash
# common.sh — Shared functions for zen-ai-stack
set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

LOG_FILE="${ZEN_LOG_DIR:-$HOME/.zen-ai-stack}/install.log"

init_log() {
    mkdir -p "$(dirname "$LOG_FILE")"
    touch "$LOG_FILE"
}

log() {
    local msg="[$(date '+%H:%M:%S')] $*"
    echo -e "${BLUE}ℹ️${NC} $*"
    echo "$msg" >> "$LOG_FILE"
}

ok() {
    echo -e "  ${GREEN}✅${NC} $*"
    echo "[$(date '+%H:%M:%S')] ✅ $*" >> "$LOG_FILE"
}

warn() {
    echo -e "  ${YELLOW}⚠️${NC} $*"
    echo "[$(date '+%H:%M:%S')] ⚠️ $*" >> "$LOG_FILE"
}

die() {
    echo -e "  ${RED}❌${NC} $*"
    echo "[$(date '+%H:%M:%S')] ❌ $*" >> "$LOG_FILE"
    exit 1
}

confirm() {
    local prompt="${1:-Continue?}"
    local response
    read -r -p "$(echo -e "${YELLOW}?${NC} $prompt [Y/n]: ")" response
    case "$response" in
        [nN]|[nN][oO]) return 1 ;;
        *) return 0 ;;
    esac
}

spinner() {
    local pid=$1
    local msg=$2
    local spin='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
    local i=0
    while kill -0 "$pid" 2>/dev/null; do
        i=$(( (i+1) % ${#spin} ))
        printf "\r  ${CYAN}%s${NC} %s" "${spin:$i:1}" "$msg"
        sleep 0.1
    done
    printf "\r  ${GREEN}✅${NC} %s\n" "$msg"
}

progress_bar() {
    local current=$1
    local total=$2
    local label=$3
    local pct=$(( current * 100 / total ))
    local filled=$(( pct / 2 ))
    local unfilled=$(( 50 - filled ))
    printf "\r  [${GREEN}"
    printf '%0.s█' $(seq 1 "$filled")
    printf "${NC}"
    printf '%0.s░' $(seq 1 "$unfilled")
    printf "] ${CYAN}%3d%%${NC} (%d/%d) ${label}" "$pct" "$current" "$total"
    if [ "$current" -eq "$total" ]; then
        echo
    fi
}

check_sudo() {
    if ! sudo -n true 2>/dev/null; then
        log "Sudo required. You may be prompted for password."
        sudo -v
    fi
}

require_tool() {
    local cmd=$1
    local hint=${2:-}
    if ! command -v "$cmd" &>/dev/null; then
        die "'$cmd' not found. ${hint:-Install it and try again.}"
    fi
}
