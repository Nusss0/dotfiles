#!/usr/bin/env bash
# Usage: ./bootstrap.sh core gui host
set -euo pipefail
cd "$(dirname "$0")"
shopt -s nullglob

for tier in "$@"; do
    [ -d "$tier" ] || { echo "no such tier: $tier"; exit 1; }

    pkgs=( "$tier"/*/ )
    if [ ${#pkgs[@]} -eq 0 ]; then
        echo "$tier: no packages yet, skipping"
        continue
    fi

    for pkg in "${pkgs[@]}"; do
        pkg=$(basename "$pkg")
        echo "stowing $tier/$pkg"
        stow -d "$tier" -t "$HOME" "$pkg"
    done
done
