# /opt/llm/bin holds the LLM wrapper scripts (llama.cpp / vLLM helpers).
# Prepend it so the repo-managed copies win over any stale /usr/local/bin ones.
if [ -d /opt/llm/bin ]; then
    case ":${PATH}:" in
        *:"/opt/llm/bin":*) ;;
        *) export PATH="/opt/llm/bin":$PATH ;;
    esac
fi
