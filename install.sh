#!/bin/bash
# ╔══════════════════════════════════════════════════════════════╗
# ║              bagja-shell — install.sh                        ║
# ╚══════════════════════════════════════════════════════════════╝

set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
BLUE='\033[0;34m'; CYAN='\033[0;36m'; BOLD='\033[1m'; RESET='\033[0m'

info()    { echo -e "${CYAN}${BOLD}[INFO]${RESET}  $*"; }
success() { echo -e "${GREEN}${BOLD}[ OK ]${RESET}  $*"; }
warn()    { echo -e "${YELLOW}${BOLD}[WARN]${RESET}  $*"; }
section() { echo -e "\n${BLUE}${BOLD}━━━ $* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"; }

# ─── 1. Check / Install yay ───────────────────────────────────
section "AUR Helper (yay)"

if command -v yay &>/dev/null; then
    success "yay is already installed: $(yay --version | head -1)"
else
    warn "yay not found, installing..."
    sudo pacman -S --needed --noconfirm git base-devel
    TMPDIR=$(mktemp -d)
    git clone https://aur.archlinux.org/yay-bin.git "$TMPDIR/yay-bin"
    (cd "$TMPDIR/yay-bin" && makepkg -si --noconfirm)
    rm -rf "$TMPDIR"
    success "yay installed"
fi

# ─── 2. Pacman packages ───────────────────────────────────────
section "Pacman Packages"

PACMAN_PKGS=(
    # Hyprland
    hyprland xdg-desktop-portal-hyprland xdg-desktop-portal-gtk polkit-kde-agent

    # Audio
    pipewire pipewire-alsa pipewire-pulse pipewire-jack wireplumber libpulse

    # Network
    networkmanager

    # Shell
    fish

    # Dependencies
    libqalculate aubio dolphin fftw wl-clipboard cliphist neovim awww swappy
    inotify-tools playerctl lm_sensors imagemagick brightnessctl dex
    fastfetch python python-pip python-pipx jq socat kde-cli-tools konsole archlinux-xdg-menu

    # Qt
    qt5-quickcontrols2 qt5-graphicaleffects qt6-5compat

    # Fonts
    noto-fonts noto-fonts-cjk noto-fonts-emoji noto-fonts-extra
    ttf-jetbrains-mono ttf-fira-code ttf-dejavu ttf-liberation ttf-font-awesome
)

sudo pacman -S --needed --noconfirm "${PACMAN_PKGS[@]}"
success "Pacman packages done"

# ─── 3. AUR packages ──────────────────────────────────────────
section "AUR Packages"

AUR_PKGS=(
    quickshell-git mpdris2
    qt5ct-kde qt6ct-kde
    ttf-jetbrains-mono-nerd ttf-iosevka-nerd ttf-twemoji
    m3wal
)

yay -S --needed --noconfirm "${AUR_PKGS[@]}"
success "AUR packages done"

# ─── 4. Set fish as default shell ─────────────────────────────
section "Default Shell"

FISH_PATH=$(which fish)
if [ "$SHELL" != "$FISH_PATH" ]; then
    grep -q "$FISH_PATH" /etc/shells || echo "$FISH_PATH" | sudo tee -a /etc/shells
    sudo chsh -s "$FISH_PATH" "$USER"
    success "Default shell set to fish"
else
    success "fish is already the default shell"
fi

# ─── 5. Setup Dotfiles ────────────────────────────────────────
section "Setup Dotfiles"

if [ -d "$HOME/.config" ]; then
    info "Backing up ~/.config → ~/.config.bak"
    rm -rf "$HOME/.config.bak"
    cp -r "$HOME/.config" "$HOME/.config.bak"
fi

cp -rf "$DOTFILES_DIR/.config/." "$HOME/.config/"
success "Dotfiles copied → ~/.config"

if [ -d "$DOTFILES_DIR/Wallpapers" ]; then
    mkdir -p "$HOME/Pictures/Wallpapers"
    cp -rf "$DOTFILES_DIR/Wallpapers/." "$HOME/Pictures/Wallpapers/"
    success "Wallpapers copied → ~/Pictures/Wallpapers"
fi

if [ -d "$DOTFILES_DIR/.local" ]; then
    cp -rf "$DOTFILES_DIR/.local/." "$HOME/.local/"
    success ".local copied"
fi

# ─── 6. Chmod ─────────────────────────────────────────────────
section "Set Executable Permissions"

find "$DOTFILES_DIR" -type f \( -name "*.sh" -o -name "*.py" \) -exec chmod +x {} \;
success "Permissions set"

# ─── 7. Setup m3wal ───────────────────────────────────────────
section "Setup m3wal"

FIRST_WALL=$(find "$HOME/Pictures/Wallpapers" -type f \( \
    -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) \
    2>/dev/null | head -1)

if [ -n "$FIRST_WALL" ]; then
    info "Running m3wal: $FIRST_WALL"
    m3wal "$FIRST_WALL" && success "Color scheme generated"
else
    warn "No wallpaper found, run manually: m3wal <path/to/wallpaper>"
fi

# ─── 8. Enable services ───────────────────────────────────────
section "Enable Services"

systemctl --user enable --now pipewire pipewire-pulse wireplumber 2>/dev/null
sudo systemctl enable --now NetworkManager 2>/dev/null
success "Services enabled"

# ─── Done ─────────────────────────────────────────────────────
section "Done!"
echo -e "${GREEN}${BOLD}"
echo "  bagja-shell installed successfully!"
echo "  Re-login to apply fish as default shell, then start Hyprland."
echo -e "${RESET}"
