{
  config,
  pkgs,
  lib,
  ...
}:
let
  clipcopy =
    if pkgs.stdenv.isDarwin then
      "pbcopy"
    else
      "sh -c 'if [ \"$XDG_SESSION_TYPE\" = x11 ]; then xclip -selection clipboard; else wl-copy; fi'";
in
{
  home.packages = with pkgs; [
    tree
  ];

  programs.fd = {
    enable = true;
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    enableBashIntegration = true;
    defaultOptions = [

    ];
    fileWidgetOptions = [
      "--walker-skip .git,node_modules,target"
      "--preview 'bat -n --color=always {}'"
      "--bind 'ctrl-/:change-preview-window(down|hidden|)'"
    ];
    fileWidgetCommand = "fd --type f --strip-cwd-prefix --hidden --follow --exclude .git";
    changeDirWidgetOptions = [
      "--walker-skip .git,node_modules,target"
      "--preview 'tree -C {}'"
      #   "--preview 'tree -C {} | head -200'"
    ];
    historyWidgetOptions = [
      "--bind 'ctrl-y:execute-silent(echo -n {2..} | ${clipcopy})+abort'"
      "--color header:italic"
      "--header 'Press CTRL-Y to copy command into clipboard'"
    ];
  };
}
