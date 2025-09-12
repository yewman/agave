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

echo "Initializing ledger at $LEDGER..."
echo "Logs: $LEDGER/agave-initialise.log"

RUST_LOG_STYLE=never ./target/release/agave-validator \
  --identity test-auth/identity.json \
  --ledger $LEDGER \
  --log "-" \
  --entrypoint entrypoint.testnet.solana.com:8001 \
  --entrypoint entrypoint2.testnet.solana.com:8001 \
  --entrypoint entrypoint3.testnet.solana.com:8001 \
  --rpc-port 8899 \
  --no-voting \
  --no-snapshots \
  --no-snapshot-fetch \
  --use-snapshot-archives-at-startup always \
  --limit-ledger-size 5000000000 \
  --block-verification-method blockstore-processor \
  2>&1 | tee $LEDGER/agave-initialise.log | grep "bank frozen: " 