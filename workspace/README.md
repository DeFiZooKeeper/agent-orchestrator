# Zoo Keeper Orchestrator

This repository houses the Zoo Keeper Orchestrator, the central AI entity for DeFiZoo. The orchestrator is responsible for managing a team of specialized animal agents, triaging incoming requests, routing tasks to the appropriate specialist agents, and coordinating cross-domain activities.

## Role and Purpose

The Zoo Keeper Orchestrator acts as the public face of DeFiZoo's AI system. Its primary functions include:

- **Triage**: Determining if incoming messages require a specialist agent and delegating tasks accordingly.
- **General Questions**: Handling non-technical questions, project status inquiries, and planning discussions that do not fall under a single specialist's domain.
- **Cross-domain Coordination**: Facilitating collaboration between specialist agents when tasks span multiple domains (e.g., frontend, backend, smart contracts). This involves summarizing requirements, providing context, and synthesizing responses from various agents.
- **Knowledge Broker**: The orchestrator does not possess deep technical expertise in every domain but knows which specialist agent holds the relevant knowledge. It routes inquiries to the correct agent rather than attempting to answer them itself.
- **Agent Creation and Management**: When a new specialist agent is required, the orchestrator is responsible for creating its brain repository, initializing its workspace files, and integrating it into the DeFiZoo system.

## How It Works

The orchestrator operates by:

- **Receiving Inputs**: Monitoring various channels (e.g., Discord) for user requests and inter-agent communications.
- **Delegating Tasks**: Utilizing an `agentToAgent` tool to send messages and tasks to specialist agents, providing necessary context and specific questions.
- **Synthesizing Responses**: Collecting responses from specialist agents and consolidating them into a coherent answer for the original requester.
- **Git-Native Knowledge Management**: All operational knowledge, configurations, and agent definitions are managed through Git commits and Pull Requests, ensuring auditable, reversible, and human-readable changes.

## Specialist Agents

The Zoo Keeper Orchestrator manages a roster of specialist agents, each with expertise in a specific domain:

| Agent ID | Name | Domain |
|----------|------|--------|
| `frontend` | 🦅 Frontend Falcon | React, UI/UX, components, styling, frontend architecture |
| `backend` | 🐊 API Alligator | APIs, databases, server logic, infrastructure, DevOps |
| `solidity` | 🦈 Solidity Shark | Smart contracts, DeFi protocols, on-chain logic, auditing |
| `hr` | 🐴 HR Horse | Hiring, team, processes, people operations |
| `marketing` | 🐵 Marketing Monkey | Brand voice, social media, content, community, campaigns |

## Getting Started

To understand the orchestrator's behavior, personality, and operational guidelines, refer to the following key files in the `workspace/` directory:

- `AGENTS.md`: Operational manual, rules, and workflow for the orchestrator.
- `SOUL.md`: Defines the orchestrator's personality, values, and boundaries.
- `IDENTITY.md`: Details the orchestrator's name, creature, vibe, and emoji.
- `TOOLS.md`: Contains specific tools, agent rosters, and environment details for the orchestrator.
- `USER.md`: Provides context about the human user and team structure.
- `HEARTBEAT.md`: A checklist for periodic checks and monitoring.
- `MEMORY.md`: Stores long-term company/team knowledge, decisions, and learnings.

## Git Configuration

For autonomous commits, the orchestrator is configured to use a specific Git identity:

```bash
git config user.name "Zoo Keeper"
git config user.email "zookeeper@defizoo.ai"
```
