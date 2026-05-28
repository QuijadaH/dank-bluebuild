#!/usr/bin/env bash

set -euo pipefail

SOURCE_DIR="/usr/libexec/dank-bluebuild/post-login-setup/script.d"
TARGET_DIR="/usr/bin"

for file in "$SOURCE_DIR"/[0-9]*-*; do
    [ -f "$file" ] || continue
    
    filename=$(basename "$file")
    link_name="${filename#*-}"
    
    ln -s "$file" "$TARGET_DIR/$link_name"    
    echo "Created: $TARGET_DIR/$link_name -> $file"
done