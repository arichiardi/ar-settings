---
name: searxng-search
description: Web search using a local SearXNG instance. Use for finding documentation, answering factual questions, searching for code examples, or any general web lookup. The endpoint is configured via the SEARXNG_URL environment variable.
---

# Web Search (SearXNG)

Search the web using the SearXNG API. The base URL is stored in the `SEARXNG_URL` environment variable.

## Usage

### Basic search
curl -s "$SEARXNG_URL/search?q=$(printf '%s' "YOUR QUERY" | jq -Rs @uri)&format=json&categories=general"

### Search specific categories
Replace `general` with one of: `it`, `science`, `news`, `images`, `videos`, `music`, `files`.

curl -s "$SEARXNG_URL/search?q=$(printf '%s' "YOUR QUERY" | jq -Rs @uri)&format=json&categories=news"

## Notes
- `jq -Rs @uri` is used **only** for safe URL-encoding. The output is raw JSON.
- Response contains a top-level `results` array. Each item includes `title`, `url`, `content` (snippet), and optionally `engine`/`score`.
- Parse the JSON directly in your LLM context; no post-processing is needed.
- Some engines might fail, but the other results are still valid and should be considered.
- ⚠️ **Mandatory**: SearXNG only returns metadata and short content snippets. If you need the full page content or deeper information, **YOU MUST use a web scraper or fetch tool** to retrieve the complete page from the returned `url` fields.
- If `SEARXNG_URL` is unset, the command will fail. Ask the user to export it first.
