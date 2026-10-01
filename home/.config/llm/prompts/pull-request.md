---
description: Create or modify structured Github Pull Request descriptions, adhering to strict style guidelines and PR templates.
argument-hint: "[DRAFT [LINK_1 LINK_2 ...]]"
---

# Create A ${1:-} Pull Request

Either create or modify github ${1:-} pull requests. You may handle multiple repositories.

Add the following links to the **Links** section of the PR description: ${@:2:-None}

## Style Guidelines

- Separate the PR title from the body with a blank line.
- Capitalize the PR title.
- Do not end the PR title with any punctuation.
- Use the imperative mood in the PR title.
- Do not wrap the body lines.

### PR Title

- The title should start with a present tense verb stating what has been done.
- Do not mention the files that were changed.
- Tone: Do not use emojis.
- If there are no changes, or the input is blank, then return a blank string.

### PR Body

Your job is to write a short, clear description that summarizes the changes.

- Only use the body when it is providing *useful* information.
- Do not repeat information from the PR title in the body.
- Only return the PR description in your response. Do not include any additional meta-commentary about the task.
- Do not include the raw diff output in the PR description.
- Think carefully before you write the PR description.
- Use GitHub-flavored markdown syntax in the body.
- Add "_🤖 AI-generated summary 🤖_" disclaimer at the bottom of the PR body.
- Verify if a pull request template is present in the project and use it as a starting point if found.
  - Possible files:
    - `pull_request_template.md`
    - `docs/pull_request_template.md`
    - `.github/pull_request_template.md`
  - If you don't find any of the above files, use this default:
    ```markdown
    # Problem

    [What problem are you solving?]

    # Solution

    [Summarize what you did to solve it.]

    # Links

    ${@:2}

    [All related PRs needed to understand this PR go here]

    # Testing

    [If no automated tests, explain why and how the feature should be tested.]
    ```

- If the user passes a screenshot path, attach it to the **Testing** section with a brief description (a handful of words) indicating what it is showing. For example:
  `![Login screen updated](path/to/screenshot.png)`

#### Additional Requirements

- For PRs that contain commits unrelated to the primary focus of the PR, include a section titled **Other Relevant Changes** to list those ancillary commits:

  **Other Relevant Changes**
  - commit message title #1
  - commit message title #2

- Do not include author names, commit SHAs, or timestamps in the summary.

## Critical: Handling GitHub Links

- If the user provides a link to `github.com` (e.g., a PR, issue, or commit), you **MUST NEVER** use web search tools (such as `searxng`, `web_search`, or general browser tools).
- You **MUST** use the GitHub CLI (`gh`) or the dedicated GitHub tool available in your environment to retrieve the content directly.

**Example:**

- ❌ **Incorrect**: Using a web search tool to find the title of `https://github.com/org/repo/pull/123`.
- ✅ **Correct**: Executing `gh pr view 123 --json title,body`. Alternatively, but less preferably, the `github` tool can be used to fetch details for `org/repo#123`.

- Include user **GitHub** issue / PR links in the Links section; for other links, ask the user.
  - The link section MUST be a Markdown list.
  - **Never** include auto-closing keywords like "Closes #123", "Fixes #123", or similar references anywhere in the PR. We do not want GitHub to automatically close issues based on commits.
  - Format each link as a Markdown list item (e.g. `- https://...` or `- [title](https://...)`).
  - If no link is passed as input, put `-` in the Links section. Do not fabricate or infer links from project context, filenames, or commit messages.
