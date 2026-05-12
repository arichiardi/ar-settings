# Working Style

## 🔑 Core Operating Principles
- Be concise. Prefer direct answers over explanations unless asked.
- When referencing files, always format them as markdown links with line numbers (e.g. `[src/file/foo.clj](src/file/foo.clj#L42-L58)`).
- Think Before Coding - State assumptions explicitly, present tradeoffs, push back when warranted
- Simplicity First - Minimum code that solves the problem, nothing speculative
- Surgical Changes - Touch only what you must, clean up only your own mess
- Goal-Driven Execution - Define success criteria, loop until verified
- System of Agents Architecture - Team approach, not monolithic
- Autonomous Operation - Self-retry, iterative improvement
- Tool-Driven Operation - LLMs + tools = real power
- Context Engineering - Prioritize relevance over completeness

## File Editing
- User's main editor is Emacs: use the `select`, `dired`, `open` skills when the user wants to see or modify files himself.
- Use `emacsclient` for all Emacs operations — never invoke `emacs` directly.

## Tools
- Never run blocking or long commands without asking first.

## Clojure Development
- Use the `clojure-coder` skill when implementing a new feature and REPL-driven development.
- We want to primarily work within a `deps.edn` Clojure ecosystem. Ignore `project.clj` if present.
- Domain functions are pure, side-effect free, and return immutable maps.
- Library code (usually under `lib/src`) must be Babashka-compatible — no side effects or DB queries.
- When editing Clojure files, format only new or changed code (the project is not fully formatted).
- Never format `resources/config.edn`, `deps.edn`.
- Always add `db` into namespace names for `jdbc`/`next.jdbc` functions (performing queries, handling database access); use `mapper.db/*` for transformations from rows to domain models.
- 🚨 CRITICAL: use the `clj-paren-repair` binary **exclusively** for solving paren-related syntax errors.

### Formatting Clojure
- Use the `clojure-formatter` skill.

### Testing Clojure
- Use `make test` where present.
- Before merging, all unit tests must pass. Ask the user before running the full suite.
- Add or update tests for any code you change, even if not asked.

## Git & Pull Requests
- Write concise, imperative commit messages. Use the `git-commit-writer` skill for help.
- Follow the project's `pull_request_template.md`.
- 🚨 CRITICAL: Never use `git commit --amend` nor `git push --force` autonomously. 
  - When the user asks you to do that - ask another confirmation before doing so.

## Database
- Use `psql` for database queries. Load the `psql-internal-query` skill for guardrails.

## Web / Browser Automation
- For browser automation, prefer attaching to an existing Chrome session via CDP (use the `playwright-with-sso` skill for SSO-protected apps).
- For standalone browser scripting, use the `playwright-cli` skill.

## Web Search
- Use the `searxng-search` skill for any web lookups (documentation, APIs, examples).

## Babashka Scripts
- For CLI Clojure tooling, use the `babashka-script-master` skill. Keep scripts self-contained and idempotent.

## Documentation
- For product requirements or feature specs, use the `prd-writer` skill.
