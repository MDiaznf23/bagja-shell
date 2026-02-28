# Bagja Shell

> **Less remembering. More doing.**

Bagja (meaning "happy" in Sundanese) is a custom, adaptive Linux shell environment. It merges the speed of keyboard-driven workflows with the visual convenience of docks and start menus.

Built to minimize cognitive load, Bagja adapts to your energy levels—not the other way around.

## Why Bagja?

Strict keyboard workflows (tiling WMs) are fast but demand high working memory. Monolithic desktop environments are visually easy but bloated.

As someone with ADHD, my energy and focus fluctuate. I needed a system built on the UX principle of **Recognition over Recall**. Bagja solves the "Desktop Trilemma":

1. **High Energy:** Use full keybinds. Fast, efficient, hands never leave the keyboard.
2. **Medium Energy:** Forgot a keybind? Use the **Bottom Dock** (macOS style) for quick, visual muscle-memory access.
3. **Low Energy / Burnout:** Forgot what packages you even have installed? Open the **GUI Start Menu** (Windows style) to visually browse everything.

No cheat sheets. No monolithic bloatware. Just an engineered, modular workflow.

## Core Features

- **Adaptive Friction:** Seamlessly switch between keyboard-centric navigation and mouse-driven GUI without changing sessions.
- **Visual Anchor:** A minimalist bottom dock for your daily drivers.
- **Universal Entry Point:** A comprehensive start menu linked to the dock for total system discoverability.
- **Modular Architecture:** Built from independent components. If one module crashes, the rest of the shell keeps running.

## Tech Stack

- **Window Manager:** Hyprland
- **Bar / Dock / Widgets:** Quickshell
- **Compositor:** Wayland
- **Color Scheme:** m3wal (Material You)
- **Shell:** Fish

## Requirements

- Arch Linux (or Arch-based distro)
- A running TTY or minimal desktop to run the installer

## Installation

```bash
git clone https://github.com/MDiaznf23/bagja-shell.git
cd bagja-shell
./install.sh
```

The script will:

1. Install `yay` if not present
2. Install all dependencies via pacman and AUR
3. Set fish as the default shell
4. Copy dotfiles to `~/.config` (existing config backed up to `~/.config.bak`)
5. Copy wallpapers to `~/Pictures/Wallpapers`
6. Generate initial color scheme via m3wal
7. Enable pipewire and NetworkManager services

Re-login after installation to apply all changes.
