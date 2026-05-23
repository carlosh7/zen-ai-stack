{
  "provider": {
    "ollama": {
      "npm": "@ai-sdk/openai-compatible",
      "name": "Ollama (local)",
      "options": {
        "baseURL": "http://localhost:11434/v1"
      },
      "models": {
        "qwen2.5-coder:7b": { "name": "Qwen 2.5 Coder 7B" },
        "qwen2.5-vl:7b": { "name": "Qwen 2.5 VL 7B" },
        "llama3.2:3b": { "name": "Llama 3.2 3B" },
        "nomic-embed-text": { "name": "Nomic Embed Text" },
        "deepseek-coder-v2-lite:16b": { "name": "DeepSeek Coder V2 Lite 16B" }
      }
    }
  }
}
