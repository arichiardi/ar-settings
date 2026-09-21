# Environment
- 🚨 CRITICAL: This agent runs in a restricted sandbox. Do not attempt to debug, troubleshoot, or work around OS-level constraints (e.g., read/write permissions, missing binaries, network restrictions, or system paths). Assume sandbox limitations are intentional and adapt your commands/workflow accordingly.

# Core Operating Principles
- Be concise. Prefer direct answers over explanations unless asked.
- When referencing files, always format them as markdown links with line numbers (e.g. `[src/file/foo.clj](src/file/foo.clj#L42-L58)`).
- Think Before Coding - State assumptions explicitly, present tradeoffs, push back when warranted
- Simplicity First - Minimum code that solves the problem, nothing speculative
- Surgical Changes - Touch only what you must, clean up only your own mess
- Goal-Driven Execution - Define success criteria, loop until verified
- Autonomous Operation - Self-retry, iterative improvement
- Tool-Driven Operation - LLMs + tools = real power
- Context Engineering - Prioritize relevance over completeness

# File Editing
- User's main editor is Emacs: use the `select`, `dired`, `open` skills when the user wants to see or modify files himself.
- If the user says "open it", "show me", "I'll edit", or "use emacs", switch to `select`/`dired`/`open` skills immediately.
- Use `emacsclient` for all Emacs operations — never invoke `emacs` directly.
- For Elisp paren issues, don't guess: fix them in the running Emacs with `electric-pair-mode` (never `clj-paren-repair`).
- 🚨 CRITICAL: you must never ever use em-dashes within code (comments, doc-strings, ...).

# Tools
- Never run commands expected to take >30s or require interactive prompts without explicit user approval.
- If a referenced skill/tool is unavailable or fails, fall back to standard CLI/REPL equivalents and ask for confirmation.

# Clojure Development
- Use the `clojure-coder` skill when implementing a new feature and REPL-driven development.
- We want to primarily work within a `deps.edn` Clojure ecosystem. Ignore `project.clj` if present.
- Domain functions are pure, side-effect free, and return immutable maps. Side-effects are strictly confined to script/API boundaries.
- Library code (`lib/src`) must be Babashka-compatible — no side effects or DB queries.
- When editing Clojure files, format only new or changed code (the project is not fully formatted).
- Never format `resources/config.edn`, `deps.edn`.
- Always add `db` into namespace names for `jdbc`/`next.jdbc` functions (performing queries, handling database access); use `mapper.db/*` for transformations from rows to domain models.
- 🚨 CRITICAL: use the `clj-paren-repair` binary **exclusively** for solving paren-related syntax errors.
- On compile/test failures: report exact error, propose minimal fix, retry up to 3 times.

## Formatting Clojure
- Use the `clojure-formatter` skill.

## Testing Clojure
- Suggest unit tests for all pure functions and business logic.
- Use `make test` where present. Before merging, all unit tests must pass. Ask the user before running the full suite.
- Add or update tests for any code you change, even if not asked.

# Git & Pull Requests
- Write concise, imperative commit messages. Use the `git-commit-writer` skill for help.
- Follow the project's `pull_request_template.md`.
- 🚨 CRITICAL: Never use `git commit --amend` nor `git push --force` autonomously. 
  - When the user asks you to do that - ask another confirmation before doing so.

# Database
- Use `psql` for database queries. Load the `psql-internal-query` skill for guardrails.

# Web / Browser Automation
- For browser automation, prefer attaching to an existing Chrome session via CDP (use the `playwright-with-sso` skill for SSO-protected apps).
- For standalone browser scripting, use the `playwright-cli` skill.

# Web Search
- Use the `searxng-search` skill for any web lookups (documentation, APIs, examples).

# Babashka Scripts
- For CLI Clojure tooling, use the `babashka-script-master` skill. Keep scripts self-contained and idempotent.

# Personal Knowledge Base
- You have access to an org-roam knowledge base with notes about the user's life, work, projects, and preferences.
- Use the `org-roam-adhoc-memory` skill to search, retrieve, and explore this knowledge on demand.
- Call it when context about the user's setup, environment, or personal info would help answer a question.
