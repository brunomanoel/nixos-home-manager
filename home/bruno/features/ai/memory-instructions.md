## Tooling — when to reach for what

This file is the routing guide for MCP tools available across all sessions.
It is not exhaustive documentation; it tells you which tool to pick first
for a given intent.

---

### Memory MCP (local-rag) + Serena — division of labor

Both indexes the codebase, but each is good at a different thing:

- **Memory MCP (local-rag)** indexes by *meaning* (semantic vectors via Qdrant
  + Ollama). It also persists cross-session memory and the import graph.
- **Serena** indexes by *symbol structure* (LSP per language). It is the
  surgical reader/editor.

Routing table:

| Intent | Tool |
|---|---|
| "Find code about X" (concept, you don't know the name) | `memory_search_code` |
| "Find symbol named X" | `serena.find_symbol` |
| Read a symbol's body | `serena.find_symbol(include_body=true)` |
| Overview of symbols in an unknown file | `serena.get_symbols_overview` |
| Find callers/references by name | `serena.find_referencing_symbols` |
| Find usages of a symbol you found via search_code | `memory_find_usages(uuid)` |
| Read a symbol by UUID without file I/O | `memory_get_symbol(uuid)` |
| Import graph (who imports this, what does it import) | `memory_get_dependencies` |
| Project orientation (tree, entry points, top imports) | `memory_project_overview` |
| Edit / replace a symbol body | `serena.replace_symbol_body` |
| Insert before/after a symbol | `serena.insert_before_symbol` / `insert_after_symbol` |
| Rename a symbol across the codebase | `serena.rename_symbol` |
| Regex over non-code files (yaml, md, configs) | `serena.search_for_pattern` |
| Persistent memory across sessions (decisions, bugs, patterns) | `memory_recall` / `memory_remember` |

Rule of thumb: **start with Memory MCP when you're discovering. Switch to
Serena when you know the symbol and want to read or edit it.**

---

### Recommended workflow for non-trivial tasks

`recall → search_code → think → act → remember`

1. `memory_recall(query)` — past decisions, incidents, patterns.
2. `memory_search_code(query)` — find relevant code by meaning.
   Use `rerank=true` for higher precision when initial results look noisy.
3. Read precisely with `serena.find_symbol(include_body=true)`.
4. Check blast radius with `memory_get_dependencies(...,
   direction="imported_by")` and/or `serena.find_referencing_symbols`.
5. Edit with Serena's symbolic editing tools.
6. `memory_remember(...)` for anything non-obvious you discovered.

Trivial tasks (e.g. "rename this file", "what time is it", a one-line tweak)
do not need the full workflow.

---

### Memory writes — when to call `remember`

Call `memory_remember` whenever you discover something a future session would
have to rediscover from scratch:

- Architecture decisions and the reasoning behind them.
- Root causes of bugs and how they were fixed.
- Undocumented behavior of libraries, services, or the environment.
- Conventions you inferred from the codebase that aren't written anywhere.

Pick `memory_type` honestly: `episodic` for events/incidents (decays),
`semantic` for facts/architecture (long-lived), `procedural` for
patterns/how-to (long-lived).

---

### Mind Palace — `~/mind-palace`

Personal Obsidian vault with notes that span sessions and projects:

- `Daily Notes/` — date-stamped logs, often with client conversations.
- `Projects/` — per-project context, decisions, follow-ups.
- `Knowledge/` — durable notes on tools, concepts, references.
- `Infra/` — homelab, servers, networking notes.
- `Security/` — security posture, credentials hygiene, incident notes.
- `TODO/` — actionable items not yet promoted to a project.

It is plain markdown. Use native `Read` / `Glob` / `Grep` directly — no
special tool. Read it when:

- The user references a client, incident, or past conversation.
- You need context about Bruno's preferences/setup that wouldn't be in a repo.
- You're starting work that touches infra or security topics.

Do not write to `~/mind-palace` without explicit permission — it is curated
manually.

---

### Other MCPs — when to use them automatically

**context / context7** — library/framework documentation. Order:
1. `context.get_docs` — local registry.
2. If missing: `context.search_packages` then `context.download_package`,
   then retry `get_docs`.
3. If still missing: `context7` (Upstash hosted).
Don't ask the user — follow the order automatically.

**fetch** — primary tool for fetching a URL (docs, repos, issues).

**playwright** — fallback to `fetch` whenever the page needs JavaScript
to render (SPAs, client-rendered docs, anything where `fetch` returns a
shell HTML). Also the right tool for any UI inspection / screenshot task.

**chrome-devtools** — Chrome headless. Use proactively when the task
involves:
- Frontend errors or console output (`list_console_messages`).
- Network requests from a real page (`list_network_requests`).
- Performance auditing (`performance_start_trace`,
  `performance_analyze_insight`).
- Lighthouse audits (`lighthouse_audit`).
- Visual checks (`take_screenshot`, `take_snapshot`).

**nixos** — any question about NixOS, Home Manager, nixpkgs, flakes:
search packages/options through this MCP rather than guessing.

**sequential-thinking** — reach for it on complex planning or debugging
where you need to externalize multi-step reasoning.

**git** — direct git operations (`git_status`, `git_diff_*`, `git_log`,
`git_show`, etc.). Faster and more structured than shelling out to
`git` via Bash for read-only inspection.

**github** — GitHub API. Call `get_me` first when permissions are unclear.
Prefer `search_*` for filtered queries, `list_*` for plain listing.

**filesystem** — file ops outside repo conventions. Allowed root:
`/home/bruno/workspaces`.
