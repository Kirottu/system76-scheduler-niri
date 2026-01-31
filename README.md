# system76-scheduler-niri

A simple daemon to update the foreground process of [system76-scheduler](https://github.com/pop-os/system76-scheduler)
based on the focused window in Niri.

## Installation

The program can be installed to `~/.cargo/bin` by running `cargo install --path .` in the
cloned repository.

### NixOS

A Nix flake is provided that contains the package, and a defined systemd user service
as a home manager module.

### Arch Linux

A community-maintained [AUR package](https://aur.archlinux.org/packages/system76-scheduler-niri-git) is available: `yay -S system76-scheduler-niri-git`

**Note**: system76-scheduler has to be enabled separately

## Usage

Simply start `system76-scheduler-niri` when Niri starts.
