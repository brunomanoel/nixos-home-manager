{
  pkgs,
  lib,
  ...
}:

# Oh My OpenAgent (OmO) — multi-model agent harness for OpenCode.
#
# Repo: https://github.com/code-yeongyu/oh-my-openagent
# npm package: oh-my-opencode (legacy name kept on the npm registry; the
# opencode.json plugin entry prefers "oh-my-openagent" via compat layer).
#
# Single-provider setup (Anthropic OAuth): pin Anthropic on every agent
# that has it in the fallback chain to avoid wasted attempts against
# providers that aren't configured.
#
# No extended thinking variants — keeps token usage predictable.
# Hephaestus is disabled (requires GPT-5.4, no Anthropic fallback).

let
  omoConfig = {
    "$schema" =
      "https://raw.githubusercontent.com/code-yeongyu/oh-my-opencode/dev/assets/oh-my-opencode.schema.json";

    # Hephaestus disabled: chain is single-entry GPT-5.4 with no fallback.
    # Invoking it without a GPT subscription would error hard.
    disabled_agents = [ "hephaestus" ];

    agents = {
      # Main orchestrator
      sisyphus = {
        model = "anthropic/claude-opus-4-7";
      };

      # Strategic planner — Opus default
      prometheus = {
        model = "anthropic/claude-opus-4-7";
      };

      # Gap analyzer — Opus default
      metis = {
        model = "anthropic/claude-opus-4-7";
      };

      # Plan executor — Sonnet, no extended thinking needed
      atlas = {
        model = "anthropic/claude-sonnet-4-6";
      };

      # Category workers — Sonnet
      "sisyphus-junior" = {
        model = "anthropic/claude-sonnet-4-6";
      };

      # Architecture/debug consultant
      oracle = {
        model = "anthropic/claude-opus-4-7";
      };

      # Plan/code reviewer
      momus = {
        model = "anthropic/claude-opus-4-7";
      };

      # Multimodal-Looker: vision via Claude (Opus has vision)
      "multimodal-looker" = {
        model = "anthropic/claude-opus-4-7";
      };

      # Explore/Librarian: Haiku is ideal for grep — fast and cheap
      explore = {
        model = "anthropic/claude-haiku-4-5";
      };
      librarian = {
        model = "anthropic/claude-haiku-4-5";
      };
    };

    # Semantic categories: pinning Anthropic across the board
    categories = {
      quick = {
        model = "anthropic/claude-haiku-4-5";
      };
      "unspecified-low" = {
        model = "anthropic/claude-sonnet-4-6";
      };
      "unspecified-high" = {
        model = "anthropic/claude-opus-4-7";
      };
      writing = {
        model = "anthropic/claude-sonnet-4-6";
      };
      "visual-engineering" = {
        model = "anthropic/claude-opus-4-7";
      };
      deep = {
        model = "anthropic/claude-opus-4-7";
      };
      ultrabrain = {
        model = "anthropic/claude-opus-4-7";
      };
      artistry = {
        model = "anthropic/claude-opus-4-7";
      };
    };

    # Cap parallel calls per provider/model
    background_task = {
      providerConcurrency = {
        anthropic = 2;
      };
      modelConcurrency = {
        "anthropic/claude-opus-4-7" = 2;
        "anthropic/claude-sonnet-4-6" = 3;
        "anthropic/claude-haiku-4-5" = 5;
      };
    };

    # Aggressive truncation helps in long loops
    experimental = {
      aggressive_truncation = true;
    };
  };

  omoConfigFile = (pkgs.formats.json { }).generate "oh-my-openagent.json" omoConfig;
in
{
  # Register the OmO plugin with opencode.
  #
  # Naming: the npm package is published as "oh-my-opencode" but OmO ships
  # an auto-migration that rewrites "oh-my-opencode" -> "oh-my-openagent"
  # in opencode.json on startup. Since home-manager regenerates the file
  # on every switch, we'd loop. We pin the new name; OpenCode resolves it
  # via the package's bin alias.
  #
  # Bump manually when needed.
  programs.opencode.settings.plugin = lib.mkAfter [
    "oh-my-openagent@3.17.12"
  ];

  # Declarative OmO config. The loader accepts both
  # oh-my-openagent.json[c] and the legacy oh-my-opencode.json[c].
  home.file.".config/opencode/oh-my-openagent.json".source = omoConfigFile;
}
