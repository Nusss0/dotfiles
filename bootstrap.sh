#!/usr/bin/env bash
# Usage: ./bootstrap.sh core gui host
set -uo pipefail
cd "$(dirname "$0")"
shopt -s nullglob

failed=()

for tier in "$@"; do
    if [ ! -d "$tier" ]; then
        echo "no such tier: $tier" >&2
        exit 1
    fi

    pkgs=( "$tier"/*/ )
    if [ ${#pkgs[@]} -eq 0 ]; then
        echo "$tier: no packages yet, skipping"
        continue
    fi

    for pkg in "${pkgs[@]}"; do
        pkg=$(basename "$pkg")
        if stow -d "$tier" -t "$HOME" "$pkg" 2>/tmp/stow.err; then
            echo "  ok      $tier/$pkg"
        else
            echo "  FAILED  $tier/$pkg"
            sed 's/^/            /' /tmp/stow.err
            failed+=("$tier/$pkg")
        fi
    done
done

rm -f /tmp/stow.err

if [ ${#failed[@]} -gt 0 ]; then
    echo
    echo "${#failed[@]} package(s) failed: ${failed[*]}"
    echo "Usually an existing real file at the target. Move it, then re-run."
    exit 1
fi

echo
echo "all packages stowed"
