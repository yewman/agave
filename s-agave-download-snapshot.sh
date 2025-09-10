#!/usr/bin/env bash
rm -rf test-auth/validator/*

# RPC endpoint (replace with your validator if needed)
# RPC_URL="https://api.mainnet-beta.solana.com"
RPC_URL="https://api.testnet.solana.com"

# Query latest snapshot slots and extract "full"
FULL_SLOT=$(curl -s "$RPC_URL" \
  -H 'Content-Type: application/json' \
  -d '{"jsonrpc":"2.0","id":1,"method":"getHighestSnapshotSlot"}' \
  | jq -r '.result.full')
echo "Latest full snapshot slot: $FULL_SLOT"

# Check if ledger already exists for snapshot slot
if [[ -e "test-auth/ledger-$FULL_SLOT" ]]; then
  echo "Ledger for slot $FULL_SLOT already exists."
  exit 0
fi

# Download snapshot to ledger
RUST_LOG_STYLE=never ./target/release/agave-validator \
  --identity test-auth/identity.json \
  --ledger ledger-$FULL_SLOT \
  --log "-" \
  --entrypoint entrypoint.testnet.solana.com:8001 \
  --entrypoint entrypoint2.testnet.solana.com:8001 \
  --entrypoint entrypoint3.testnet.solana.com:8001 \
  --no-incremental-snapshots \
  init 

  # --entrypoint entrypoint.mainnet-beta.solana.com:8001 \
  # --entrypoint entrypoint2.mainnet-beta.solana.com:8001 \
  # --entrypoint entrypoint3.mainnet-beta.solana.com:8001 \
  # --entrypoint entrypoint4.mainnet-beta.solana.com:8001 \
  # --entrypoint entrypoint5.mainnet-beta.solana.com:8001 \
