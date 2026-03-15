{ pkgs, lib, ... }:

{
  # Ollama — local LLM inference with CUDA (RTX 2060)
  services.ollama = {
    enable = true;
    package = pkgs.ollama-cuda;
    host = "127.0.0.1";
    port = 11434;
    loadModels = [
      "qwen3-embedding:0.6b" # local-rag embeddings (1024 dims)
      "qwen2.5-coder:3b" # local-rag descriptions
    ];
    environmentVariables = {
      # Allow 2 parallel requests — embed + coder can run simultaneously
      OLLAMA_NUM_PARALLEL = "2";
      # Flash attention — reduces KV cache VRAM usage (supported on RTX 2060, compute 7.5)
      OLLAMA_FLASH_ATTENTION = "1";
    };
  };

  # Qdrant — local vector database
  services.qdrant = {
    enable = true;
    settings = {
      service = {
        host = "127.0.0.1";
        http_port = 6333;
        grpc_port = 6334;
      };
    };
  };
}
