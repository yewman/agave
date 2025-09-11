#!/usr/bin/env bash
set -euo pipefail

LEDGER="${1:-}"
if [[ -z "$LEDGER" ]]; then
  echo "Usage: $0 <ledger-path> <max-slots>"
  exit 1
fi
LEDGER="${LEDGER%/}"
if [[ ! -d "$LEDGER" ]]; then
  echo "Error: ledger directory not found: $LEDGER"
  exit 1
fi

MAX_SLOTS="${2:-}"
if [[ -z "$MAX_SLOTS" ]]; then
  echo "Usage: $0 <ledger-path> <max-slots>"
  exit 1
fi
if ! [[ "$MAX_SLOTS" =~ ^[0-9]+$ ]]; then
  echo "Error: max-slots must be a positive integer"
  exit 1
fi

SNAPSHOT_FILE="$(ls "$LEDGER"/remote/snapshot-* 2>/dev/null | head -n1 || true)"
if [[ -z "$SNAPSHOT_FILE" ]]; then
  echo "Error: no snapshot found in $LEDGER/remote/"
  exit 1
fi

b="$(basename "$SNAPSHOT_FILE")"
SNAPSHOT_SLOT="${b#*-}"; SNAPSHOT_SLOT="${SNAPSHOT_SLOT%%-*}"

TARGET_SLOT=$(( SNAPSHOT_SLOT + MAX_SLOTS + 1 ))

./target/release/agave-ledger-tool \
  --ledger "$LEDGER" \
  blockstore purge "$TARGET_SLOT"