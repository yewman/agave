#!/usr/bin/env bash
set -euo pipefail

LEDGER="${1:-}"
if [[ -z "$LEDGER" ]]; then
  echo "Usage: $0 <ledger-path>"
  exit 1
fi

LEDGER="${LEDGER%/}"

if [[ ! -d "$LEDGER" ]]; then
  echo "Error: ledger directory not found: $LEDGER"
  exit 1
fi

rm -rf "$LEDGER-diff"
mkdir -p "$LEDGER-diff"

cp $LEDGER/agave-debug.log "$LEDGER-diff/agave-debug.log"
cp ../sig/validator/sig-debug.log "$LEDGER-diff/sig-debug.log"

code "$LEDGER-diff/agave-debug.log" "$LEDGER-diff/sig-debug.log"

echo "diff "$LEDGER-diff/agave-debug.log" "$LEDGER-diff/sig-debug.log""