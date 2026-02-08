# Agent Orchestrator

Docker deployment for [OpenClaw](https://openclaw.ai) as a self-hosted AI coding assistant. Chat with it in Discord, it writes code and opens pull requests on GitHub.

## What This Does

```
You (Discord)                     Your Server (Docker)
    │                                  │
    │  "Fix the auth bug              │
    │   in user-service"              │
    │                                  │
    ▼                                  ▼
┌──────────┐   Discord API    ┌────────────────┐
│ Discord  │◄────────────────►│   OpenClaw      │
│  Server  │                  │   Gateway       │
└──────────┘                  │   (:18789)      │
                              │                 │
                              │  LLM ──► Claude │
                              │  Sandbox ──► git clone, write code, run tests
                              │  GitHub  ──► push branch, open PR
                              │                 │
                              └────────────────┘
```

[OpenClaw](https://openclaw.ai) is an open-source personal AI assistant by [@steipete](https://github.com/steipete). This repo wraps it in Docker Compose with:
- Pre-configured Discord + GitHub integration
- Custom skills for code writing, PR creation, PR review, and issue triage
- An agent persona tuned for coding workflows

## Prerequisites

- Docker Engine 24+ with Compose v2
- A Discord bot token — [create one](https://discord.com/developers/applications)
- A GitHub personal access token — [create one](https://github.com/settings/tokens)
- At least one LLM API key: [Anthropic](https://console.anthropic.com/) (recommended), [OpenAI](https://platform.openai.com/api-keys), or [OpenRouter](https://openrouter.ai/keys)

## Quick Start

```bash
git clone https://github.com/your-org/agent-orchestrator.git
cd agent-orchestrator

# Set up environment
cp .env.example .env
# Edit .env — fill in ANTHROPIC_API_KEY, DISCORD_BOT_TOKEN, GITHUB_TOKEN

# Build and start (first build takes a few minutes)
docker compose up -d

# Watch it boot
docker compose logs -f

# Once running, complete onboarding:
docker compose exec openclaw openclaw onboard
```

Then open `http://localhost:18789` for the Control UI, or DM your bot on Discord.

### Interactive Setup (Alternative)

```bash
./setup.sh
```

Walks you through keys, builds, and starts everything.

## How It Works

The `docker-compose.yml` builds OpenClaw directly from the [official repo](https://github.com/openclaw/openclaw) — no custom Dockerfile. Docker pulls the source, builds it using OpenClaw's own Dockerfile, and runs the gateway.

Your workspace (skills, agent persona) and config are bind-mounted from this repo. OpenClaw state (sessions, credentials, memory) lives in Docker named volumes that persist across container rebuilds.

```
agent-orchestrator/
├── docker-compose.yml            # Builds + runs OpenClaw from its GitHub repo
├── .env.example                  # API keys template
├── setup.sh                      # Interactive setup helper
│
├── state/
│   └── openclaw.json             # Gateway config (Discord guilds, sandboxing, etc.)
│
├── workspace/                    # Agent workspace — bind-mounted into container
│   ├── AGENTS.md                 # What the agent does (coding workflow instructions)
│   ├── SOUL.md                   # Personality and safety rules
│   └── skills/
│       ├── github-code-pr/       # Clone repo → write code → open PR
│       ├── github-pr-review/     # Structured PR reviews
│       └── github-issue-triage/  # Issue classification and triage
│
├── README.md
├── roadmap.md
└── LICENSE
```

**Docker volumes** (persistent, managed by Docker):
- `openclaw_state` — sessions, credentials, agent memory (`/home/node/.openclaw`)
- `openclaw_local_bin` — installed CLI tools (`/home/node/.local/bin`)
- `openclaw_npm_global` — global npm packages (`/home/node/.npm-global`)

**Bind mounts** (from this repo, version-controlled):
- `./workspace` → `/home/node/.openclaw/workspace` — your skills and persona
- `./state/openclaw.json` → `/home/node/.openclaw/openclaw.json` — gateway config

## Discord Setup

1. [Discord Developer Portal](https://discord.com/developers/applications) → New Application → Bot
2. Copy the **Bot Token** → put it in `.env` as `DISCORD_BOT_TOKEN`
3. **Bot → Privileged Gateway Intents** → enable **Message Content Intent** + **Server Members Intent**
4. **OAuth2 → URL Generator** → scopes: `bot` + `applications.commands` → permissions: View Channels, Send Messages, Read Message History, Embed Links, Attach Files, Add Reactions
5. Open the generated invite URL → add bot to your server
6. Edit `state/openclaw.json` to lock down your guild:

```json5
// In channels.discord.guilds, replace the "*" wildcard:
"YOUR_GUILD_ID": {
  requireMention: true,
  users: ["YOUR_DISCORD_USER_ID"],
  channels: {
    "bot-chat": { allow: true, requireMention: false },
  },
}
```

Full Discord docs: [docs.openclaw.ai/channels/discord](https://docs.openclaw.ai/channels/discord)

## CLI Commands

Run commands inside the running container:

```bash
docker compose exec openclaw openclaw health             # Gateway health
docker compose exec openclaw openclaw status             # Detailed status
docker compose exec openclaw openclaw doctor             # Diagnose issues
docker compose exec openclaw openclaw channels status    # Channel status
docker compose exec openclaw openclaw dashboard --no-open  # Control UI URL + token
docker compose exec openclaw openclaw onboard            # Re-run onboarding
```

## Customization

### Agent Behavior

Edit the files in `workspace/`:
- `AGENTS.md` — What the agent does. Change this to customize its coding workflow, which repos it knows about, how it handles PRs.
- `SOUL.md` — Personality and safety guardrails.
- `skills/` — Add new skills by creating `skills/<name>/SKILL.md`. See [skill format](https://docs.openclaw.ai/tools/skills).

Changes are picked up on the next agent session.

### Gateway Config

Edit `state/openclaw.json` for Discord guild rules, sandboxing settings, logging, etc. Restart the container after changes:

```bash
docker compose restart
```

Full config reference: [docs.openclaw.ai/gateway/configuration](https://docs.openclaw.ai/gateway/configuration)

### Adding More Tools

To install additional CLI tools (like Claude CLI, OpenCode, Codex), add them to the startup `command` in `docker-compose.yml`. Example pattern from the startup script:

```bash
# Install Claude CLI
[ -f ~/.local/bin/claude ] || curl -fsSL https://claude.ai/install.sh | bash 2>/dev/null || true

# Install OpenCode
which opencode >/dev/null 2>&1 || npm install -g --prefix ~/.npm-global opencode-ai 2>/dev/null || true
```

Tools installed to `~/.local/bin` or `~/.npm-global` persist in Docker volumes across restarts.

### Pinning OpenClaw Version

In `docker-compose.yml`, change the build context to a specific release tag:

```yaml
build:
  context: "https://github.com/openclaw/openclaw.git#v2026.2.6"
```

## Deployment

### VPS (Hetzner, DigitalOcean, etc.)

```bash
ssh your-server
git clone https://github.com/your-org/agent-orchestrator.git
cd agent-orchestrator
cp .env.example .env && nano .env
docker compose up -d
```

Detailed guide: [docs.openclaw.ai/install/hetzner](https://docs.openclaw.ai/install/hetzner)

### Coolify

1. Create a new service → Docker Compose
2. Point to this Git repository
3. Add env vars from `.env.example` via Coolify Secrets
4. Expose port `18789`
5. Deploy

### Updating

```bash
docker compose build --no-cache   # Rebuild with latest OpenClaw
docker compose up -d              # Restart with new image
```

Or pin to a new version tag in `docker-compose.yml` and rebuild.

## Security

- Secrets in `.env` only — never baked into images.
- Gateway binds to `127.0.0.1` by default — put a reverse proxy in front for public access.
- Agent sandboxing runs code in isolated Docker containers (configured in `openclaw.json`).
- Set `requireMention: true` in shared Discord channels.
- Use Discord guild/channel allowlists to restrict who can talk to the bot.

## Links

- [OpenClaw Docs](https://docs.openclaw.ai)
- [OpenClaw GitHub](https://github.com/openclaw/openclaw)
- [Discord Setup](https://docs.openclaw.ai/channels/discord)
- [Configuration Reference](https://docs.openclaw.ai/gateway/configuration)
- [Skills System](https://docs.openclaw.ai/tools/skills)
- [Docker Deployment](https://docs.openclaw.ai/install/docker)
- [ClawHub (Community Skills)](https://clawhub.com)

## Roadmap

See [roadmap.md](./roadmap.md).

## License

MIT — see [LICENSE](./LICENSE).
