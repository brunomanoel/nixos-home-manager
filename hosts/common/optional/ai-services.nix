{ pkgs, lib, ... }:

{
  environment.systemPackages = with pkgs; [
    alpaca # native GNOME client for Ollama
  ];

  # Ollama — local LLM inference with CUDA (RTX 2060)
  services.ollama = {
    enable = true;
    package = pkgs.ollama-cuda;
    host = "127.0.0.1";
    port = 11434;
    loadModels = [
      "nomic-embed-text" # easy-memory default
      "embeddinggemma:300m" # local-rag default
    ];
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

  # Open WebUI — web interface for Ollama at http://localhost:8080
  services.open-webui = {
    enable = true;
    host = "127.0.0.1";
    port = 8080;
    environment = {
      OLLAMA_BASE_URL = "http://127.0.0.1:11434";
    };
  };
}
