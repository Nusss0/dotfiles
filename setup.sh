#!/usr/bin/env bash
# Provision a machine from this repo.
#   ./setup.sh core          headless box
#   ./setup.sh core gui      VM with a display
#   ./setup.sh core gui host full workstation
set -uo pipefail
cd "$(dirname "$0")"
REPO="$PWD"

[ $# -eq 0 ] && { echo "usage: $0 core [gui] [host]"; exit 1; }

say() { printf '\n\033[1;34m==>\033[0m %s\n' "$1"; }

PKGS_CORE="zsh tmux git stow curl wget fzf fd-find bat ripgrep \
zsh-autosuggestions zsh-syntax-highlighting eza ranger \
highlight atool poppler-utils"

PKGS_GUI="alacritty xclip w3m-img ffmpegthumbnailer fonts-noto-cjk"

PKGS_HOST="i3 xorg picom rofi dunst feh i3lock-color xss-lock autotiling \
arandr brightnessctl maim pavucontrol network-manager-gnome mate-polkit \
libnotify-bin x11-xserver-utils papirus-icon-theme lm-sensors ncal"

# ─── Packages ──────────────────────────────────────────────────
LIST=""
for tier in "$@"; do
  case "$tier" in
    core) LIST="$LIST $PKGS_CORE" ;;
    gui)  LIST="$LIST $PKGS_GUI"  ;;
    host) LIST="$LIST $PKGS_HOST" ;;
    *) echo "unknown tier: $tier"; exit 1 ;;
  esac
done

say "Installing packages"
sudo apt update
# shellcheck disable=SC2086
sudo apt install -y $LIST || echo "batch install had errors — verifying individually"

say "Verifying packages"
MISSING=""
for p in $LIST; do
  dpkg -l "$p" 2>/dev/null | grep -q '^ii' || MISSING="$MISSING $p"
done
if [ -n "$MISSING" ]; then
  echo "  retrying:$MISSING"
  for p in $MISSING; do
    sudo apt install -y "$p" >/dev/null 2>&1 || echo "  STILL MISSING: $p"
  done
else
  echo "  all packages present"
fi

# ─── Directories ───────────────────────────────────────────────
say "Creating directories"
mkdir -p ~/.cache/zsh ~/.local/bin ~/.local/share/fonts
for t in "$@"; do
  [ "$t" = gui ] || [ "$t" = host ] && \
    mkdir -p ~/Pictures/wallpapers ~/Pictures/screenshots
done

# ─── Nerd Font ─────────────────────────────────────────────────
if printf '%s\n' "$@" | grep -qE '^(gui|host)$'; then
  if fc-list 2>/dev/null | grep -qi "JetBrainsMono Nerd Font"; then
    say "Nerd Font already installed"
  else
    say "Installing JetBrainsMono Nerd Font"
    tmp=$(mktemp -d)
    if wget -q -O "$tmp/f.zip" \
      https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip
    then
      unzip -oq "$tmp/f.zip" -d ~/.local/share/fonts/JetBrainsMono
      fc-cache -f >/dev/null
      echo "  installed"
    else
      echo "  download failed — install manually"
    fi
    rm -rf "$tmp"
  fi
fi

# ─── Local override files ──────────────────────────────────────
say "Creating local override files"
[ -f ~/.zshrc.local ] || cat > ~/.zshrc.local << 'EOF'
# Machine-specific. Never committed.
EOF

if [ ! -f ~/.gitconfig.local ]; then
  cat > ~/.gitconfig.local << 'EOF'
[user]
    name = CHANGE_ME
    email = CHANGE_ME
EOF
  chmod 600 ~/.gitconfig.local
  echo "  EDIT ~/.gitconfig.local — git identity is a placeholder"
fi

printf '%s\n' "$@" | grep -q '^host$' && \
  { [ -f ~/.config/i3/config.local ] || \
    { mkdir -p ~/.config/i3 && touch ~/.config/i3/config.local; }; }

# ─── Wallpaper ─────────────────────────────────────────────────
if printf '%s\n' "$@" | grep -q '^host$'; then
  if [ ! -e ~/.wallpaper ]; then
    first=$(find ~/Pictures/wallpapers -maxdepth 1 -type f 2>/dev/null | head -1)
    if [ -n "$first" ]; then
      ln -sfn "$first" ~/.wallpaper
      echo "  wallpaper -> $(basename "$first")"
    else
      echo "  no wallpaper found — drop one in ~/Pictures/wallpapers, then run: wp"
    fi
  fi
fi

# ─── Input method ──────────────────────────────────────────────
if printf '%s\n' "$@" | grep -q '^host$' && command -v im-config >/dev/null 2>&1; then
  say "Disabling input method framework"
  im-config -n none >/dev/null 2>&1 || true
fi

# ─── Free Alt+Space for tmux under XFCE ────────────────────────
if command -v xfconf-query >/dev/null 2>&1; then
  xfconf-query -c xfce4-keyboard-shortcuts -p '/xfwm4/custom/<Alt>space' -s 'empty' 2>/dev/null || true
fi

# ─── Default shell ─────────────────────────────────────────────
if [ "$SHELL" != "$(command -v zsh)" ]; then
  say "Setting zsh as default shell"
  chsh -s "$(command -v zsh)" || echo "  chsh failed — run manually"
fi

# ─── Stow ──────────────────────────────────────────────────────
say "Linking configs"
"$REPO/bootstrap.sh" "$@"

say "Done"
echo "Log out and back in for shell and session changes to apply."
