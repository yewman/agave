#!/bin/bash

# ubuntu@ip-172-31-33-159:~/agave$ mkdir /mnt/validator/artifacts/356426040
# ubuntu@ip-172-31-33-159:~/agave$ mkdir /mnt/validator/artifacts/356426040/agave
# ubuntu@ip-172-31-33-159:~/agave$ cp -r test-data/ledger-356426040/remote /mnt/validator/artifacts/35
# 355414255/ 356426040/ 
# ubuntu@ip-172-31-33-159:~/agave$ cp -r test-data/ledger-356426040/remote /mnt/validator/artifacts/35
# 355414255/ 356426040/ 
# ubuntu@ip-172-31-33-159:~/agave$ cp -r test-data/ledger-356426040/remote /mnt/validator/artifacts/35
# 355414255/ 356426040/ 
# ubuntu@ip-172-31-33-159:~/agave$ cp -r test-data/ledger-356426040/remote /mnt/validator/artifacts/356426040/
# ubuntu@ip-172-31-33-159:~/agave$ cp -r test-data/ledger-356426040/rocksdb /mnt/validator/artifacts/356426040/
# ubuntu@ip-172-31-33-159:~/agave$ cp -r test-data/ledger-356426040/genesis.bin /mnt/validator/artifacts/356426040/

# ubuntu@ip-172-31-33-159:~/sig$ mkdir validator-artifact
# ubuntu@ip-172-31-33-159:~/sig$ cp -r validator-old/ledger validator-artifact/
# ubuntu@ip-172-31-33-159:~/sig$ mkdir validator-artifact/accounts_db
# ubuntu@ip-172-31-33-159:~/sig$ cp validator-old/accounts_db/snapshot-356426040-4KCRDtBBFUjqtH9PSfZ2FDGWb9QUqWEUYXAoCnagKMKN.tar.zst validator-artifact/accounts_db/

####################################################################################################
# Read slot 
####################################################################################################
if [[ -z "$1" ]]; then
  echo "Error: No slot specified."
  exit 1
fi

SLOT=$1

####################################################################################################
# Setup artifacts directory for slot
####################################################################################################
ARTIFACTS_DIR="/mnt/validator/artifacts"

if [[ -e "$ARTIFACTS_DIR/$SLOT" && "$2" != "overwrite" ]]; then
  echo "Error: Artifacts for slot $SLOT already exist. Specify 'overwrite' to replace."
  exit 1
fi

if [[ -e "$ARTIFACTS_DIR/$SLOT" && "$2" == "overwrite" ]]; then
  echo "Overwriting artifacts for slot $SLOT..."
  rm -r "$ARTIFACTS_DIR/$SLOT"
else 
  echo "Creating artifacts dir for slot $SLOT..."
fi

mkdir -p "$ARTIFACTS_DIR/$SLOT"

####################################################################################################
# Validate snapshot slot and artifacts slot
####################################################################################################
SNAPSHOT_FILE=$(ls test-data/validator/ledger/remote/snapshot-* 2>/dev/null | head -n1)

if [[ ! -n "$SNAPSHOT_FILE" ]]; then
  echo "No snapshot found."
  rm -r "$ARTIFACTS_DIR/$SLOT"
  exit 1
fi

SNAPSHOT_SLOT=$(basename "$SNAPSHOT_FILE" | cut -d'-' -f2)

if [[ "$SLOT" != "$SNAPSHOT_SLOT" ]]; then
  echo "Slot $SLOT does not match snapshot slot $SNAPSHOT_SLOT."
  rm -r "$ARTIFACTS_DIR/$SLOT"
  exit 1
fi

####################################################################################################
# Check artifacts exist
####################################################################################################
if [[ ! -f "test-data/agave-slot-hashes.txt" ]]; then
  echo "Error: Missing test-data/agave-slot-hashes.txt"
  rm -r "$ARTIFACTS_DIR/$SLOT"
  exit 1
fi

echo "Packaging artifacts for slot $SNAPSHOT_SLOT..."

echo "Packaging agave snapshot..."
cp test-data/validator/ledger/remote/snapshot-$SLOT-* "$ARTIFACTS_DIR/$SLOT/"
cp test-data/validator/ledger/genesis.bin "$ARTIFACTS_DIR/$SLOT/"
cp -r test-data/validator/ledger/rocksdb "$ARTIFACTS_DIR/$SLOT/"

echo "Packaging agave slot hashes..."
cp test-data/agave-slot-hashes.txt "$ARTIFACTS_DIR/$SLOT/"

echo "Packaging sig ledger..."
tar -I zstd -cvf "$ARTIFACTS_DIR/$SLOT/sig-ledger.tar.zst" -C ../sig/validator/ledger .