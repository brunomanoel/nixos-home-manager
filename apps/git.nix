{
  programs.git = {
    enable = true;
    userName = "Bruno Manoel";
    userEmail = "26349861+brunomanoel@users.noreply.github.com";
    signing.signByDefault = true;
    signing.key = "DFAF2902BD774DC0";
    delta = {
      enable = true;
      options = {
      	decorations = {};
      	features = "side-by-side line-numbers decorations";
      	syntax-theme = "Dracula";
      };
    };
  };

  programs.jujutsu = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      user = {
        name = "Bruno Manoel";
        email = "26349861+brunomanoel@users.noreply.github.com";
      };
    };
  };
}
