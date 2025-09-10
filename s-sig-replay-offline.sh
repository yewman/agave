#!/usr/bin/env bash
set -euo pipefail

cd ../sig

# Remove old logs
rm -f validator/sig-replay.log validator/sig-debug.log

# Replay offline (logging + screen), Ctrl-C kills entire pipeline
echo "Replaying offline..."
zig-out/bin/sig replay-offline \
    -c testnet \
    --replay-threads 1 \
    --disable-consensus \
    --use-disk-index \
    --skip-snapshot-validation \
    --max-shreds 100100100100 \
  2>&1 | tee validator/sig-replay.log \
      | tee >(grep -v "^time=" > validator/sig-debug.log) \
      | grep "^time="