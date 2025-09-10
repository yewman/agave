#!/usr/bin/env bash
set -euo pipefail

IDENTITY_KEY="test-auth/identity.json"
VOTE_KEY="test-auth/vote.json"
WITHDRAWER_KEY="test-auth/withdrawer.json"
FEE_PAYER_KEY="test-auth/fee-payer.json"

# --- ensure keys exist ---
[ -f "$IDENTITY_KEY" ]   || ./target/release/solana-keygen new -o "$IDENTITY_KEY" --no-bip39-passphrase
[ -f "$VOTE_KEY" ]       || ./target/release/solana-keygen new -o "$VOTE_KEY" --no-bip39-passphrase
[ -f "$WITHDRAWER_KEY" ] || ./target/release/solana-keygen new -o "$WITHDRAWER_KEY" --no-bip39-passphrase
[ -f "$FEE_PAYER_KEY" ]  || ./target/release/solana-keygen new -o "$FEE_PAYER_KEY" --no-bip39-passphrase

WITHDRAWER_PUB=$(./target/release/solana-keygen pubkey "$WITHDRAWER_KEY")
FEE_PAYER_PUB=$(./target/release/solana-keygen pubkey "$FEE_PAYER_KEY")
VOTE_PUB=$(./target/release/solana-keygen pubkey "$VOTE_KEY")

# --- check fee payer balance ---
echo "Checking fee payer $FEE_PAYER_PUB balance..."
BALANCE=$(./target/release/solana balance "$FEE_PAYER_PUB" --url https://api.testnet.solana.com 2>/dev/null | awk '{print $1}' || echo 0)
NEEDED=1
if (( $(echo "$BALANCE < $NEEDED" | bc -l) )); then
  echo "Fee payer has $BALANCE SOL (< $NEEDED). Requesting airdrop..."
  ./target/release/solana airdrop 2 "$FEE_PAYER_PUB" --url https://api.testnet.solana.com
else
  echo "Fee payer $FEE_PAYER_PUB has $BALANCE SOL, no airdrop needed."
fi

# --- create vote account if it does not exist ---
BALANCE=$(./target/release/solana balance "$FEE_PAYER_PUB" --url https://api.testnet.solana.com 2>/dev/null | awk '{print $1}' || echo 0)

NEEDED=0.001
if (( $(echo "$BALANCE < $NEEDED" | bc -l) )); then
  ./target/release/solana create-vote-account \
    "$VOTE_KEY" \
    "$IDENTITY_KEY" \
    "$WITHDRAWER_PUB" \
    --commission 8 \
    --fee-payer "$FEE_PAYER_KEY" \
    --url https://api.testnet.solana.com
else
  echo "Vote account $VOTE_PUB already exists!"
fi
