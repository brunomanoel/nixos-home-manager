{
  programs.git = {
    enable = true;
    userName = "Bruno Manoel";
    userEmail = "26349861+brunomanoel@users.noreply.github.com";
    signing.signByDefault = true;
    signing.key = "86B002F60764A739";
    delta = {
      enable = true;
      options = {
      	features = "side-by-side line-numbers decorations";
      	syntax-theme = "Dracula";
        decorations = {
          commit-decoration-style = "cyan ol";
          hunk-header-decoration-style = "cyan box ul";
          hunk-header-file-style = "red";
          hunk-header-line-number-style = "cyan";
          hunk-header-style = "file line-number syntax";
          file-decoration-style = "cyan ul";
          file-style = "cyan";
        };
        interactive = {
          keep-plus-minus-markers = true;
        };
        line-numbers = {
          line-numbers-left-style = "cyan";
          line-numbers-right-style = "cyan";
          line-numbers-minus-style = 124;
          line-numbers-plus-style = 28;
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
}
