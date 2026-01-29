#!/bin/bash

# Local Coding AI - Startup Script
# Quick launcher for the server

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}🚀 Starting Local Coding AI...${NC}"
echo ""

# Check if Ollama is running
if ! pgrep -x "ollama" > /dev/null; then
    echo -e "${YELLOW}⚠ Ollama not running. Starting Ollama...${NC}"
    nohup ollama serve > /tmp/ollama.log 2>&1 &
    sleep 2
    
    if pgrep -x "ollama" > /dev/null; then
        echo -e "${GREEN}✓ Ollama started${NC}"
    else
        echo -e "${YELLOW}⚠ Could not start Ollama automatically${NC}"
        echo "Please start Ollama manually: ollama serve"
        echo ""
    fi
else
    echo -e "${GREEN}✓ Ollama is running${NC}"
fi

echo ""

# Start the server with any passed arguments
python3 src/server.py "$@"
