#!/usr/bin/env bash
# ============================================================
# Discord Bot — Setup Script
# ============================================================
# Interactive helper for first-time setup.
# Run: ./setup.sh
# ============================================================

set -euo pipefail

BOLD='\033[1m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m'

info()  { echo -e "${GREEN}[ok]${NC} $*"; }
warn()  { echo -e "${YELLOW}[!!]${NC} $*"; }
fail()  { echo -e "${RED}[xx]${NC} $*"; }
step()  { echo -e "\n${BOLD}--- $* ---${NC}"; }

echo ""
echo -e "${BOLD}Discord Bot Setup${NC}"
echo -e "OpenClaw + Discord + OpenRouter"
echo ""

# --- Prerequisites ---
step "Checking prerequisites"

if ! command -v docker &>/dev/null; then
    fail "Docker not found. Install: https://docs.docker.com/get-docker/"
    exit 1
fi
info "Docker: $(docker --version | head -1)"

if ! docker compose version &>/dev/null 2>&1; then
    fail "Docker Compose v2 not found."
    exit 1
fi
info "Compose: $(docker compose version --short 2>/dev/null)"

# --- .env ---
step "Environment"

if [ -f .env ]; then
    warn ".env exists, skipping creation. Edit it manually if needed."
else
    cp .env.example .env
    info "Created .env from template"
fi

echo ""
echo "Fill in your API keys (press Enter to skip any):"
echo ""

read -rp "  OPENROUTER_API_KEY: " val
[ -n "$val" ] && sed -i.bak "s/^OPENROUTER_API_KEY=.*/OPENROUTER_API_KEY=$val/" .env && rm -f .env.bak && info "Set OPENROUTER_API_KEY"

read -rp "  DISCORD_BOT_TOKEN: " val
[ -n "$val" ] && sed -i.bak "s/^DISCORD_BOT_TOKEN=.*/DISCORD_BOT_TOKEN=$val/" .env && rm -f .env.bak && info "Set DISCORD_BOT_TOKEN"

# --- Build ---
step "Building OpenClaw image (this takes a few minutes the first time)"
docker compose build

# --- Start ---
step "Starting gateway"
docker compose up -d

echo ""
echo -e "${GREEN}${BOLD}Done!${NC}"
echo ""
echo "  Control UI:    http://localhost:${OPENCLAW_PORT:-18789}"
echo "  Logs:          docker compose logs -f"
echo "  Health check:  docker compose exec openclaw openclaw health"
echo ""
echo "Next steps:"
echo "  1. Invite your Discord bot to your server"
echo "  2. DM the bot or @mention it in a channel"
echo "  3. Approve the pairing code when prompted"
echo ""
