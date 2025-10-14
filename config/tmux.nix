{ config, pkgs, lib, ... }:

{
  # Configuring tmux, Copy tmux.conf to destination
  # home.file."${config.xdg.configHome}/tmux/tmux.conf".source = ../dotfiles/tmux/tmux.conf;
  # home.file."${config.xdg.configHome}/tmux/tmuxfzf".source = ../dotfiles/tmux/tmuxfzf;

  programs.tmux = {
    enable = true;
    shortcut = "a";
  };

  # # Append to PATH
  # home.sessionPath = [
  #   "${config.xdg.configHome}/tmux" # Make tmuxfzf.sh available
  # ];
}
