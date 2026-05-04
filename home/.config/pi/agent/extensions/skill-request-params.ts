import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";
import * as fs from "fs";

/**
 * Skill Request Parameters Extension
 *
 * Sets custom provider request parameters (temperature, top_p, top_k, etc.)
 * per skill. Parameters are injected into the provider payload before each request.
 *
 * Detection strategies:
 * 1. Explicit `/skill:name` — detected in `input` handler (before expansion)
 * 2. Expanded `<skill name="...">` block — parsed from `event.prompt` in `before_agent_start`
 * 3. LLM auto-invocation — detected by scanning non-system messages for skill file paths
 *
 * Usage:
 * 1. Define your skill -> requestParams mapping below in SKILL_REQUEST_PARAMS.
 * 2. Skill names must match the 'name' field in your SKILL.md frontmatter.
 * 3. Optional "default" entry: fallback params when no skill is detected.
 *    Omit it entirely to apply no custom params when no skill matches.
 * 4. Test with: pi -e skill-request-params.ts
 * 5. Or place in ~/.pi/agent/extensions/ for auto-discovery.
 */

// ============================================================
// CONFIGURATION: Define per-skill request parameters here
// ============================================================

interface ChatTemplateKwargs {
  enable_thinking?: boolean;
  preserve_thinking?: boolean;
}

interface SkillRequestParams {
  temperature?: number;
  top_p?: number;
  top_k?: number;
  min_p?: number;
  presence_penalty?: number;
  repetition_penalty?: number;
  chat_template_kwargs?: ChatTemplateKwargs;
}

interface SkillRequestEntry {
  params: SkillRequestParams;
  aliases?: string[]; // additional skill names that share these params
}

/**
 * Map skill names (or a canonical name) to their request parameters.
 * Use `aliases` to share params across multiple skills.
 *
 * Optional "default" entry: fallback params applied when no skill is detected.
 * Omit it entirely to apply no custom params when no skill matches.
 */
type SkillParams = {
  temperature: number;
  top_p: number;
  top_k: number;
  min_p: number;
  presence_penalty: number;
  repetition_penalty: number;
  chat_template_kwargs: ChatTemplateKwargs;
};

const SKILL_REQUEST_PARAMS: Record<string, SkillRequestEntry> = {
  "default": {
    params: {
      temperature: 0.7,
      top_p: 0.80,
      top_k: 20,
      min_p: 0.0,
      presence_penalty: 1.5,
      repetition_penalty: 1.0,
      chat_template_kwargs: {
        enable_thinking: true,
        preserve_thinking: false,
      },
    },
  },

  "coder": {
    params: {
      temperature: 0.6,
      top_p: 0.95,
      top_k: 20,
      min_p: 0.0,
      presence_penalty: 0.0,
      repetition_penalty: 1.0,
      chat_template_kwargs: {
        enable_thinking: true,
        preserve_thinking: true,
      },
    },
    aliases: ["clojure-coder", "babashka-script-master"],
  },

  "one-shot": {
    params: {
      temperature: 0.6,
      top_p: 0.95,
      top_k: 20,
      min_p: 0.0,
      presence_penalty: 0.0,
      repetition_penalty: 1.0,
      chat_template_kwargs: {
        enable_thinking: false,
      },
    },
  },

  "clojure-formatter": {
    params: {
      temperature: 0.7,
      top_p: 0.80,
      top_k: 20,
      min_p: 0.0,
      presence_penalty: 1.5,
      repetition_penalty: 1.0,
      chat_template_kwargs: {
        enable_thinking: false,
      },
    },
  },

  "git-commit-writer": {
    params: {
      temperature: 0.7,
      top_p: 0.80,
      top_k: 20,
      min_p: 0.0,
      presence_penalty: 1.5,
      repetition_penalty: 1.0,
      chat_template_kwargs: {
        enable_thinking: true,
        preserve_thinking: false,
      },
    },
  },
};

/**
 * Build a lookup from every skill name (primary + aliases) to its params,
 * and extract the optional default params separately.
 */
function buildLookup(table: Record<string, SkillRequestEntry>): {
  lookup: Record<string, SkillRequestParams>;
  defaultParams: SkillRequestParams | null;
} {
  const lookup: Record<string, SkillRequestParams> = {};
  let defaultParams: SkillRequestParams | null = null;
  for (const [name, entry] of Object.entries(table)) {
    if (name === "default") {
      defaultParams = entry.params;
    } else {
      lookup[name] = entry.params;
      for (const alias of entry.aliases ?? []) {
        lookup[alias] = entry.params;
      }
    }
  }
  return { lookup, defaultParams };
}

const { lookup: PARAMS_LOOKUP, defaultParams: DEFAULT_PARAMS } = buildLookup(SKILL_REQUEST_PARAMS);

/**
 * Merges skill-specific request params into the provider payload.
 */
function applySkillParams(payload: any, params: SkillRequestParams): any {
  const result = { ...payload };

  if (params.temperature !== undefined) {
    result.temperature = params.temperature;
  }
  if (params.top_p !== undefined) {
    result.top_p = params.top_p;
  }
  if (params.top_k !== undefined) {
    result.top_k = params.top_k;
  }
  if (params.min_p !== undefined) {
    result.min_p = params.min_p;
  }
  if (params.presence_penalty !== undefined) {
    result.presence_penalty = params.presence_penalty;
  }
  if (params.repetition_penalty !== undefined) {
    result.repetition_penalty = params.repetition_penalty;
  }
  if (params.chat_template_kwargs !== undefined) {
    result.chat_template_kwargs = params.chat_template_kwargs;
  }

  // Remove top-level enable_thinking — it's handled by chat_template_kwargs
  delete result.enable_thinking;

  return result;
}

function formatParams(params: SkillRequestParams): string {
  const parts: string[] = [];
  if (params.temperature !== undefined) parts.push(`t=${params.temperature}`);
  if (params.top_p !== undefined) parts.push(`pp=${params.top_p}`);
  if (params.top_k !== undefined) parts.push(`tk=${params.top_k}`);
  if (params.min_p !== undefined) parts.push(`mp=${params.min_p}`);
  if (params.presence_penalty !== undefined) parts.push(`pres=${params.presence_penalty}`);
  if (params.repetition_penalty !== undefined) parts.push(`rep=${params.repetition_penalty}`);
  if (params.chat_template_kwargs) {
    const { enable_thinking, preserve_thinking } = params.chat_template_kwargs;
    if (!enable_thinking) parts.push(`th=off`);
    else if (preserve_thinking) parts.push(`th=preserve`);
    else parts.push(`th=on`);
  }
  return parts.join(" ");
}

/**
 * Parse <skill name="..."> block from expanded prompt text.
 * Matches the format pi generates when expanding /skill:name commands:
 *   <skill name="clojure-coder" location="/path/to/SKILL.md">
 */
function parseSkillBlock(prompt: string): string | null {
  const match = prompt.match(/<skill name="([^"]+)"/);
  return match ? match[1] : null;
}

// ============================================================
// Extension entry point
// ============================================================

export default function (pi: ExtensionAPI) {
  let activeSkill: string | null = null;
  let manualOverride = false;
  // Reverse lookup: skill file path -> skill name (populated in before_agent_start)
  let skillPathToName: Map<string, string> = new Map();

  const DEBUG_LOG = "/tmp/skill-request-params-debug.log";
  const DEBUG = false;
  function log(msg: string) {
    if (DEBUG) {
      fs.appendFileSync(DEBUG_LOG, `${new Date().toISOString()} ${msg}\n`);
    }
  }

  // Detect /skill:name in raw input BEFORE expansion swallows it
  pi.on("input", (event, ctx) => {
    activeSkill = null;
    manualOverride = false;
    const match = event.text.match(/\/skill:([a-z0-9-]+)/);
    if (match && PARAMS_LOOKUP[match[1]] !== undefined) {
      activeSkill = match[1];
      manualOverride = true;
      log(`Manual override: ${activeSkill}`);
      ctx.ui.notify(`[skill-request-params] Manual override: ${activeSkill}`, "info");
    }
    return { action: "continue" };
  });

  // Build path->name lookup and detect explicit skill from expanded prompt
  pi.on("before_agent_start", (event, ctx) => {
    const skills = event.systemPromptOptions?.skills;

    // Build reverse path->name lookup from loaded skills
    skillPathToName.clear();
    if (skills && Array.isArray(skills)) {
      for (const skill of skills) {
        const name = typeof skill === "string" ? skill : (skill.name ?? skill.id ?? "");
        const filePath = typeof skill === "object" ? (skill.filePath ?? skill.location ?? "") : "";
        if (name && filePath) {
          skillPathToName.set(filePath, name);
        }
      }
    }
    log(`before_agent_start: skillPathToName has ${skillPathToName.size} entries`);

    // Check for explicit skill invocation in expanded prompt
    // (pi expands /skill:name into <skill name="..."> before this event fires)
    const explicitSkill = parseSkillBlock(event.prompt);
    log(`before_agent_start: parseSkillBlock returned ${explicitSkill ?? "null"}`);
    log(`before_agent_start: prompt preview: ${event.prompt.substring(0, 300)}`);
    if (explicitSkill && PARAMS_LOOKUP[explicitSkill]) {
      activeSkill = explicitSkill;
      manualOverride = true;
      log(`Explicit skill from prompt: ${activeSkill}`);
      return;
    }

    if (!manualOverride) {
      activeSkill = null;
    }
  });

  // Detect LLM auto-invocation: scan non-system messages for skill file references.
  // System prompt includes all skill paths in <available_skills>, so skip it.
  pi.on("before_provider_request", (event, ctx) => {
    if (!activeSkill) {
      const messages = (event.payload as any).messages ?? [];
      // Find the last non-system message (most recent assistant/tool response)
      let lastMsg: any = null;
      for (let i = messages.length - 1; i >= 0; i--) {
        if (messages[i].role !== "system") {
          lastMsg = messages[i];
          break;
        }
      }
      if (lastMsg) {
        const msgStr = JSON.stringify(lastMsg);
        for (const [path, name] of skillPathToName) {
          if (msgStr.includes(path) && PARAMS_LOOKUP[name]) {
            activeSkill = name;
            log(`LLM auto-invoked skill: ${activeSkill}`);
            break;
          }
        }
      }
    }

    // Apply skill params or fallback to default if configured
    const params = activeSkill
      ? PARAMS_LOOKUP[activeSkill]
      : DEFAULT_PARAMS;

    if (params) {
      const modifiedPayload = applySkillParams(event.payload, params);
      const label = activeSkill
        ? `⚡ ${activeSkill}: ${formatParams(params)}`
        : `⚡ default: ${formatParams(params)}`;
      ctx.ui.setStatus("skill-params", label);
      ctx.ui.notify(`[skill-request-params] ${label}`, "info");
      log(`Applied: ${activeSkill ?? "default"}`);
      return modifiedPayload;
    }
    ctx.ui.setStatus("skill-params", "");
    return undefined;
  });

  pi.on("session_shutdown", () => {
    activeSkill = null;
    manualOverride = false;
    skillPathToName.clear();
  });
}
