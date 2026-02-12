# 🦍 Zoo Keeper — Agent Orchestrator

Zoo Keeper is the coordinator agent for **The Zoo**, DeFiZoo's internal AI platform. It routes messages, triages requests, coordinates cross-domain work between specialist agents, and provisions new agents.

This repo contains the OpenClaw gateway configuration, Zoo Keeper's brain, and the orchestration layer that ties all agents together. Each specialist agent has its own brain repo — they're cloned into `brains/` and mounted as isolated workspaces.

Built on [OpenClaw](https://docs.openclaw.ai), running in a single Docker container.

## The Zoo — Architecture

Zoo Keeper sits at the center of a hub-and-spoke multi-agent system. Specialists handle domain work; Zoo Keeper handles routing and coordination.

```
┌───────────────────────────────────────────────────────────────┐
│  HUMAN INTERFACE                                              │
│                                                               │
│  Discord   → one channel per agent, DMs, notifications        │
│  GitHub    → PRs, issues, code review, CI/CD                  │
└──────────────────────────┬────────────────────────────────────┘
                           │
┌──────────────────────────▼────────────────────────────────────┐
│  OPENCLAW GATEWAY (Docker)                                    │
│                                                               │
│            ┌────────────────────┐                             │
│            │   🦍 Zoo Keeper     │  coordinator / router      │
│            └─────────┬──────────┘                             │
│                      │ agentToAgent (hub-and-spoke)           │
│       ┌──────────────┼──────────────┐                        │
│  ┌────▼─────┐  ┌─────▼────┐  ┌─────▼──────┐                 │
│  │🦅 Frontend│  │🐊 API    │  │🦈 Solidity │                 │
│  │  Falcon   │  │Alligator │  │   Shark    │                 │
│  └──────────┘  └──────────┘  └────────────┘                  │
│  ┌──────────┐  ┌───────────┐                                 │
│  │🐴 HR     │  │🐵 Marketing│                                │
│  │  Horse   │  │  Monkey    │                                │
│  └──────────┘  └───────────┘                                 │
│                                                               │
│  ┌─────────────────────────────────────────────────────────┐  │
│  │  🕷️ Sprint Spider — Execution Layer                      │  │
│  │  Receives briefs → spawns sub-agents for each stage:    │  │
│  │  workspace setup → planning → execution → validation    │  │
│  └─────────────────────────────────────────────────────────┘  │
└──────────────────────────┬────────────────────────────────────┘
                           │
┌──────────────────────────▼────────────────────────────────────┐
│  EXTERNAL SERVICES                                            │
│  GitHub · ClickUp · Coolify · LLM providers (OpenRouter, etc) │
└───────────────────────────────────────────────────────────────┘
```

## The Agents

Zoo Keeper coordinates seven agents, each with an isolated workspace, its own brain repo, persistent memory, and a distinct personality.

| Agent | Channel | Domain |
|-------|---------|--------|
| 🦍 **Zoo Keeper** | All (mention required) | Routing, triage, cross-domain coordination |
| 🦅 Frontend Falcon | `#frontend` | React, Next.js, UI/UX |
| 🐊 API Alligator | `#backend` | APIs, NestJS, databases, infra |
| 🦈 Solidity Shark | `#solidity` | Smart contracts, DeFi, Hardhat/Foundry |
| 🐴 HR Horse | `#hr` | Hiring, PTO, team processes |
| 🐵 Marketing Monkey | `#marketing` | Brand, social media, content, campaigns |
| 🕷️ Sprint Spider | `#sprint` | Coding pipeline orchestration |

Messages in bound channels go directly to the assigned specialist — no @mention needed. Everything else falls through to Zoo Keeper (mention required). Specialists route through Zoo Keeper for cross-domain work; no direct specialist-to-specialist messaging.

## How It Works

1. **Talk to a specialist.** Open a conversation in a domain channel (e.g. `#frontend`). The specialist understands your problem, asks clarifying questions, and shapes a task brief.

2. **Sprint Spider runs the pipeline.** The domain agent hands the brief to Sprint Spider, which autonomously: sets up a workspace, generates an implementation plan, creates code, and runs validation (lint, test, build).

3. **Humans stay in the loop.** Plan review (draft PR), QA testing, and code review all require human approval before the pipeline advances. `/abort` cancels at any point.

```
User ←→ Domain Specialist (conversation + brief shaping)
              │
              │ agentToAgent
              ▼
         🕷️ Sprint Spider
              │
              ├─ Workspace setup (clone, worktree, deps)
              ├─ Planning (OpenCode analysis → draft PR)
              │   ← Human approves plan
              ├─ Execution (OpenCode writes code)
              ├─ Validation (lint + test + build, auto-retry)
              │   → PR ready for review
              │   ← Human QA + code review
              └─ Cleanup (worktree, branch, archive)
```

## Prerequisites

- Docker Engine 24+ with Compose v2
- A Discord bot token — [create one](https://discord.com/developers/applications)
- An OpenRouter API key — [get one](https://openrouter.ai/keys)
- A GitHub token with `repo` scope

## Quick Start

```bash
git clone https://github.com/DeFiZooKeeper/agent-orchestrator.git
cd agent-orchestrator

cp .env.example .env
# Fill in: OPENROUTER_API_KEY, DISCORD_BOT_TOKEN, GITHUB_TOKEN

docker compose up -d
docker compose logs -f
```

### Interactive Setup

```bash
./setup.sh
```

### Brain Repos

Each specialist agent has its own brain repo on GitHub (`DeFiZooKeeper/<id>-brain`). They're cloned into `brains/` and mounted as isolated workspaces inside the container.

```bash
./setup-brains.sh
```

New agents are provisioned from the `DeFiZooKeeper/template-brain` GitHub template.

## Discord Setup

1. Go to the [Discord Developer Portal](https://discord.com/developers/applications) and create a new application
2. Go to **Bot** → copy the **Bot Token** into `.env` as `DISCORD_BOT_TOKEN`
3. Under **Privileged Gateway Intents**, enable **Message Content Intent** and **Server Members Intent**
4. Go to **OAuth2 → URL Generator**:
   - Scopes: `bot` + `applications.commands`
   - Permissions: View Channels, Send Messages, Read Message History, Embed Links, Attach Files, Add Reactions
5. Open the generated URL and add the bot to your server
6. Create channels for each agent (`#frontend`, `#backend`, `#solidity`, `#hr`, `#marketing`, `#sprint`)
7. Update `state/openclaw.json` with your guild ID and channel IDs

Full Discord docs: [docs.openclaw.ai/channels/discord](https://docs.openclaw.ai/channels/discord)

## Configuration

### Agent routing

Edit `state/openclaw.json` to configure channel-to-agent bindings, guild lockdown, and mention requirements.

### Zoo Keeper's brain

Zoo Keeper's behavior and personality are defined by markdown files in `workspace/`:

| File | Purpose |
|------|---------|
| `AGENTS.md` | What the agent does, its rules, how it behaves |
| `SOUL.md` | Personality and identity |
| `USER.md` | Team context |
| `MEMORY.md` | Long-term curated memory |
| `memory/` | Daily session logs |

Specialist agents have the same file structure in their own brain repos (`brains/<agent-id>/`).

### Memory

Agents use a hybrid memory system:

- **OpenClaw vector search** — indexes all markdown in the workspace, provides semantic + keyword retrieval via `memory_search`. Per-agent SQLite, no shared state.
- **Git-native markdown** — permanent records (team rosters, PTO, architectural decisions) committed to brain repos. Human-readable, diffable, version-controlled — and also indexed by vector search.

### Restart after config changes

```bash
docker compose restart
```

## CLI Commands

```bash
docker compose exec openclaw openclaw health           # Gateway health
docker compose exec openclaw openclaw doctor           # Diagnose issues
docker compose exec openclaw openclaw channels status  # Discord status
```

## Project Structure

```
├── docker-compose.yml              # OpenClaw gateway + all agent mounts
├── .env.example                    # API keys template
├── setup.sh                        # Interactive setup helper
├── setup-brains.sh                 # Clone/init specialist brain repos
├── ZooKeeperOrchestratorSpec.md    # Full product specification
├── ZooKeeperOverview.md            # Technical overview
├── state/
│   └── openclaw.json               # Gateway + agent + Discord config
├── workspace/                      # 🦍 Zoo Keeper's brain
│   ├── AGENTS.md
│   ├── SOUL.md
│   ├── USER.md
│   ├── MEMORY.md
│   └── memory/
└── brains/                         # Specialist brains (cloned from GitHub)
    ├── frontend/                   # → DeFiZooKeeper/frontend-brain
    ├── backend/                    # → DeFiZooKeeper/backend-brain
    ├── solidity/                   # → DeFiZooKeeper/solidity-brain
    ├── hr/                         # → DeFiZooKeeper/hr-brain
    ├── marketing/                  # → DeFiZooKeeper/marketing-brain
    └── sprint/                     # → DeFiZooKeeper/sprint-brain
```

## Design Principles

- **Team over monolith.** Multiple specialists scale better than one megaprompt. Adding a capability means adding an agent.
- **Git over magic.** All knowledge lives as markdown in git repos — committed, diffable, human-readable.
- **Communication over sharing.** Agents exchange context through messages, not shared state. Each brain deepens independently.
- **Human-in-the-loop by default.** AI shapes, plans, and executes — humans review, approve, and make architectural decisions.

## Links

- [OpenClaw Docs](https://docs.openclaw.ai)
- [Discord Channel Setup](https://docs.openclaw.ai/channels/discord)
- [Configuration Reference](https://docs.openclaw.ai/gateway/configuration)

## License

MIT — see [LICENSE](./LICENSE).
