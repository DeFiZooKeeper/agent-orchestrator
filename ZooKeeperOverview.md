# The Zoo: AI Agent Orchestrator — Technical Overview

## Overview

The Zoo is DeFiZoo's internal AI platform — a team of specialized AI agents that 
handle software development, marketing, HR, and coordination across all protocols 
and products. Each agent is a domain expert with its own personality, memory, and 
workspace. They communicate through a central coordinator and interact with humans 
through Discord.

It runs on [OpenClaw](https://docs.openclaw.ai), an open-source AI gateway, inside 
a single Docker container.

### Design Principles

- **Team over monolith.** Multiple specialists with isolated brains scale better than one agent trying to know everything. Adding a capability means adding an agent, not rewriting a megaprompt.
- **Git over magic.** All knowledge lives as markdown in git repos — committed, diffable, human-readable. No black-box memory.
- **Communication over sharing.** Agents exchange context through messages, not shared state. Each brain deepens independently.
- **Human-in-the-loop by default.** Agents shape, plan, and execute — but humans review plans, approve PRs, test outputs, and make architectural decisions. The system is a force multiplier, not an autonomous replacement.

---

## System Architecture

```
┌──────────────────────────────────────────────────────────────┐
│                      HUMAN INTERFACE                         │
│                                                              │
│   Discord (channels per agent, DMs, notifications)           │
│   GitHub  (PRs, issues, code review, CI/CD)                  │
│   ClickUp (task intake, status tracking)                     │
└────────────────────────┬─────────────────────────────────────┘
                         │
┌────────────────────────▼─────────────────────────────────────┐
│                   OPENCLAW GATEWAY (Docker)                  │
│                                                              │
│              ┌────────────────────┐                          │
│              │   🦍 Zoo Keeper     │  coordinator / router   │
│              └─────────┬──────────┘                          │
│                        │ agentToAgent (hub-and-spoke)        │
│         ┌──────────────┼──────────────┐                      │
│   ┌─────▼─────┐  ┌────▼────┐  ┌──────▼─────┐                 │
│   │🦅 Frontend│  │🐊 API   │  │🦈 Solidity │                 │
│   │  Falcon   │  │Alligator│  │   Shark    │                 │
│   └───────────┘  └─────────┘  └────────────┘                 │
│   ┌───────────┐  ┌───────────┐                               │
│   │🐴 HR Horse│  │🐵 Marketing│                              │
│   │           │  │  Monkey   │                               │
│   └───────────┘  └───────────┘                               │
│                                                              │
│   Each agent: isolated workspace, sessions, memory, brain    │
│                                                              │
│   ┌──────────────────────────────────────────────────────┐   │
│   │  EXECUTION LAYER — 🕷️ Sprint Spider                  │   │
│   │                                                      │   │
│   │  Receives briefs from domain agents, spawns          │   │
│   │  sandboxed sub-agents for each pipeline stage:       │   │
│   │  workspace setup → planning → execution → validation │   │
│   │                                                      │   │
│   │  OpenCode CLI   — code analysis + generation         │   │
│   │  Git worktrees  — isolated workspace per task        │   │
│   └──────────────────────────────────────────────────────┘   │
└────────────────────────┬─────────────────────────────────────┘
                         │
┌────────────────────────▼─────────────────────────────────────┐
│                    EXTERNAL SERVICES                         │
│                                                              │
│   GitHub         — code hosting, PRs, CI/CD                  │
│   ClickUp        — task management                           │
│   LLM providers  — OpenRouter, Anthropic, OpenAI             │
└──────────────────────────────────────────────────────────────┘
```

---

## Multi-Agent Design

Seven agents, each a fully isolated OpenClaw persona with separate workspace, sessions, auth profiles, and memory index. No shared state between agents.

| ID | Agent | Role | Channel Binding |
|----|-------|------|-----------------|
| `coordinator` | 🦍 Zoo Keeper | Routing, triage, cross-domain coordination | Default |
| `frontend` | 🦅 Frontend Falcon | React, Next.js, UI/UX | `#frontend` |
| `backend` | 🐊 API Alligator | APIs, NestJS, MongoDB, infra | `#backend` |
| `solidity` | 🦈 Solidity Shark | Smart contracts, Hardhat/Foundry, DeFi | `#solidity` |
| `hr` | 🐴 HR Horse | Hiring, PTO, team processes | `#hr` |
| `marketing` | 🐵 Marketing Monkey | Brand, social, content, campaigns | `#marketing` |
| `sprint` | 🕷️ Sprint Spider | Coding pipeline orchestration | `#sprint` |

**Routing:** Deterministic binding — each Discord channel maps to one agent. Messages in bound channels go directly to the agent without @mention. Everything else falls through to Zoo Keeper (mention required). DMs use OpenClaw's pairing model.

**Provisioning:** New agents are created from `DeFiZooKeeper/template-brain` (GitHub template repo). Placeholder substitution, register in `openclaw.json`, add volume mount, restart gateway.

---

## Agent Communication

**Hub-and-spoke.** Specialists route through Zoo Keeper for cross-domain work. No direct specialist-to-specialist messaging.

```
                 🦅 Frontend Falcon
                      ↕
🐴 HR Horse  ←→  🦍 Zoo Keeper  ←→  🐊 API Alligator
                      ↕
                 🦈 Solidity Shark
                      ↕
                 🕷️ Sprint Spider
```

**Loop prevention:**

1. **Prompt-level:** Every AGENTS.md instructs: never send agentToAgent back to the requesting agent
2. **Structural:** Hub-and-spoke — specialists don't talk laterally
3. **Infrastructure:** Sub-agents (spawned via `sessions_spawn`) cannot use `sessions_send` or `sessions_spawn` — hard-enforced by OpenClaw, not just prompting
4. **Configuration:** Per-agent `tools.deny` can remove `sessions_send` entirely for agents that should never initiate communication (e.g., HR)

---

## Coding Pipeline

Domain specialists handle task shaping. Sprint Spider handles execution. The split keeps domain knowledge in domain agents and process knowledge in the pipeline agent.

```
User ←→ Domain Specialist (conversation, brief shaping)
              │
              │ agentToAgent: task brief
              ▼
         Sprint Spider
              │
              ├─ sessions_spawn → WORKSPACE_SETUP
              │   Clone repo, create git worktree, detect runtime,
              │   detect package manager, install deps
              │
              ├─ sessions_spawn → PLANNING
              │   OpenCode analyzes codebase, generates plan
              │   → Draft PR created for human review
              │
              │   ← Human approves plan on GitHub
              │
              ├─ sessions_spawn → EXECUTING
              │   OpenCode writes code per approved plan
              │
              ├─ sessions_spawn → VALIDATING
              │   lint + typecheck + test + build
              │   Failure → retry with error context (max 2x)
              │   Repeated failure → escalate to domain specialist
              │
              │   → PR marked ready for review
              │   ← Human QA + code review on GitHub
              │
              └─ CLEANUP
                  Remove worktree, clean branch, archive task
```

Sub-agents are sandboxed: they cannot spawn nested sub-agents or message other agents (hard-enforced by OpenClaw), have configurable timeouts, and run on a dedicated queue lane so they don't block conversation.

**Human gates:** Plan review (draft PR on GitHub), QA testing (preview deploy or staging), and code review (PR ready for review) all require human approval before the pipeline advances. At any point, `/abort` cancels the task and cleans up.

**Complexity-based flow adjustment:**
- Low (typo, dep update): skip plan review, auto-validate, straight to code review
- Medium (new endpoint, component): full planning + review cycle
- High (architecture change, cross-repo): extended planning, mandatory human involvement throughout

---

## Memory

Each agent wakes up with no memory of previous sessions. Continuity comes from two systems working together:

**Session-to-session recall — OpenClaw's built-in vector search:**

Every agent has a SQLite database (`~/.openclaw/memory/<agentId>.sqlite`) that indexes all markdown files in its workspace. When an agent needs to recall something — "what did we decide about the Lynex liquidation logic?" — it runs `memory_search`, which combines BM25 keyword matching with vector similarity to find relevant chunks across all its notes and memory files. This runs locally, per-agent, with no shared state between agents.

**Permanent records — git-native markdown in brain repos:**

Some data must be human-readable, version-controlled, and never lost. Team rosters, PTO records, birthdays, architectural decisions, coding conventions — these live as markdown files in the agent's brain repo on GitHub. They're committed, diffable, and survive any system reset. These files are also indexed by vector search, so the agent can recall them semantically without reading every file on every session start.

**How they interact:** An agent writes a decision to `decisions/api-error-handling.md` and commits it to its brain repo. The vector index picks it up automatically. Three months later, when the agent needs to recall that decision, `memory_search` finds it by meaning — even if the query uses completely different wording than the original file.

**Scale path:** OpenClaw supports QMD as an alternative backend — a local-first sidecar that adds reranking on top of BM25 + vector search. For cross-agent shared knowledge, an external vector DB (Pinecone, Weaviate) or Hindsight (Vectorize SaaS) can be layered in without changing the underlying markdown-as-source-of-truth model.

---

