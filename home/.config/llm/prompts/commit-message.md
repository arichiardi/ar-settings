---
description: Write concise, imperative Git commit messages adhering to strict style guidelines.
argument-hint: "[LINK_1 LINK_2 ...]"
---

# Write a Commit Message

Write a short, clear commit message that summarizes the changes. You may handle multiple repositories.

## Context

A commit message must explain why you make a change. The diff shows what
changed, not why. Before you write, collect the reason:

- Read every link the user provides.
- Look at related issues, pull requests, and recent commits.
- Read the code and its history.
- Ask the user when the reason is still unclear.

Do not guess the reason.

## Style Guidelines

- Separate the subject from the body with a blank line.
- Try to limit the subject line to 50 characters.
- Capitalize the subject line.
- Do not end the subject line with any punctuation.
- Use the imperative mood in the subject line.
- Wrap the body at 72 characters.

### Subject Rules

- Start with a present tense verb stating what has been done.
- Do not mention the files that were changed.
- Use bullet points for multiple changes.
- Tone: Do not use emojis.
- If there are no changes, or the input is blank, then return a blank string.

### Body Rules

- Always include a brief body that provides context, motivation, or details beyond the subject.
- Explain *why* the change was made, not just *what* was changed.
- Do not repeat information from the subject line in the body.
- Keep the body concise, but do not omit it merely because the subject is clear.

### Output Rules

- Only return the commit message in your response. Do not include any additional meta-commentary.
- Do not include the raw diff output in the commit message.
- Do not include any links in the commit message unless the user explicitly asks you to.
- Think carefully before you write your commit message.

What you write will be passed directly to `git commit -m "[message]"`.

## Links

Links provided: ${@:-None}

If one or more links are provided, read each one **before** writing the commit message. Use their content (PR description, issue summary, commit context, etc.) as additional context to better describe the motivation and intent behind the change. Do not copy text verbatim — synthesize it into the commit message naturally.

## Critical: Handling GitHub Links

- If the user provides a link to `github.com` (e.g., a PR, issue, or commit), you **MUST NEVER** use web search tools (such as `searxng`, `web_search`, or general browser tools).
- You **MUST** use the GitHub CLI (`gh`) or the dedicated GitHub tool available in your environment to retrieve the content directly.
- Use retrieved link content as context to inform the commit message.

**Example:**

- ❌ **Incorrect**: Using a web search tool to find the title of `https://github.com/org/repo/pull/123`.
- ✅ **Correct**: Executing `gh pr view 123 --json title,body`. Alternatively, but less preferably, the `github` tool can be used to fetch details for `org/repo#123`.
