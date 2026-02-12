# Discord Bot

A simple Discord chat bot powered by [OpenClaw](https://openclaw.ai) and Claude. DM it or @mention it in a channel and get AI responses.

## How It Works

```
You (Discord)                     Your Server (Docker)
    │                                  │
    │  "Hey, what's the              │
    │   weather like?"               │
    │                                  │
    ▼                                  ▼
┌──────────┐   Discord API    ┌────────────────┐
│ Discord  │◄────────────────►│   OpenClaw      │
│  Server  │                  │   Gateway       │
└──────────┘                  │   (:18789)      │
                              │                 │
                              │  LLM ──► Claude │
                              └────────────────┘
```

## Prerequisites

- Docker Engine 24+ with Compose v2
- A Discord bot token — [create one](https://discord.com/developers/applications)
- An OpenRouter API key — [get one](https://openrouter.ai/keys)

## Quick Start

```bash
git clone https://github.com/your-org/agent-orchestrator.git
cd agent-orchestrator

cp .env.example .env
# Edit .env — fill in OPENROUTER_API_KEY and DISCORD_BOT_TOKEN

docker compose up -d
docker compose logs -f
```

Then DM your bot on Discord or @mention it in a channel.

### Interactive Setup

```bash
./setup.sh
```

## Discord Bot Setup

1. Go to the [Discord Developer Portal](https://discord.com/developers/applications) and create a new application
2. Go to **Bot** and copy the **Bot Token** into your `.env` as `DISCORD_BOT_TOKEN`
3. Under **Privileged Gateway Intents**, enable:
   - **Message Content Intent**
   - **Server Members Intent**
4. Go to **OAuth2 → URL Generator**:
   - Scopes: `bot` + `applications.commands`
   - Permissions: View Channels, Send Messages, Read Message History, Embed Links, Attach Files, Add Reactions
5. Open the generated URL and add the bot to your server
6. DM the bot — approve the pairing code when prompted

Full Discord docs: [docs.openclaw.ai/channels/discord](https://docs.openclaw.ai/channels/discord)

## Configuration

### Guild lockdown (optional)

Edit `state/openclaw.json` to restrict which servers/channels/users can talk to the bot:

```json
{
  "channels": {
    "discord": {
      "guilds": {
        "YOUR_GUILD_ID": {
          "requireMention": true,
          "users": ["YOUR_USER_ID"],
          "channels": {
            "bot-chat": { "allow": true, "requireMention": false }
          }
        }
      }
    }
  }
}
```

### Bot personality

Edit `workspace/AGENTS.md` and `workspace/SOUL.md` to change how the bot behaves. Changes are picked up on the next session.

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
├── docker-compose.yml          # Builds + runs OpenClaw
├── .env.example                # API keys template
├── setup.sh                    # Interactive setup helper
├── state/
│   └── openclaw.json           # Gateway + Discord config
├── workspace/
│   ├── AGENTS.md               # What the bot does
│   └── SOUL.md                 # Personality
└── README.md
```

## Links

- [OpenClaw Docs](https://docs.openclaw.ai)
- [Discord Channel Setup](https://docs.openclaw.ai/channels/discord)
- [Configuration Reference](https://docs.openclaw.ai/gateway/configuration)

## License

MIT — see [LICENSE](./LICENSE).
