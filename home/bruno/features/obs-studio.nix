{ pkgs, ... }:{
  programs.obs-studio = {
    enable = true;
    plugins = with pkgs.obs-studio-plugins; [
      wlrobs
      obs-vkcapture
      obs-source-clone
      obs-pipewire-audio-capture
      obs-move-transition
      obs-backgroundremoval
      obs-3d-effect
      looking-glass-obs
      input-overlay
      advanced-scene-switcher
      obs-shaderfilter
    ];
  };
}
