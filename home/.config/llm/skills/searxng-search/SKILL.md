---
name: searxng-search
description: Web search using a local SearXNG instance. Use for finding documentation, answering factual questions, searching for code examples, or any general web lookup. The endpoint is configured via the SEARXNG_URL environment variable.
---

# Web Search (SearXNG)

Search the web using the SearXNG API. The base URL is stored in the `SEARXNG_URL` environment variable.

## Usage

### Basic search (top 5 results)
```bash
curl -s "$SEARXNG_URL/search?q=$(printf '%s' 'YOUR QUERY' | jq -Rs @uri)&format=json&categories=general" | jq -r '.results[:5] | .[] | "• \(.title)\n  \(.url)\n  \(.content)\n"'
```

### Broader search (top 10 results with snippets)
```bash
curl -s "$SEARXNG_URL/search?q=$(printf '%s' 'YOUR QUERY' | jq -Rs @uri)&format=json&categories=general&engines=google,bing,duckduckgo" | jq -r '.results[:10] | .[] | "• \(.title)\n  \(.url)\n  \(.snippet)\n"'
```

### Search specific categories
Replace `general` with one of: `it`, `science`, `news`, `images`, `videos`, `music`, `files`.

```bash
curl -s "$SEARXNG_URL/search?q=$(printf '%s' 'YOUR QUERY' | jq -Rs @uri)&format=json&categories=news" | jq -r '.results[:5] | .[] | "• \(.title)\n  \(.url)\n  \(.content)\n"'
```

## Notes
- Always URL-encode the query using `jq -Rs @uri` to handle special characters safely.
- Results are returned as JSON with fields: `title`, `url`, `content` (full snippet), and sometimes `engine` or `score`.
- If `SEARXNG_URL` is not set, the search will fail — ask the user to configure it.

