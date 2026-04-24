import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";

/**
 * Skill Request Parameters Extension
 *
 * Sets custom provider request parameters (temperature, top_p, top_k, etc.)
 * per skill. Parameters are injected into the provider payload before each request.
 *
 * Usage:
 * 1. Define your skill -> requestParams mapping below in SKILL_REQUEST_PARAMS.
 * 2. Skill names must match the 'name' field in your SKILL.md frontmatter.
 * 3. Test with: pi -e skill-request-params.ts
 * 4. Or place in ~/.pi/agent/extensions/ for auto-discovery.
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

/**
 * Map skill names to their request parameters.
 *
 * Example (translated from your Clojure config):
 *
 * (:temperature 0.6
 *  :top_p 0.95
 *  :top_k 20
 *  :min_p 0.0
 *  :presence_penalty 0.0
 *  :repetition_penalty 1.0
 *  :chat_template_kwargs (:enable_thinking t :preserve_thinking t))
 */
const SKILL_REQUEST_PARAMS: Record<string, SkillRequestParams> = {
  "one-shot": {
    temperature: 0.7,
    top_p: 0.80,
    top_k: 20,
    min_p: 0.05,
    presence_penalty: 1.5,
    repetition_penalty: 1.0,
  },

  "clojure-coder": {
    temperature: 0.6,
    top_p: 0.95,
    top_k: 20,
    min_p: 0.0,
    presence_penalty: 0.0,
    repetition_penalty: 1.0,
    chat_template_kwargs: {
      enable_thinking: true,
      preserve_thinking: true,
    }
  },
};

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

// ============================================================
// Extension entry point
// ============================================================

export default function (pi: ExtensionAPI) {
  let activeSkill: string | null = null;

  // Detect /skill:name in raw input BEFORE expansion swallows it
  pi.on("input", (event, _ctx) => {
    const match = event.text.match(/\/skill:([a-z0-9-]+)/);
    if (match && SKILL_REQUEST_PARAMS[match[1]] !== undefined) {
      activeSkill = match[1];
    } else {
      activeSkill = null;
    }
    return { action: "continue" };
  });

  // Detect skills loaded via system prompt (agent or auto-loaded)
  pi.on("before_agent_start", (event, _ctx) => {
    const skills = event.systemPromptOptions?.skills;
    if (skills && Array.isArray(skills)) {
      for (const skill of skills) {
        const name = typeof skill === "string" ? skill : skill.name ?? skill.id ?? "";
        if (SKILL_REQUEST_PARAMS[name]) {
          activeSkill = name;
          return;
        }
      }
    }
  });

  pi.on("before_provider_request", (event, ctx) => {
    if (activeSkill && SKILL_REQUEST_PARAMS[activeSkill]) {
      const modifiedPayload = applySkillParams(event.payload, SKILL_REQUEST_PARAMS[activeSkill]);
      const label = `⚡ ${activeSkill}: ${formatParams(SKILL_REQUEST_PARAMS[activeSkill])}`;
      ctx.ui.setStatus("skill-params", label);
      // ctx.ui.notify(`[skill-request-params] modifiedPayload:\n${JSON.stringify(modifiedPayload, null, 2)}`);
      return modifiedPayload;
    }
    ctx.ui.setStatus("skill-params", "");
    return undefined;
  });

  pi.on("session_shutdown", () => {
    activeSkill = null;
  });
}
