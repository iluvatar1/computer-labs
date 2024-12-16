#!/bin/bash

if command -v apptainer >/dev/null 2>&1; then
    echo "Already installed"
    exit 0
fi

TARGET_DIR=/usr/local

cd /tmp
curl -s https://raw.githubusercontent.com/apptainer/apptainer/main/tools/install-unprivileged.sh | bash -s - $TARGET_DIR

echo "Apptainer config and other files at /usr/local/x86_64/"
