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

./target/release/agave-ledger-tool verify \
  --ledger "$LEDGER" \
  --block-verification-method blockstore-processor \
  >  "$LEDGER/agave-debug.log" \
  2> >(tee "$LEDGER/agave-replay.log" >&2)

echo "Output written to $LEDGER/agave-debug.log"