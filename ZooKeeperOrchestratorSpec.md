# The Zoo: AI Agent Orchestrator

## Product Specification v1.0

**Date:** February 12, 2026
**Team:** DeFiZoo
**Platform:** OpenClaw Gateway

---

## 1. Product Overview

### 1.1 What Is the Zoo?

The Zoo is DeFiZoo's internal AI orchestration platform. It operates as a **team of specialized AI agents** — each with its own brain, personality, memory, and domain expertise — coordinated by a central agent called Zoo Keeper. Together, they handle software development, marketing, HR, operations, and cross-domain coordination across DeFiZoo's protocols and products.

The Zoo is not a single monolithic AI. It is an **organization of specialists** running inside OpenClaw, DeFiZoo's AI gateway. Each agent owns a Discord channel, maintains its own git-backed brain repository, and communicates with other agents through structured message passing. Humans interact with whichever specialist fits their need — talk in `#frontend`, get a frontend expert; talk in `#solidity`, get a smart contract expert.

### 1.2 Why It Exists

DeFiZoo operates three DeFi protocols (VaultEdge, Felines, ApeBond) — each with smart contracts, frontends, backends, and subgraphs. Maintaining and evolving all of these with a lean team requires a force multiplier that goes beyond just code. The Zoo is that force multiplier: a full AI team covering coding, marketing, HR, and coordination — where each specialist deepens its domain expertise over time through persistent, git-native memory.

### 1.3 Design Philosophy

The Zoo is built on five principles:

1. **Team over monolith.** Multiple specialists with isolated brains scale better than one agent trying to know everything. Adding a new capability means adding a new agent, not rewriting a megaprompt.

2. **Git over magic.** All knowledge evolution happens through commits and PRs. Memory files are markdown, brain repos are git repositories, and every change is auditable, reversible, and human-readable.

3. **Communication over sharing.** Agents exchange context through messages, not shared memory pools. Each brain deepens independently. Cross-domain knowledge flows through the coordinator.

4. **Natural over rigid.** Interaction should feel like talking to a team member, not issuing commands to a pipeline. Channel-based routing, conversational task shaping, and agent personalities make the system approachable.

5. **Human-in-the-loop by default.** AI agents shape, plan, and execute — but humans review plans, approve PRs, test outputs, and make architectural decisions. The system is a force multiplier, not an autonomous replacement.

### 1.4 Key Stakeholders

- **Doublo** — AI-Augmented Engineering Lead. Primary user of the coding pipeline. Reviews AI-generated plans and code, handles the work AI can't do alone, ships production-quality software across all protocols. Admin authority (Discord ID: `915194999321288734`).
- **Team members** — Engineers, marketers, and ops staff who interact with the Zoo through Discord channels for domain-specific help.

---

## 2. Architecture

### 2.1 System Overview

```
┌──────────────────────────────────────────────────────────────┐
│                      HUMAN INTERFACE                          │
│                                                               │
│   Discord                                                     │
│   ├── #general          → 🦍 Zoo Keeper (mention required)    │
│   ├── #frontend         → 🦅 Frontend Falcon                  │
│   ├── #backend          → 🐊 API Alligator                    │
│   ├── #solidity         → 🦈 Solidity Shark                   │
│   ├── #hr               → 🐴 HR Horse                         │
│   ├── #marketing        → 🐵 Marketing Monkey                 │
│   ├── #sprint           → 🕷️  Sprint Spider                   │
│   └── DMs               → paired agent (via pairing)          │
│                                                               │
│   GitHub (PRs, issues, code review)                           │
└─────────────────────────┬─────────────────────────────────────┘
                          │
┌─────────────────────────▼─────────────────────────────────────┐
│                    OPENCLAW GATEWAY                            │
│                    (Docker container)                          │
│                                                               │
│               ┌────────────────────┐                          │
│               │   🦍 Zoo Keeper     │                          │
│               │   coordinator       │                          │
│               │   routes, triages,  │                          │
│               │   coordinates       │                          │
│               └─────────┬──────────┘                          │
│                         │ agentToAgent (hub-and-spoke)         │
│          ┌──────────────┼──────────────┐                      │
│          │              │              │                       │
│   ┌──────▼──────┐ ┌────▼────┐ ┌───────▼──────┐               │
│   │🦅 Frontend  │ │🐊 API   │ │🦈 Solidity   │               │
│   │   Falcon    │ │Alligator│ │   Shark      │               │
│   └─────────────┘ └─────────┘ └──────────────┘               │
│   ┌─────────────┐ ┌─────────────┐                             │
│   │🐴 HR Horse  │ │🐵 Marketing │                             │
│   │             │ │   Monkey    │                             │
│   └─────────────┘ └─────────────┘                             │
│                                                               │
│   Each agent has:                                             │
│   ├── Isolated workspace (brain repo)                         │
│   ├── Own session store + auth profiles                       │
│   ├── Own memory index (SQLite per agent)                     │
│   └── AGENTS.md / SOUL.md / USER.md / MEMORY.md              │
│                                                               │
│   ┌───────────────────────────────────────────────────────┐   │
│   │              EXECUTION LAYER                          │   │
│   │                                                       │   │
│   │   🕷️  Sprint Spider (pipeline agent)                   │   │
│   │   Receives briefs from domain agents via agentToAgent  │   │
│   │                                                       │   │
│   │   Spawns sandboxed sub-agents (sessions_spawn):       │   │
│   │   ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌────────┐  │   │
│   │   │WORKSPACE │ │ PLANNING │ │EXECUTING │ │VALIDATE│  │   │
│   │   │  SETUP   │ │          │ │          │ │        │  │   │
│   │   └──────────┘ └──────────┘ └──────────┘ └────────┘  │   │
│   │                                                       │   │
│   │   OpenCode CLI  — code analysis, generation, editing  │   │
│   │   Git worktrees — isolated workspace per task         │   │
│   │   Validation    — lint, typecheck, test, build        │   │
│   └───────────────────────────────────────────────────────┘   │
└───────────────────────────────────────────────────────────────┘
                          │
┌─────────────────────────▼─────────────────────────────────────┐
│                    EXTERNAL SERVICES                           │
│                                                               │
│   GitHub         — code hosting, PRs, issues, CI/CD           │
│   Discord        — team communication, task intake            │
│   ClickUp        — task management                            │
│   Coolify        — preview deployments                        │
└───────────────────────────────────────────────────────────────┘
```

### 2.2 Component Inventory

| Component | Technology | Purpose |
|-----------|-----------|---------|
| OpenClaw Gateway | Node.js / Docker | Agent routing, Discord integration, tool execution |
| Zoo Keeper | OpenClaw agent (`coordinator`) | Triage, routing, cross-domain coordination |
| Frontend Falcon | OpenClaw agent (`frontend`) | Frontend development, React/Next.js, UI/UX |
| API Alligator | OpenClaw agent (`backend`) | Backend development, APIs, databases, infra |
| Solidity Shark | OpenClaw agent (`solidity`) | Smart contracts, DeFi protocols, auditing |
| HR Horse | OpenClaw agent (`hr`) | HR, PTO tracking, hiring, team processes |
| Marketing Monkey | OpenClaw agent (`marketing`) | Brand, social media, content, campaigns |
| Sprint Spider | OpenClaw agent (`sprint`) | Coding pipeline orchestration |
| Brain repos | Git repositories (GitHub) | Per-agent persistent workspace and memory |
| Template Brain | GitHub repo template | Bootstrapping new agent brains |
| OpenCode CLI | npm package | AI coding execution engine |

### 2.3 Infrastructure

- **Runtime:** Single Docker container running OpenClaw Gateway
- **Image:** Built from `openclaw/openclaw` (pinned to release tag)
- **Networking:** Gateway bound to `lan` inside container; host access restricted to `127.0.0.1` via Docker port binding
- **Persistent storage:** Named Docker volume (`openclaw_config`) for gateway state; host-mounted volumes for brain repos and configuration
- **Git identity:** `Zoo Keeper <zookeeper@defizoo.ai>`
- **GitHub account:** [DeFiZooKeeper](https://github.com/DeFiZooKeeper)

---

## 3. The Zoo — Agent Roster

### 3.1 Overview

Each agent in the Zoo is a fully isolated persona with its own workspace, session store, memory, and personality. Agents are domain experts — they know their field deeply and don't pretend to know fields outside their scope.

| Agent ID | Name | Emoji | Domain | Discord Channel | Brain Repo |
|----------|------|-------|--------|----------------|------------|
| `coordinator` | Zoo Keeper | 🦍 | Routing, coordination, general | All (mention required) | `workspace/` (orchestrator repo) |
| `frontend` | Frontend Falcon | 🦅 | React, Next.js, UI/UX, styling | `#frontend` | `DeFiZooKeeper/frontend-brain` |
| `backend` | API Alligator | 🐊 | APIs, databases, server logic, infra | `#backend` | `DeFiZooKeeper/backend-brain` |
| `solidity` | Solidity Shark | 🦈 | Smart contracts, DeFi, auditing | `#solidity` | `DeFiZooKeeper/solidity-brain` |
| `hr` | HR Horse | 🐴 | Hiring, team, PTO, processes | `#hr` | `DeFiZooKeeper/hr-brain` |
| `marketing` | Marketing Monkey | 🐵 | Brand, social media, content, campaigns | `#marketing` | `DeFiZooKeeper/marketing-brain` |
| `sprint` | Sprint Spider | 🕷️  | Coding pipeline orchestration | `#sprint` | `DeFiZooKeeper/sprint-brain` |

### 3.2 Zoo Keeper — The Coordinator

Zoo Keeper is the public face of the Zoo. It handles:

- **Triage:** Determines if a message needs a specialist and routes it via `agentToAgent`
- **General questions:** Non-technical questions, project status, planning
- **Cross-domain coordination:** Tasks spanning frontend + backend + contracts
- **Knowledge brokering:** Knows *who* knows what — routes, doesn't guess
- **Agent provisioning:** Creates new specialist agents from `template-brain`

Zoo Keeper does NOT write production code, make architectural decisions in isolation, or store domain-specific knowledge. It is a coordinator, not a generalist.

**Message prefix:** `🦍 **[Zoo Keeper]**`

### 3.3 Domain Specialists

Each domain specialist:

- **Owns a Discord channel** where users can talk without @mentioning
- **Maintains a brain repo** that evolves through git commits
- **Uses OpenCode** for all code modifications (clone → `opencode run` → branch → commit → PR)
- **Has its own personality** defined in `SOUL.md`
- **Reads memory files** at session start for continuity
- **Routes to Zoo Keeper** when a question is outside its domain (hub-and-spoke pattern)

| Agent | Prefix | Ask them about |
|-------|--------|---------------|
| 🦅 Frontend Falcon | `🦅 **[Frontend Falcon]**` | React, UI/UX, components, styling, frontend architecture |
| 🐊 API Alligator | `🐊 **[API Alligator]**` | APIs, databases, server logic, infrastructure, DevOps |
| 🦈 Solidity Shark | `🦈 **[Solidity Shark]**` | Smart contracts, DeFi protocols, on-chain logic, auditing |
| 🐴 HR Horse | `🐴 **[HR Horse]**` | Hiring, team processes, PTO, people operations |
| 🐵 Marketing Monkey | `🐵 **[Marketing Monkey]**` | Brand voice, social media, content, community, campaigns |

### 3.4 Sprint Spider — The Pipeline Agent

Sprint Spider is the Zoo's coding pipeline specialist. While domain agents shape tasks through conversation with humans, Sprint Spider owns the execution lifecycle: workspace setup, planning, code generation, validation, PR management, and cleanup.

**Why a separate agent?** Keeping pipeline logic in Sprint Spider's brain (not Zoo Keeper's) means:
- Domain agents stay focused on domain expertise
- Pipeline logic can evolve independently
- Sprint Spider can use sub-agents (`sessions_spawn`) for parallel work
- The pipeline doesn't pollute the coordinator's context window

**How it works:**

```
User in #frontend: "The liquidation widget is broken"
         │
    🦅 Frontend Falcon: shapes the task, understands the domain
         │
    🦅 → agentToAgent → 🕷️  Sprint Spider:
      "Task: Fix liquidation threshold in felines-frontend.
       The comparison should trigger at exactly 150%, currently
       only triggers below. Add boundary test case."
         │
    🕷️  Sprint Spider runs the pipeline:
      1. Spawns sub-agent: clone repo, create worktree, install deps
      2. Spawns sub-agent: OpenCode planning phase
      3. Creates draft PR with plan for human review
      4. On approval: spawns sub-agent for execution
      5. Spawns sub-agent: lint + test + build validation
      6. Marks PR ready for review
         │
    🕷️  → agentToAgent → 🦅 Frontend Falcon:
      "PR #42 ready for review: github.com/DeFiZooKeeper/..."
         │
    🦅 Reports back in #frontend
```

**Sprint Spider sub-agents use OpenClaw's built-in protections:**
- Sub-agents **cannot spawn sub-agents** (no nested fan-out — hard enforced)
- Sub-agents **cannot use `sessions_send`** (no triggering other agents)
- Sub-agents have **configurable timeouts** (`runTimeoutSeconds`)
- Sub-agents run on a **dedicated queue lane** (don't block main conversation)
- Sub-agents can use a **cheaper model** to save costs on mechanical work

**Message prefix:** `🕷️  **[Sprint Spider]**`

See [Section 6: Task Pipeline](#6-task-pipeline-sprint-spider) for the full lifecycle.

### 3.5 Agent Provisioning — Template Brain

New agents are created from `DeFiZooKeeper/template-brain`, a GitHub template repository containing the standard workspace files with placeholders:

- `AGENTS.md` — agent instructions (`{{AGENT_ID}}`, `{{AGENT_NAME}}`, `{{EMOJI}}`, `{{DOMAIN}}`)
- `SOUL.md` — personality and identity
- `USER.md` — team context
- `TOOLS.md` — available tools and notes
- `IDENTITY.md` — public-facing identity
- `HEARTBEAT.md` — periodic check configuration
- `MEMORY.md` — long-term memory
- `memory/` — daily notes directory

**Provisioning workflow:**

1. Create repo from template: `DeFiZooKeeper/template-brain` → `DeFiZooKeeper/<id>-brain`
2. Clone into `brains/<id>/`
3. Replace placeholders in all files
4. Register in `state/openclaw.json` (agent list, bindings)
5. Update `setup-brains.sh` and `workspace/AGENTS.md` (roster)
6. Restart gateway: `docker compose restart`

**Stub brain pattern:** When `setup-brains.sh` can't clone a brain repo (doesn't exist yet), it creates a minimal `AGENTS.md` stub that instructs the agent to ask the user about creating its brain from the template. On confirmation, the agent delegates to Zoo Keeper via `agentToAgent` to perform the full creation workflow.

---

## 4. Communication & Routing

### 4.1 Discord Channel Routing

Each agent is bound to a Discord channel via `bindings` in `openclaw.json`. Messages in bound channels route directly to the assigned agent without requiring an @mention.

| Channel | Agent | Mention Required |
|---------|-------|-----------------|
| `#frontend` | 🦅 Frontend Falcon | No |
| `#backend` | 🐊 API Alligator | No |
| `#solidity` | 🦈 Solidity Shark | No |
| `#hr` | 🐴 HR Horse | No |
| `#marketing` | 🐵 Marketing Monkey | No |
| `#sprint` | 🕷️  Sprint Spider | No |
| Everything else | 🦍 Zoo Keeper | Yes |
| DMs | Paired agent | — |

**Routing rules (most-specific wins):**
1. Peer match (exact DM/group/channel id)
2. Guild id (Discord)
3. Channel-level match
4. Fallback to default agent (Zoo Keeper)

### 4.2 Agent-to-Agent Communication

Agents communicate via `agentToAgent` (`sessions_send`). This is enabled globally with an allow list of eligible target agents:

```json
"tools": {
  "agentToAgent": {
    "enabled": true,
    "allow": ["coordinator", "frontend", "backend", "solidity", "hr", "marketing", "sprint"]
  }
}
```

**Every `agentToAgent` message must include:**
1. **Context:** What the user asked and why you're delegating
2. **Specific question:** What you need from the specialist
3. **Format:** How you want the answer (summary, code, PR link, etc.)

### 4.3 Hub-and-Spoke Pattern

To keep communication clean and prevent loops, the Zoo uses a **hub-and-spoke model**:

```
                    🦅 Frontend Falcon
                         ↕
🐴 HR Horse  ←→  🦍 Zoo Keeper  ←→  🐊 API Alligator
                         ↕
                    🦈 Solidity Shark
                         ↕
                    🕷️  Sprint Spider
```

**Rules:**
- **Specialists talk to Zoo Keeper** for cross-domain questions, never directly to each other
- **Zoo Keeper routes** between specialists when multi-domain coordination is needed
- **Coding specialists talk to Sprint Spider** for pipeline execution (via Zoo Keeper or direct, depending on context)
- **Sprint Spider talks to coding specialists** to report results back

**Exception:** Domain agents may send task briefs directly to Sprint Spider when the user explicitly requests code changes. This is a one-directional handoff, not a conversation loop.

### 4.4 Loop Prevention

Agent-to-agent communication has no built-in loop detection in OpenClaw. The Zoo prevents loops through layered safeguards:

**Layer 1 — AGENTS.md instruction (soft enforcement):**
Every specialist's AGENTS.md contains this rule:
> "When responding to an agentToAgent query from another agent, NEVER send an agentToAgent query back to the requesting agent. If you can't answer from your own knowledge, say 'I don't have enough context for this' rather than re-delegating."

**Layer 2 — Hub-and-spoke routing (structural enforcement):**
Specialists don't talk to each other directly. All cross-domain communication routes through Zoo Keeper, who has the context to detect and break potential loops.

**Layer 3 — Sub-agent hard limits (infrastructure enforcement):**
Sprint Spider's sub-agents (spawned via `sessions_spawn`) have hard-enforced protections:
- `sessions_spawn` is denied for sub-agents → no nested fan-out
- `sessions_send` is denied for sub-agents → no triggering other agents
- `runTimeoutSeconds` kills runaway sub-agents automatically

**Layer 4 — Per-agent tool scoping (configuration enforcement):**
Agents that should never communicate can have `sessions_send` denied at the config level:

```json
{
  "id": "hr",
  "tools": {
    "deny": ["sessions_send"]
  }
}
```

### 4.5 Sub-Agents

Sub-agents are background tasks spawned via `sessions_spawn`. They run in isolated sessions, do their work, and announce results back when finished. Sprint Spider uses sub-agents heavily for pipeline execution.

**Key properties:**
- Run on a dedicated queue lane (`subagent`) — don't block main conversation
- Cannot spawn their own sub-agents (no nested fan-out)
- Cannot use `sessions_send`, `sessions_list`, `sessions_history` (no agent coordination)
- Have configurable timeouts
- Can use a different (cheaper) model than the parent agent
- Auto-archive after configurable period (default: 60 minutes)

**Configuration:**

```json
{
  "agents": {
    "defaults": {
      "subagents": {
        "model": "minimax/MiniMax-M2.1",
        "maxConcurrent": 4,
        "archiveAfterMinutes": 60
      }
    },
    "list": [
      {
        "id": "sprint",
        "subagents": {
          "model": "anthropic/claude-sonnet-4",
          "allowAgents": ["frontend", "backend", "solidity"]
        }
      }
    ]
  }
}
```

---

## 5. Memory System

### 5.1 Design Philosophy

Memory in the Zoo follows the principle: **files are the source of truth, search is an accelerator.**

Agents wake up fresh each session. Their continuity comes from reading files. Vector search helps them find relevant context without reading everything, but the markdown files are always the canonical record.

### 5.2 OpenClaw Built-in Memory (Primary)

OpenClaw's built-in memory system is the primary recall mechanism. It indexes markdown files in the agent's workspace and provides semantic + keyword search.

**How it works:**
- Watches `MEMORY.md` and `memory/**/*.md` for changes
- Chunks files (~400 tokens, 80-token overlap)
- Embeds chunks using configured provider (local GGUF, OpenAI, Gemini, or Voyage)
- Stores in per-agent SQLite at `~/.openclaw/memory/<agentId>.sqlite`
- Supports hybrid search (BM25 keyword + vector similarity)
- Tools: `memory_search` (semantic retrieval) and `memory_get` (read specific file)

**Configuration:**

```json
{
  "agents": {
    "defaults": {
      "memorySearch": {
        "enabled": true,
        "provider": "openai",
        "model": "text-embedding-3-small",
        "query": {
          "hybrid": {
            "enabled": true,
            "vectorWeight": 0.7,
            "textWeight": 0.3
          }
        }
      }
    }
  }
}
```

**What gets indexed:**
- `MEMORY.md` — long-term curated memory
- `memory/YYYY-MM-DD.md` — daily logs
- Any additional markdown files in the workspace

**When agents use it:**
- Recalling past decisions ("what did we decide about the Lynex liquidation logic?")
- Finding relevant context from past conversations
- Searching for specific patterns or approaches that worked before

### 5.3 Git-Native Markdown (Permanent Records)

While OpenClaw's built-in memory handles session-to-session recall, some information must be **permanent, human-readable, and version-controlled**. This is what git-native markdown brain repos are for.

**What goes in git-native files (not just memory search):**

| File | Purpose | Example Content |
|------|---------|----------------|
| `MEMORY.md` | Curated long-term facts | Company decisions, conventions, architectural patterns |
| `memory/YYYY-MM-DD.md` | Daily session logs | What happened today, open loops, context |
| `hr/team.md` | Team directory | Names, roles, contact info |
| `hr/pto.md` | PTO records | Leave dates, balances — must survive forever |
| `hr/birthdays.md` | Birthdays | Never lose this data |
| `conventions/` | Coding standards | Per-repo patterns, style guides |
| `decisions/` | Architectural decisions | ADR-style records of why we chose X over Y |

**Rule of thumb:** If a human might need to read it directly, or it must never be lost, it goes in a git-committed file. If it's contextual recall for the AI, OpenClaw's memory search handles it.

**Git-native files are also indexed by memory search** — you get the best of both worlds. The file is the permanent record; the search index makes it retrievable by meaning.

### 5.4 When to Use What

| Scenario | Mechanism |
|----------|-----------|
| "What did we discuss about X last week?" | `memory_search` (semantic retrieval) |
| "When is Alice's birthday?" | Git file (`hr/birthdays.md`) + `memory_search` finds it |
| "What's our convention for API error handling?" | Git file (`conventions/api.md`) + `memory_search` |
| Agent needs to remember a preference mid-session | Write to `memory/YYYY-MM-DD.md` → indexed automatically |
| Recording a permanent team decision | Write to `MEMORY.md` or `decisions/` → committed to git |
| PTO approval for next month | Write to `hr/pto.md` → committed to git, human-readable |

### 5.5 Future: External Semantic Memory

If the built-in system hits scale limits (thousands of documents, cross-agent knowledge bases), options include:

- **QMD backend** — OpenClaw's experimental local-first search sidecar (BM25 + vectors + reranking). No cloud dependency. Already supported in config (`memory.backend = "qmd"`).
- **External vector DB** — Pinecone, Weaviate, or similar for cross-agent shared knowledge. Would require a custom integration.
- **Hindsight (Vectorize SaaS)** — Third-party long-term memory service. Adds vendor dependency but handles scale automatically.

For now, the built-in system is sufficient. Revisit when the Zoo has been running for 3+ months and memory volume becomes a concern.

---

## 6. Task Pipeline (Sprint Spider)

### 6.1 Overview

Sprint Spider manages the coding task lifecycle — from a shaped brief to a merged PR. It operates as a process specialist, not a domain expert. It doesn't understand what "fix the liquidation threshold" means technically — it trusts the domain agent to shape a good brief and then drives that brief through the pipeline.

### 6.2 Task Lifecycle

```
CONVERSATION → BRIEF → WORKSPACE_SETUP → PLANNING → PLAN_REVIEW →
  EXECUTING → VALIDATING → QA → CODE_REVIEW → MERGED → CLEANUP
```

**Detailed flow:**

1. **CONVERSATION** — A user talks with a domain specialist (e.g., Frontend Falcon) in their Discord channel. The specialist understands the problem, asks clarifying questions, and shapes the task into a well-defined brief. This is conversational and natural — no forms, no commands.

2. **BRIEF** — The domain specialist hands the brief to Sprint Spider via `agentToAgent`. The brief includes: what to change, which repo, why, acceptance criteria, and any constraints. Sprint Spider creates an internal task record.

3. **WORKSPACE_SETUP** — Sprint Spider spawns a sub-agent that:
   - Clones the target repo (if not already cached)
   - Creates a git worktree for task isolation
   - Detects Node version from `.nvmrc`, `.node-version`, or `package.json#engines`
   - Detects package manager from lockfiles
   - Installs dependencies
   - Reports workspace metadata back to Sprint Spider

4. **PLANNING** — Sprint Spider spawns a sub-agent running OpenCode to analyze the codebase and generate an implementation plan. The plan is a structured markdown file covering: files to modify, approach, test strategy, and risks.

5. **PLAN_REVIEW** — The plan is submitted as a draft GitHub PR for human review. The developer reviews on GitHub — approves, requests changes, or rejects. Sprint Spider monitors the PR status.

6. **EXECUTING** — On approval, Sprint Spider spawns a sub-agent running OpenCode to execute the plan. The sub-agent writes code, creates files, and modifies existing code per the plan.

7. **VALIDATING** — Sprint Spider spawns a sub-agent to run pre-merge validation:
   - Linting (`lint` script from package.json)
   - Type checking (if applicable)
   - Unit/integration tests (`test` script from package.json)
   - Build verification (`build` script from package.json)
   - On failure: automatic retry with error output as context (up to 3 attempts)
   - On repeated failure: escalate to the domain specialist

8. **QA** — Human testing gate. For frontend changes: developer tests via preview deployment or local. For backend: API testing against staging. For contracts: test suite review. Issues found are fed back to Sprint Spider, which spawns a fix sub-agent. The task loops back to EXECUTING.

9. **CODE_REVIEW** — PR is moved from draft to ready-for-review. Developer reviews code on GitHub. Comments trigger context injection back into a fix sub-agent.

10. **MERGED** — PR merged (human action). Sprint Spider updates task state.

11. **CLEANUP** — Worktree removed, branch cleaned up, task archived.

### 6.3 Task State Machine

```
           ┌──────────────┐
           │ CONVERSATION  │  Domain specialist + user (natural)
           └──────┬───────┘
                  │  specialist shapes brief
           ┌──────▼───────┐
           │    BRIEF      │  agentToAgent → Sprint Spider
           └──────┬───────┘
                  │
           ┌──────▼───────┐
           │  WORKSPACE    │  sub-agent: clone, worktree, deps
           │    SETUP      │
           └──────┬───────┘
                  │
           ┌──────▼───────┐
           │   PLANNING    │  sub-agent: OpenCode analysis
           └──────┬───────┘  timeout → ESCALATED
                  │
           ┌──────▼───────┐
           │ PLAN_REVIEW   │  draft PR for human review
           └──────┬───────┘  rejected → PLANNING (with feedback)
                  │ approved
           ┌──────▼───────┐
           │  EXECUTING    │  sub-agent: OpenCode code generation
           └──────┬───────┘  timeout → ESCALATED
                  │
           ┌──────▼───────┐
           │  VALIDATING   │  sub-agent: lint + test + build
           └──────┬───────┘  fail → EXECUTING (retry, max 3)
                  │ pass
           ┌──────▼───────┐
           │      QA       │  human testing
           └──────┬───────┘  issues → EXECUTING (with feedback)
                  │ pass
           ┌──────▼───────┐
           │ CODE_REVIEW   │  PR ready for review
           └──────┬───────┘  changes requested → EXECUTING
                  │ approved
           ┌──────▼───────┐
           │    MERGED     │  human merges PR
           └──────┬───────┘
                  │
           ┌──────▼───────┐
           │   CLEANUP     │  worktree, branch, archive
           └──────────────┘

    At any point:  /abort → ABORTED → CLEANUP
```

### 6.4 Complexity Assessment

Sprint Spider auto-assesses task complexity from the brief to determine the appropriate workflow:

| Complexity | Example | Workflow |
|------------|---------|---------|
| **Low** | Typo fix, dependency update, small bug | Skip plan review, auto-validate, straight to code review |
| **Medium** | New API endpoint, UI component, test suite | Full planning + review cycle |
| **High** | Architecture change, new service, cross-repo | Extended planning, mandatory human involvement throughout |

### 6.5 Human-in-the-Loop Gates

| Gate | Channel | Who | Action |
|------|---------|-----|--------|
| Task shaping | Discord channel | Developer + domain specialist | Conversational — define what to build |
| Plan review | GitHub PR (draft) | Developer | Approve, request changes, or reject |
| QA testing | Preview / staging | Developer or QA | Manual testing, report issues |
| Code review | GitHub PR | Developer | Review code, approve, or request changes |
| Merge | GitHub | Developer | Merge the PR |
| Abort | Discord | Anyone | `/abort <task-id>` — cancels task, cleans up |

### 6.6 Concurrency

Sprint Spider manages concurrent tasks using OpenClaw's sub-agent system:

- **Max concurrent sub-agents:** Configurable (default: 8, recommend starting with 4)
- **Queue lane:** Sub-agents run on a dedicated `subagent` lane, separate from main agent queues
- **Isolation:** Each task gets its own git worktree — no workspace collisions
- **Cost control:** Sub-agents can use a cheaper model for mechanical work (validation, workspace setup)

### 6.7 Error Handling

| Scenario | Response |
|----------|----------|
| Planning timeout (sub-agent exceeds `runTimeoutSeconds`) | Sprint Spider aborts sub-agent, notifies domain specialist, retries with simplified prompt |
| Execution timeout | Same — abort, notify, offer to retry or escalate |
| Test failure (1st–3rd attempt) | Sprint Spider spawns new sub-agent with test output as context. Retries up to 3 times. |
| Test failure (4th attempt) | Escalates to domain specialist via `agentToAgent` with full failure context |
| Sub-agent loop/confusion | `runTimeoutSeconds` kills it. Sprint Spider notifies and offers manual intervention. |
| Gateway restart | Sub-agent pending announce work is lost (best-effort). Sprint Spider checks git state and PR status to determine where to resume. |

### 6.8 Recovery on Restart

When the system restarts (container restart, crash, deploy), active sub-agent work is lost. Sprint Spider recovers by inspecting durable state:

1. **For each in-flight task, check:**
   - Git state (branch exists? last commit? uncommitted changes?)
   - GitHub PR status (draft? approved? review comments?)
   - Worktree status (exists? clean? has plan files?)

2. **Based on state, either:**
   - **Resume** — Spawn a new sub-agent with context injection (task brief, plan content, git diff of work done so far, and specific instructions for what remains)
   - **Escalate** — Notify the domain specialist via Discord that manual intervention is needed
   - **Clean up** — Task was in a terminal state; remove worktree and archive

Sprint Spider logs recovery actions to its brain repo for audit.

---

## 7. Tech Stack Coverage

### 7.1 Supported Stacks

The Zoo is designed to be stack-agnostic within the JavaScript/TypeScript ecosystem, with specific support for Solidity smart contracts.

| Layer | Technology | Package Manager | Node Version | Notes |
|-------|-----------|----------------|--------------|-------|
| Smart Contracts | Solidity (Hardhat/Foundry) | npm or yarn | 18–20 | Compilation, testing, deployment scripts |
| Backend | NestJS + TypeScript | npm or pnpm | 18–22 | MongoDB, REST APIs, services |
| Frontend | Next.js + React + TypeScript | npm or pnpm | 18–22 | App Router, Tailwind, component libraries |
| Subgraphs | AssemblyScript / TypeScript | npm | 18–20 | The Graph protocol, event indexing |
| Shared Libraries | TypeScript | varies | varies | Shared types, utils across repos |

### 7.2 Repo Onboarding

Repos should be **self-describing**. The Zoo infers configuration from standard project files — `README.md`, `AGENTS.md`, `package.json`, lockfiles, and version files.

**There is no manually-maintained per-repo configuration file.** Instead:

1. **Auto-inference on first encounter.** When Sprint Spider receives a task for a repo it hasn't seen, the workspace setup sub-agent reads standard files to infer: Node version, package manager, test/build/lint commands, tech stack, and project structure.

2. **Conversational refinement.** If inference misses something (custom test setup, unusual build steps, environment requirements), the developer tells the domain specialist and it updates the brief for Sprint Spider.

3. **Progressive improvement.** Sprint Spider can be tasked with improving a repo's agentic readiness — creating `AGENTS.md`, updating `README.md`, adding missing scripts, setting up CI.

### 7.3 AGENTS.md Convention

Every repository the Zoo works on should contain an `AGENTS.md` file at its root. This file provides AI agents with project-specific context. OpenCode reads it automatically when a session starts.

**Standard structure:**

```markdown
# Project Name

## Overview
Brief description of what this project does and its role in the ecosystem.

## Architecture
Key architectural decisions, patterns used, file organization.

## Tech Stack
Runtime version, framework, database, key dependencies.

## Coding Standards
Style rules, naming conventions, patterns to follow, anti-patterns to avoid.

## Testing
How to run tests, test framework, coverage expectations.

## Related Repos
Links to other repos this project interacts with.

## Known Issues / Tech Debt
Active issues the agent should be aware of.
```

---

## 8. Security

### 8.1 Per-Agent Tool Restrictions

Each agent can have its own tool allow/deny list via `agents.list[].tools`:

```json
{
  "id": "hr",
  "tools": {
    "allow": ["read", "write", "edit", "exec", "sessions_list", "sessions_history"],
    "deny": ["browser", "gateway"]
  }
}
```

**Recommended restrictions by agent type:**

| Agent | Tools Policy |
|-------|-------------|
| Zoo Keeper | Full access (coordinator needs all tools) |
| Domain specialists (coding) | Full access (need exec, write, edit for OpenCode) |
| HR Horse | Deny `browser`, `gateway`. Allow `sessions_send` for coordination. |
| Marketing Monkey | Deny `gateway`. Allow web search/fetch for research. |
| Sprint Spider | Full access + `sessions_spawn` for sub-agents |
| Sub-agents (Sprint Spider's) | Default denied: `sessions_send`, `sessions_spawn`, `sessions_list`, `sessions_history`, `gateway`, `cron`, `memory_search` |

### 8.2 Sandbox Configuration

For agents handling untrusted input or operating in public-facing channels, OpenClaw supports per-agent sandboxing:

```json
{
  "id": "public-agent",
  "sandbox": {
    "mode": "all",
    "scope": "agent"
  },
  "tools": {
    "allow": ["read"],
    "deny": ["exec", "write", "edit", "apply_patch"]
  }
}
```

All agents run on host within the Docker container by default. Per-agent sandboxing is enabled for agents handling untrusted input or operating in public-facing channels.

### 8.3 Secrets Management

| Concern | Mitigation |
|---------|-----------|
| Agent reads secrets from other workspaces | Each agent has isolated workspace; default cwd is workspace, not root |
| Agent commits secrets | AGENTS.md instructs: "Never commit API keys, .env files, credentials, tokens" |
| Agent pushes to protected branches | GitHub branch protection enforces PR-only merges to main |
| Agent accesses production infrastructure | No production credentials in container. Only GitHub token (repo scope) and LLM API keys. |
| Runaway API costs | Sub-agent timeouts. Cheaper models for mechanical tasks. Usage tracking per agent. |

---

## 9. Integration Points

### 9.1 Discord

- **Inbound:** Task conversations, domain questions, QA feedback, abort commands
- **Outbound:** Task status notifications, plan ready alerts, completion notices, error escalations
- **Channels:** One per agent + general (mention required for Zoo Keeper)
- **DMs:** Supported via pairing (per-agent main session)

### 9.2 GitHub

- **Inbound:** PR approval status, review comments
- **Outbound:** Branch creation, commits, PR creation (draft → ready), PR description updates
- **Auth:** `GITHUB_TOKEN` with `repo` scope, stored as environment variable
- **Account:** [DeFiZooKeeper](https://github.com/DeFiZooKeeper)
- **Git identity:** `Zoo Keeper <zookeeper@defizoo.ai>`

### 9.3 ClickUp

- **Inbound:** Task creation events (tag `ai-task` or status change to `AI Queue`)
- **Outbound:** Task status updates, completion notes
- **Integration:** Via OpenClaw MCP or webhook

### 9.4 Coolify / Preview Deployments

- **Purpose:** Deploy PR branches as live preview URLs for QA testing
- **Integration:** Coolify API with workspace token
- **DNS:** Wildcard subdomain (e.g., `*.preview.defizoo.fi`)
- **Lifecycle:** Created when PR reaches QA state, torn down on merge/abort

---

## 10. Developer Interaction Modes

The Zoo supports three modes of working. Developers naturally move between them depending on the task:

### 10.1 Orchestrated Mode (via the Zoo)

For tasks that benefit from the full automated pipeline — new features, bug fixes across unfamiliar code, boilerplate-heavy work, subgraph generation, etc.

1. Developer opens a conversation with a domain specialist in Discord
2. Specialist shapes the brief and hands off to Sprint Spider
3. Developer gets notified when plan is ready → reviews on GitHub
4. Developer (or QA) tests the output via preview deployment or staging
5. Developer reviews the code PR → approves and merges

### 10.2 Direct Mode (Cursor / Claude Code locally)

For tasks where the developer needs hands-on control — complex Solidity logic, debugging production issues, rapid prototyping, code they want to deeply understand.

1. Developer opens the repo in Cursor or Claude Code
2. Uses inline AI assistance
3. Pushes code and creates PR through normal git workflow
4. No Zoo involvement

### 10.3 Hybrid Mode

For complex multi-step work — the developer uses the Zoo for scaffolding (generate a NestJS service skeleton, build UI components from specs, create subgraph boilerplate) and then works directly in Cursor for the critical logic, edge cases, and polish.

The Zoo doesn't enforce any single mode. It is a force multiplier for the work that benefits from automation, not a mandatory workflow gate.

---

## 11. Observability & Metrics

### 11.1 What to Track

| Metric | Purpose |
|--------|---------|
| Cycle time (brief → merged) | How fast tasks move through the pipeline |
| Planning accuracy | How often plans are approved without revision |
| Validation pass rate | How often code passes lint/test/build on first attempt |
| QA pass rate | How often QA passes without sending back for fixes |
| Cost per task | Token usage per task (sub-agents + orchestration) |
| Tasks per week | Throughput |
| Agent-to-agent message count | Communication overhead (watch for loop indicators) |

### 11.2 How to Access

- **Discord:** Ask Zoo Keeper for status updates and metrics summaries
- **Sub-agents:** `/subagents list` shows active and completed background tasks with runtime and token usage
- **Gateway logs:** `docker compose exec openclaw openclaw logs` for system-level monitoring
- **Memory files:** Sprint Spider logs task outcomes to its brain repo for historical reference

---

## 12. Configuration Reference

### 12.1 openclaw.json

```json
{
  "gateway": { "mode": "local", "auth": { "mode": "token" } },
  "agents": {
    "defaults": {
      "model": { "primary": "openrouter/qwen/qwen3-coder-next" },
      "memorySearch": {
        "enabled": true,
        "query": {
          "hybrid": {
            "enabled": true,
            "vectorWeight": 0.7,
            "textWeight": 0.3
          }
        }
      }
    },
    "list": [
      {
        "id": "coordinator",
        "default": true,
        "identity": { "name": "Zoo Keeper", "emoji": "🦍" },
        "workspace": "/home/node/.openclaw/workspace"
      },
      {
        "id": "frontend",
        "identity": { "name": "Frontend Falcon", "emoji": "🦅" },
        "workspace": "/home/node/.openclaw/workspace-frontend"
      },
      {
        "id": "backend",
        "identity": { "name": "API Alligator", "emoji": "🐊" },
        "workspace": "/home/node/.openclaw/workspace-backend"
      },
      {
        "id": "solidity",
        "identity": { "name": "Solidity Shark", "emoji": "🦈" },
        "workspace": "/home/node/.openclaw/workspace-solidity"
      },
      {
        "id": "hr",
        "identity": { "name": "HR Horse", "emoji": "🐴" },
        "workspace": "/home/node/.openclaw/workspace-hr"
      },
      {
        "id": "marketing",
        "identity": { "name": "Marketing Monkey", "emoji": "🐵" },
        "workspace": "/home/node/.openclaw/workspace-marketing"
      },
      {
        "id": "sprint",
        "identity": { "name": "Sprint Spider", "emoji": "🕷️ " },
        "workspace": "/home/node/.openclaw/workspace-sprint",
        "subagents": {
          "model": "anthropic/claude-sonnet-4",
          "maxConcurrent": 4,
          "allowAgents": ["frontend", "backend", "solidity"]
        }
      }
    ]
  },
  "tools": {
    "agentToAgent": {
      "enabled": true,
      "allow": ["coordinator", "frontend", "backend", "solidity", "hr", "marketing", "sprint"]
    },
    "web": { "search": { "enabled": true }, "fetch": { "enabled": true } },
    "exec": { "pathPrepend": ["/usr/local/bin"] }
  },
  "bindings": [
    { "agentId": "frontend", "match": { "channel": "discord", "peer": { "kind": "channel", "id": "<frontend-channel-id>" } } },
    { "agentId": "backend", "match": { "channel": "discord", "peer": { "kind": "channel", "id": "<backend-channel-id>" } } },
    { "agentId": "solidity", "match": { "channel": "discord", "peer": { "kind": "channel", "id": "<solidity-channel-id>" } } },
    { "agentId": "hr", "match": { "channel": "discord", "peer": { "kind": "channel", "id": "<hr-channel-id>" } } },
    { "agentId": "marketing", "match": { "channel": "discord", "peer": { "kind": "channel", "id": "<marketing-channel-id>" } } },
    { "agentId": "sprint", "match": { "channel": "discord", "peer": { "kind": "channel", "id": "<sprint-channel-id>" } } },
    { "agentId": "coordinator", "match": { "channel": "discord", "peer": { "kind": "channel", "id": "<coordinator-channel-id>" } } }
  ],
  "channels": {
    "discord": {
      "enabled": true,
      "dm": { "enabled": true, "policy": "pairing" },
      "guilds": {
        "<GUILD_ID>": {
          "requireMention": true,
          "channels": {
            "<frontend-channel-id>": { "allow": true, "requireMention": false },
            "<backend-channel-id>": { "allow": true, "requireMention": false },
            "<solidity-channel-id>": { "allow": true, "requireMention": false },
            "<hr-channel-id>": { "allow": true, "requireMention": false },
            "<marketing-channel-id>": { "allow": true, "requireMention": false },
            "<sprint-channel-id>": { "allow": true, "requireMention": false },
            "<coordinator-channel-id>": { "allow": true, "requireMention": false },
            "*": { "allow": true, "requireMention": true }
          }
        }
      },
      "historyLimit": 30
    }
  }
}
```

### 12.2 Docker Compose Volumes

```yaml
volumes:
  # Config (read-only)
  - ./state:/mnt/state:ro
  # Coordinator workspace
  - ./workspace:/home/node/.openclaw/workspace
  # Brain repos → agent workspaces
  - ./brains/frontend:/home/node/.openclaw/workspace-frontend
  - ./brains/backend:/home/node/.openclaw/workspace-backend
  - ./brains/solidity:/home/node/.openclaw/workspace-solidity
  - ./brains/hr:/home/node/.openclaw/workspace-hr
  - ./brains/marketing:/home/node/.openclaw/workspace-marketing
  - ./brains/sprint:/home/node/.openclaw/workspace-sprint
```

### 12.3 Environment Variables

| Variable | Purpose | Required |
|----------|---------|----------|
| `ANTHROPIC_API_KEY` | Anthropic API access | At least one LLM key |
| `OPENAI_API_KEY` | OpenAI API access (also used for embeddings) | Recommended for memory search |
| `OPENROUTER_API_KEY` | OpenRouter multi-provider access | At least one LLM key |
| `DISCORD_BOT_TOKEN` | Discord bot authentication | Yes |
| `GITHUB_TOKEN` | GitHub repo access (`repo` scope) | Yes |
| `GITHUB_ORG` | GitHub account name | Yes (`DeFiZooKeeper`) |
| `OPENCLAW_GATEWAY_TOKEN` | Gateway auth for Control UI and health checks | Yes |
| `OPENCLAW_GATEWAY_BIND` | Gateway bind mode (`lan` for Docker) | Yes |
| `OPENCLAW_PORT` | Gateway port (default: `18789`) | No |
| `GOG_KEYRING_PASSWORD` | Credential/keyring flows | Yes |
| `TZ` | Timezone | No (default: `UTC`) |

---

## 13. Capabilities & Success Criteria

### 13.1 Core Capabilities

| # | Capability | Status |
|---|-----------|--------|
| 1 | Multi-agent routing (Zoo Keeper + domain specialists + Sprint Spider) | Built |
| 2 | Discord channel binding per agent | Built |
| 3 | Agent-to-agent communication (`agentToAgent`) with hub-and-spoke routing | Built |
| 4 | Group chat mention patterns | Built |
| 5 | OpenCode CLI for code changes | Integrated |
| 6 | Brain repo structure with template-based provisioning | Partially built |
| 7 | Docker Compose deployment | Built |
| 8 | Git identity and GitHub auth | Built |
| 9 | Setup scripts (`setup.sh`, `setup-brains.sh`) | Built |
| 10 | Stub brain pattern for bootstrapping | Built |
| 11 | Sprint Spider pipeline (brief → workspace → plan → execute → validate → PR) | Not started |
| 12 | Sub-agent concurrency with loop protection | Not started |
| 13 | Hybrid memory (OpenClaw vector search + git-native permanent records) | Partially built |
| 14 | Complexity-based workflow adjustment | Not started |
| 15 | ClickUp integration (task intake via tag/status) | Not started |
| 16 | GitHub Issue intake (label trigger) | Not started |
| 17 | Preview deployments via Coolify API | Not started |
| 18 | Per-agent tool scoping | Not started |
| 19 | Performance metrics (cycle time, cost per task) | Not started |
| 20 | Repo onboarding workflow (auto-audit, AGENTS.md generation) | Not started |
| 21 | Recovery on restart (git state + PR status inspection) | Not started |
| 22 | Developer interaction modes (orchestrated / direct / hybrid) | Designed |

### 13.2 Success Criteria

The system is production-ready when:

1. A developer can talk to a domain specialist, shape a task, and have Sprint Spider autonomously produce a reviewable PR
2. The pipeline handles validation (lint, test, build) with auto-retry on failure
3. Plan review and code review gates work through GitHub PRs
4. The entire flow is observable via Discord notifications
5. Agent-to-agent communication is loop-free and reliable
6. Each specialist maintains persistent memory across sessions
7. New agents can be provisioned from template in under 30 minutes
8. If something goes wrong, `/abort` cleans up and notifies

---

## 14. Glossary

| Term | Definition |
|------|-----------|
| **OpenClaw** | Open-source AI gateway. Hosts multiple agents, routes messages from Discord/Telegram/WhatsApp, provides tool execution. |
| **Zoo Keeper** | The coordinator agent (🦍). Routes messages, coordinates cross-domain work, provisions new agents. |
| **Sprint Spider** | The pipeline agent (🕷️ ). Manages the coding task lifecycle from brief to merged PR. |
| **Brain repo** | A git repository that serves as an agent's persistent workspace. Contains AGENTS.md, SOUL.md, memory files, and domain knowledge. |
| **Template brain** | A GitHub template repository (`DeFiZooKeeper/template-brain`) used to bootstrap new agent brains with standard file structure and placeholders. |
| **Stub brain** | A minimal AGENTS.md created by `setup-brains.sh` when the actual brain repo doesn't exist yet. Instructs the agent to request brain creation. |
| **agentToAgent** | OpenClaw tool (`sessions_send`) that lets one agent send a message to another agent's session. Used for inter-agent coordination. |
| **Sub-agent** | A background task spawned via `sessions_spawn`. Runs in an isolated session, announces results when done. Cannot spawn nested sub-agents. |
| **Hub-and-spoke** | Communication pattern where specialists route through Zoo Keeper rather than talking to each other directly. Prevents loops. |
| **OpenCode** | AI coding CLI tool. Agents use `opencode run` to make code changes: edits, branch creation, commits, and PRs. |
| **Worktree** | Git feature allowing multiple working directories from a single repo clone. Each task gets its own worktree for isolation. |
| **memory_search** | OpenClaw built-in tool for semantic + keyword search over an agent's markdown memory files. |
| **Coolify** | Self-hosted PaaS for container orchestration. Handles preview deployments of PR branches. |
| **DeFiZoo** | The organization. Operates VaultEdge, Felines, and ApeBond — three interconnected DeFi protocols. |
| **Felines** | Family of MetaDEX deployments: Lynex, Catex, Pumex, Snap, Ocelex. |
| **ApeBond** | Decentralized bonding platform where users buy discounted tokens that vest over time. |
| **VaultEdge** | Decentralized borrowing protocol for borrowing against a wide range of assets. |

---

## Appendix A: Comparison with Carpintechno Approach

The Carpintechno spec (v1.1, Feb 2026) proposes a **single monolithic orchestrator** that delegates to generic coding sub-agents (Prometheus/Atlas via OHO). The Zoo takes a different approach:

| Aspect | Carpintechno | The Zoo |
|--------|-------------|---------|
| Architecture | Single orchestrator + generic coding agents | Team of domain specialists + pipeline agent |
| Memory | Hindsight (vector DB SaaS) + tasks.json | Git-native markdown + OpenClaw built-in vector search |
| Routing | Command-based (`/code repo "task"`) | Channel-based (talk in domain channel) |
| Scope | Coding pipeline only | Full org (code, HR, marketing, coordination) |
| Scaling | Rewrite the monolithic prompt | Add a brain from template |
| Process rigor | 13-state machine in one agent | Pipeline logic isolated in Sprint Spider |
| Communication | Top-down delegation only | Hub-and-spoke with lateral coordination |
| Personality | Minimal (orchestrator + HR bot) | Full identity per agent (animal theme, prefixes) |
| Infrastructure | OpenCode Server (serve mode) + Pipe Daemon + OHO | OpenClaw-native sub-agents + OpenCode CLI |

**What the Zoo adopts from Carpintechno:**
- Structured task lifecycle with explicit quality gates
- Git worktree isolation per task
- Auto-retry on validation failure (up to 3 attempts)
- Complexity-based workflow adjustment
- Preview deployments via Coolify
- Repo onboarding and agentic-readiness audits

**What the Zoo does differently:**
- Domain expertise distributed across specialists, not centralized in one brain
- Pipeline agent (Sprint Spider) is one specialist among many, not the entire system
- Memory is git-native and transparent, not a black-box vector DB
- Communication is natural (channel-based) not command-driven
- Agent provisioning is templated and self-replicating

---

## Appendix B: File Structure

```
agent-orchestrator/
├── docker-compose.yml              # Builds + runs OpenClaw
├── .env.example                    # API keys template
├── .env                            # API keys (never committed)
├── setup.sh                        # Interactive setup helper
├── setup-brains.sh                 # Clone/init brain repos
├── ZooKeeperOrchestratorSpec.md    # This document
├── state/
│   └── openclaw.json               # Gateway + agent + Discord config
├── workspace/                      # Zoo Keeper's brain (coordinator)
│   ├── AGENTS.md                   # Coordinator instructions
│   ├── SOUL.md                     # Zoo Keeper identity
│   ├── USER.md                     # Team context
│   ├── TOOLS.md                    # Available tools and notes
│   ├── IDENTITY.md                 # Public identity
│   ├── HEARTBEAT.md                # Periodic check config
│   ├── MEMORY.md                   # Long-term memory
│   ├── README.md                   # Workspace readme
│   └── memory/                     # Daily notes
└── brains/                         # Specialist brain repos (git clones)
    ├── frontend/                   # → DeFiZooKeeper/frontend-brain
    ├── backend/                    # → DeFiZooKeeper/backend-brain
    ├── solidity/                   # → DeFiZooKeeper/solidity-brain
    ├── hr/                         # → DeFiZooKeeper/hr-brain
    ├── marketing/                  # → DeFiZooKeeper/marketing-brain
    └── sprint/                     # → DeFiZooKeeper/sprint-brain
```

---

## Appendix C: Document Roadmap

1. **The Zoo: AI Agent Orchestrator** (this document) — Architecture, capabilities, pipeline design, MVP scope.
2. **AI-Augmented Engineering Playbook** — How the team uses the Zoo day-to-day across all DeFiZoo protocols. Workflows, role definitions, protocol-specific considerations.
3. **Agent Brain Standards** — Template brain specification, AGENTS.md conventions, brain repo maintenance guidelines.
