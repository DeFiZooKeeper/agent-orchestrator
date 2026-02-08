# Roadmap

Phased rollout plan. Each phase builds on the previous one.

---

## Phase 1 — Gateway + Discord + LLM

Get OpenClaw running and talking to you in Discord.

- [ ] Build and start OpenClaw gateway via Docker Compose
- [ ] Configure Discord bot (token, intents, guild invite)
- [ ] Set up at least one LLM provider (Anthropic recommended)
- [ ] Run onboarding wizard
- [ ] Verify: DM the bot on Discord and get a response
- [ ] Configure guild settings (channels, mention requirements, allowlists)

**You're done when:** You can chat with the bot in Discord and it responds intelligently.

---

## Phase 2 — GitHub Integration + Coding Skills

Enable the agent to write code and open pull requests.

- [ ] Add `GITHUB_TOKEN` to `.env`
- [ ] Customize `workspace/AGENTS.md` with your repos and coding preferences
- [ ] Test the `github-code-pr` skill: ask the bot to make a code change
- [ ] Test the `github-pr-review` skill: ask it to review a PR
- [ ] Test the `github-issue-triage` skill: ask it to triage an issue
- [ ] Tweak `workspace/SOUL.md` for safety rules specific to your repos

**You're done when:** You can say "fix the typo in README.md of org/repo" in Discord and get a PR link back.

---

## Phase 3 — Agent Sandboxing

Isolate code execution for security.

- [ ] Enable sandboxing in `state/openclaw.json` (already pre-configured)
- [ ] Build the sandbox image: `docker compose exec openclaw-gateway scripts/sandbox-setup.sh`
- [ ] Test sandboxed execution: ask the bot to run code
- [ ] Configure sandbox resource limits (memory, CPU, network)
- [ ] Review tool allow/deny policies

**You're done when:** Code execution happens in isolated containers, not on the host.

---

## Phase 4 — Custom Skills + Workflows

Extend the agent with your own skills and automation.

- [ ] Write custom skills in `workspace/skills/` (follow the SKILL.md format)
- [ ] Browse [ClawHub](https://clawhub.com) for community skills
- [ ] Set up cron jobs for scheduled tasks (daily reports, monitoring)
- [ ] Configure webhooks for event-driven workflows (GitHub → Discord alerts)
- [ ] Add more Discord channels with different skill sets per channel

**You're done when:** The agent proactively handles tasks and responds to events.

---

## Phase 5 — Hardening + Multi-Agent

Production-grade security and scaling.

- [ ] Restrict Discord guild/channel access with strict allowlists
- [ ] Enable structured logging (JSON format)
- [ ] Set up monitoring for gateway health
- [ ] Configure multiple agents with different personas and tool access
- [ ] Set up agent-to-agent communication for complex workflows
- [ ] Document backup/restore procedures for `state/` directory
- [ ] Token rotation schedule

**You're done when:** The system runs reliably 24/7 with proper monitoring and security.

---

## Future

- Browser automation skills (web scraping, form filling)
- Voice interaction via Telegram/WhatsApp
- Local model support (Ollama, LM Studio)
- Kubernetes deployment (Helm charts)
- Multi-tenant workspaces for team use
