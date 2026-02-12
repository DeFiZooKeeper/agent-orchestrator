# TOOLS.md — Zoo Keeper Notes

## The Zoo

| Agent ID | Name | Workspace | Domain |
|----------|------|-----------|--------|
| `coordinator` | 🦍 Zoo Keeper | `workspace/` | Routing, general questions, cross-domain |
| `frontend` | 🦅 Frontend Falcon | `brains/frontend/` | React, Next.js, UI/UX |
| `backend` | 🐊 API Alligator | `brains/backend/` | APIs, databases, infra |
| `solidity` | 🦈 Solidity Shark | `brains/solidity/` | Solidity, DeFi, audits |
| `hr` | 🐴 HR Horse | `brains/hr/` | Hiring, team, processes |
| `marketing` | 🐵 Marketing Monkey | `brains/marketing/` | Brand voice, social media, content, community, campaigns |

## Message Prefixes

Each agent prefixes their Discord messages so users know which specialist is responding:
- `🦍 **[Zoo Keeper]**` — coordinator
- `🦅 **[Frontend Falcon]**` — frontend
- `🐊 **[API Alligator]**` — backend
- `🦈 **[Solidity Shark]**` — contracts
- `🐴 **[HR Horse]**` — HR
- `🐵 **[Marketing Monkey]**` — marketing

## Code Changes — OpenCode CLI

**All code changes MUST go through OpenCode.** Do not manually edit files with `sed`, `awk`, `echo`, or heredocs. Use the `opencode` CLI instead.

```bash
# Single task (non-interactive)
opencode run "describe the change you want to make"

# Interactive session (multi-step work)
opencode

# Target a specific model
opencode run --model <model> "prompt"
```

OpenCode handles file edits, branch creation, commits, and can open PRs. It is installed in the container via `npm install -g opencode-ai` and authenticated with `OPENCODE_API_KEY`.

**When to use OpenCode:**
- Writing or modifying code in any repository
- Fixing bugs, adding features, refactoring
- Running tests and linters
- Any file editing task

## GitHub Access

**Account:** [DeFiZooKeeper](https://github.com/DeFiZooKeeper) (personal account, not an org)

Tools available:
- `opencode` — AI coding agent for all code changes
- `git` — configured as "Zoo Keeper <zookeeper@defizoo.ai>", authenticated via `GITHUB_TOKEN` env var

### Brain Repos

| Agent | Repo | Purpose |
|-------|------|---------|
| 🦅 Frontend Falcon | `DeFiZooKeeper/frontend-brain` | Frontend workspace |
| 🐊 API Alligator | `DeFiZooKeeper/backend-brain` | Backend workspace |
| 🦈 Solidity Shark | `DeFiZooKeeper/solidity-brain` | Solidity workspace |
| 🐴 HR Horse | `DeFiZooKeeper/hr-brain` | HR workspace |
| 🐵 Marketing Monkey | `DeFiZooKeeper/marketing-brain` | Marketing workspace |

### Other Repos

_(Add project repos as agents start working with them)_

### Quick Reference

```bash
# Clone a repo (token auth is automatic via GITHUB_TOKEN)
git clone https://github.com/DeFiZooKeeper/<name>.git

# Create a new repo via GitHub API
curl -s -H "Authorization: token $GITHUB_TOKEN" \
  https://api.github.com/user/repos \
  -d '{"name":"<name>","private":true,"description":"..."}'

# List all repos
curl -s -H "Authorization: token $GITHUB_TOKEN" \
  "https://api.github.com/users/DeFiZooKeeper/repos?per_page=50"

# Open a PR
curl -s -H "Authorization: token $GITHUB_TOKEN" \
  https://api.github.com/repos/DeFiZooKeeper/<repo>/pulls \
  -d '{"title":"...","body":"...","head":"<branch>","base":"main"}'
```

## Model Providers

| Provider | Model | Role |
|----------|-------|------|
| OpenRouter | `qwen/qwen3-coder-next` | Primary |

## Discord Channels

| Channel | Agent | Notes |
|---------|-------|-------|
| `#frontend` | 🦅 Frontend Falcon | No mention required |
| `#backend` | 🐊 API Alligator | No mention required |
| `#solidity` | 🦈 Solidity Shark | No mention required |
| `#hr` | 🐴 HR Horse | No mention required |
| `#marketing` | 🐵 Marketing Monkey | No mention required |
| Everything else | 🦍 Zoo Keeper | Mention required |

