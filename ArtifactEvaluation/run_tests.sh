#!/bin/bash
set -euo pipefail

ESC=$(printf '\033')
message() {
  printf "${ESC}[32m==>${ESC}[m ${ESC}[1m%s${ESC}[m\n" "$1"
}

read -rp "Select implementation to test (before/after): " choice

case "$choice" in
    before)
        message "cd /workspace/before"
        cd /workspace/before
        pwd
        ;;
    after)
        message "cd /workspace/after"
        cd /workspace/after
        pwd
        ;;
    *)
        echo "Invalid choice: $choice"
        exit 1
        ;;
esac

message "cargo miri test --target i686-unknown-linux-gnu"
cargo +nightly miri test --target i686-unknown-linux-gnu
