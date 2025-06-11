#!/bin/bash
# One-line installer for AI Assistant MCP Server

set -e

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🚀 AI Assistant MCP Server Installer${NC}"
echo ""

# Check requirements
if ! command -v python3 &> /dev/null; then
    echo -e "${RED}❌ Python 3 is required. Please install it first.${NC}"
    exit 1
fi

if ! command -v claude &> /dev/null; then
    echo -e "${RED}❌ Claude Code CLI not found. Please install it first:${NC}"
    echo "npm install -g @anthropic-ai/claude-code"
    exit 1
fi

# Clone the repository
echo "📥 Downloading AI Assistant MCP Server..."
TEMP_DIR=$(mktemp -d)
cd "$TEMP_DIR"

# Since this is a new project, we'll create the files directly
mkdir -p ai-assistant-mcp

# Download files from the repository (when it exists)
# For now, we'll assume the files are being distributed somehow
# In production, this would be:
# git clone https://github.com/YOUR_USERNAME/ai-assistant-mcp.git

echo -e "${YELLOW}⚠️  Please download the repository files and run setup.sh${NC}"
echo ""
echo "Steps:"
echo "1. Download the ai-assistant-mcp folder"
echo "2. cd ai-assistant-mcp"
echo "3. ./setup.sh"
echo ""

# Cleanup
cd ~
rm -rf "$TEMP_DIR"