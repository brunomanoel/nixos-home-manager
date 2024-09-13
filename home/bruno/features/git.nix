{ pkgs, ... }:
{
  programs.git = {
    enable = true;
    userName = "Bruno Manoel";
    userEmail = "26349861+brunomanoel@users.noreply.github.com";
    signing.signByDefault = true;
    signing.key = "86B002F60764A739";
    extraConfig = ''
      [pull]
        rebase = true
      [branch]
        autosetuprebase = always

    '';
    delta = {
      enable = true;
      options = {
      	features = "side-by-side line-numbers decorations";
      	syntax-theme = "Dracula";
        decorations = {
          commit-decoration-style = "ol";
          hunk-header-decoration-style = "box ul ol";
          hunk-header-style = "file line-number syntax";
          file-decoration-style = "ul";
        };
        interactive = {
          keep-plus-minus-markers = true;
        };
        line-numbers = {
          line-numbers-minus-style = 124;
          line-numbers-plus-style = 28;
        };
        hyperlinks = {
          hyperlinks = true;
          hyperlinks-file-link-format = "vscode://file/{path}:{line}";
        };
      };
    };
  };

  programs.jujutsu = {
    enable = true;
    settings = {
      user = {
        name = "Bruno Manoel";
        email = "26349861+brunomanoel@users.noreply.github.com";
      };
    };
  };

  programs.lazygit = {
    enable = true;
    settings = {
      git.paging.pager = "delta --paging=never --hyperlinks --hyperlinks-file-link-format=\"lazygit-edit://{path}:{line}\"";
    };
  };
}
