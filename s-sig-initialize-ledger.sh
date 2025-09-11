#!/usr/bin/env bash
set -euo pipefail

LEDGER="${1:-}"
if [[ -z "$LEDGER" ]]; then
  echo "Usage: $0 <ledger-path>"
  exit 1
fi

if [[ ! -d "$LEDGER" ]]; then
  echo "Error: ledger directory not found: $LEDGER"
  exit 1
fi

# Get snapshot slot
SNAPSHOT_FILE="$(ls $LEDGER/remote/snapshot-* 2>/dev/null | head -n1)"
[[ -n "$SNAPSHOT_FILE" ]] || { echo "No snapshot found."; exit 1; }

# Extract slot from filename snapshot-<slot>-...
b="$(basename "$SNAPSHOT_FILE")"
SNAPSHOT_SLOT="${b#*-}"; SNAPSHOT_SLOT="${SNAPSHOT_SLOT%%-*}"

# Prepare sig validator directory
echo "Preparing sig validator with snapshot for slot $SNAPSHOT_SLOT..."
cd ../sig
rm -rf validator/* 2>/dev/null || true
mkdir -p validator/accounts_db
cp "../agave/$SNAPSHOT_FILE" validator/accounts_db/

# Collect shreds with timeout, Ctrl-C safe
echo "Collecting shreds for slot $SNAPSHOT_SLOT..."
zig-out/bin/sig shred-network \
  -c testnet \
  --test-repair-for-slot "$SNAPSHOT_SLOT" \
  --max-shreds 100100100100 