# system76-scheduler-niri

A simple daemon to update the foreground process of [system76-scheduler](https://github.com/pop-os/system76-scheduler)
based on the focused window in Niri.

## Installation

The program can be installed to `~/.cargo/bin` by running `cargo install --path .` in the
cloned repository.

### NixOS

A Nix flake is provided that contains the package, and a defined systemd user service
as a home manager module.

**Note**: system76-scheduler has to be enabled separately with `services.system76-scheduler.enable`.

## Usage

Simply start `system76-scheduler-niri` when Niri starts.
