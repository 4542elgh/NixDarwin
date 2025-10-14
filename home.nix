{ config, pkgs, lib, ... }:

{
  # Enable XDG base directory
  xdg = {
    enable = true;
  };

  # Configuring zsh
  imports = [
    ./config/zsh.nix
    ./config/tmux.nix
  ];

  # The state version is required and should stay at the version you
  # originally installed.
  home.stateVersion = "25.05";
}
