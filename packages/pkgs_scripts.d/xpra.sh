#!/bin/bash

# There are two options:
# 1. Use pip
# 2. Use slackbuilds and the source

# - https://www.cs.utexas.edu/~novak/xpra.html
# - https://github.com/Xpra-org/xpra

if command -v xpra &>/dev/null; then
    echo "xpra already installed"
    exit 0
fi

# Setup TMPIR
TMPDIR=$(mktemp -d)
cd $TMPDIR

# Clone the repo
git clone https://github.com/Xpra-org/xpra

# pip install
cd xpra
pip install .

