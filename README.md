# My dotfiles

My personal dotfiles. Everything here is just for me and it's not a reference

> Note: I'm on MacOS. This Nix config might not fit your linux

Install nix:
```bash
sh <(curl -L https://nixos.org/nix/install)
```

Nix darwin:
```bash
nix run nix-darwin -- switch --flake ~/github/dotfiles
```
Then
```bash
darwin-rebuild switch --flake ~/github/dotfiles#macbook
```
