# Nix for Darwin MACOSX
This nix configuration and home-manager is only for Darwin system. It will not work for any linux like system.

## Install Nix
```bash
sh <(curl --proto '=https' --tlsv1.2 -L https://nixos.org/nix/install)
```
## Build Package
git clone this repository to `~/.config/nix` folder and you should be able to build the nix packages with
```bash
sudo darwin-rebuild switch --flake ~/.config/nix
```
