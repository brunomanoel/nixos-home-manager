# Cloudarm Benchmarks — Oracle ARM A1.Flex (4 cores, 24GB RAM)

Data: 2026-03-15
Kernel: 6.12.76 (NixOS 25.11)

## Embedding Models

Testado com CPU idle, sem concorrência, Ollama restart limpo entre modelos.

| Modelo | Cold | Warm | Dimensão | RAM |
|--------|------|------|----------|-----|
| embeddinggemma:300m | 6.2s | **1.7s** | 768 | ~0.6GB |
| qwen3-embedding:8b | 43.3s | **8.2s** | 4096 | ~6GB |

**Escolhido: embeddinggemma:300m** — recall é frequente, latência acumula.

## Code Description Models (generation)

Testado com CPU idle, modelo warm.

| Modelo | Cold | Warm | RAM |
|--------|------|------|-----|
| qwen2.5-coder:1.5b | 6.3s | **3s** | ~1GB |
| qwen2.5-coder:3b | 13.5s | **3.4s** | ~2GB |
| qwen2.5-coder:7b | 35.6s | **9.2s** | ~4.5GB |
| qwen2.5-coder:14b | 73.8s | **27s** | ~9GB |

**Escolhido: qwen2.5-coder:7b** — bom tradeoff qualidade/velocidade. Se lento, drop para 3b.

## Custo por chunk de indexação

Cada chunk de código requer: 1 generation + 2 embeddings (code + description).

| Combo | Tempo/chunk |
|-------|-------------|
| gemma:300m + coder:1.5b | ~6s |
| gemma:300m + coder:3b | ~6.4s |
| gemma:300m + coder:7b | ~12s |
| gemma:300m + coder:14b | ~30s |
| qwen3:8b + coder:14b | ~45s |

## Notas

- Cold start = primeiro request após carregar modelo do disco para RAM.
- Warm = modelo já na RAM. Com OLLAMA_KEEP_ALIVE=-1, modelos ficam carregados.
- Testes feitos com CPU 100% idle, sem concorrência.
- Sob carga (múltiplos requests paralelos ou indexação ativa), tempos são significativamente maiores.
- 8 requests de embedding em paralelo saturaram os 4 cores e causaram timeouts.
