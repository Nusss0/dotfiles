#!/usr/bin/env bash
# Usage: ./bootstrap.sh core gui host
set -euo pipefail
cd "$(dirname "$0")"

for tier in "$@"; do
    [ -d "$tier" ] || { echo "no such tier: $tier"; exit 1; }
    for pkg in "$tier"/*/; do
        pkg=$(basename "$pkg")
        echo "stowing $tier/$pkg"
        stow -d "$tier" -t "$HOME" "$pkg"
    done
done
