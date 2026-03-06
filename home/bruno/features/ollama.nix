{ pkgs, ... }:
{
  services.ollama = {
    enable = true;
    acceleration = "cuda";
    # loadModels = [ "llama3.1:8b" "deepseek-r1:1.5b" ];
  };

  # home.packages = [ pkgs.alpaca ]; # chat client for ollama
}
