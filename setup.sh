#!/bin/bash
# Setup script for AI Assistant MCP Server

set -e

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}🚀 AI Assistant MCP Server Setup${NC}"
echo ""

# Check Python version
echo "📋 Checking requirements..."
if ! command -v python3 &> /dev/null; then
    echo -e "${RED}❌ Python 3 is required but not installed.${NC}"
    exit 1
fi

PYTHON_VERSION=$(python3 -c 'import sys; print(".".join(map(str, sys.version_info[:2])))')
echo "✅ Python $PYTHON_VERSION found"

# Check Claude Code
if ! command -v claude &> /dev/null; then
    echo -e "${RED}❌ Claude Code CLI not found. Please install it first:${NC}"
    echo "npm install -g @anthropic-ai/claude-code"
    exit 1
fi
echo "✅ Claude Code CLI found"

# Check Python dependencies
echo "📦 Checking Python dependencies..."
if ! python3 -c "import mcp" 2>/dev/null; then
    echo -e "${YELLOW}Installing required Python packages...${NC}"
    pip3 install mcp requests || {
        echo -e "${RED}❌ Failed to install Python dependencies${NC}"
        echo "Please run: pip3 install mcp requests"
        exit 1
    }
fi
echo "✅ Python dependencies installed"

# Create directory
echo ""
echo "📁 Setting up MCP server directory..."
INSTALL_DIR="$HOME/.claude-mcp-servers/ai-assistant"
mkdir -p "$INSTALL_DIR"

# Copy files
echo "📋 Installing server files..."
cp server.py "$INSTALL_DIR/"
cp config.json "$INSTALL_DIR/"

# Make server executable
chmod +x "$INSTALL_DIR/server.py"

# Check for API key
echo ""
echo "🔑 Checking API configuration..."
echo ""

# Check OpenRouter
if [ -z "$OPENROUTER_API_KEY" ]; then
    echo -e "${YELLOW}⚠️  OpenRouter API key not found${NC}"
    echo ""
    echo "To get an OpenRouter API key:"
    echo "1. Visit https://openrouter.ai/keys"
    echo "2. Sign up for a free account"
    echo "3. Create a new API key"
    echo "4. Run: export OPENROUTER_API_KEY='your-api-key'"
    echo "5. Add to your ~/.zshrc or ~/.bashrc to persist"
    echo ""
    echo -e "${RED}❌ Setup cannot continue without an API key.${NC}"
    exit 1
else
    echo -e "${GREEN}✅ OpenRouter API key found${NC}"
fi

# Configure Claude Code MCP
echo ""
echo "🔧 Configuring Claude Code..."

# Remove any existing configuration
claude mcp remove ai-assistant 2>/dev/null || true

# Add MCP server with global scope
claude mcp add --scope user ai-assistant python3 "$INSTALL_DIR/server.py"

# Setup CLAUDE.md instructions
echo ""
echo "📝 Setting up natural language instructions..."
CLAUDE_FILE="$HOME/.claude/CLAUDE.md"
CLAUDE_DIR=$(dirname "$CLAUDE_FILE")

# Create .claude directory if it doesn't exist
if [ ! -d "$CLAUDE_DIR" ]; then
    mkdir -p "$CLAUDE_DIR"
    echo "✅ Created $CLAUDE_DIR directory"
fi

# Define the AI assistant instructions marker
AI_ASSISTANT_MARKER="<!-- AI_ASSISTANT_MCP_SERVER -->"
AI_ASSISTANT_CONTENT="$AI_ASSISTANT_MARKER
# AI Assistant Natural Language Interface

## Overview

This document provides instructions for Claude Code to automatically detect and translate natural language requests into AI assistant tool calls.

## Natural Language Detection Rules

### Pattern Recognition

When you detect prompts matching these patterns, automatically translate them to the appropriate MCP tool call:

#### General Patterns
- \`\"ask [Model] to [action] [content]\"\`
- \`\"have [Model] [action] [content]\"\`
- \`\"get [Model] to [action] [content]\"\`
- \`\"let [Model] [action] [content]\"\`

Where:
- \`[Model]\` = O3, Gemini, Grok, DeepSeek, or Opus (case-insensitive)
- \`[action]\` = action keywords listed below
- \`[content]\` = the rest of the user's request

### Action Keyword Mappings

#### 1. General Collaboration → \`mcp__ai-assistant__pair\`
**Keywords**: explain, help, discuss, answer, solve, implement, create, write, build, design, develop, clarify, demonstrate, show, teach, guide, assist

**Examples**:
- \"ask Gemini to explain recursion\" → \`mcp__ai-assistant__pair\` with prompt=\"explain recursion\", model=\"Gemini\"
- \"have O3 help with implementing a binary tree\" → \`mcp__ai-assistant__pair\` with prompt=\"help with implementing a binary tree\", model=\"O3\"
- \"get DeepSeek to solve this algorithm problem\" → \`mcp__ai-assistant__pair\` with prompt=\"solve this algorithm problem\", model=\"DeepSeek\"

#### 2. Code Review → \`mcp__ai-assistant__review\`
**Keywords**: review, check, analyze, inspect, examine, critique, evaluate (when followed by \"code\", \"function\", \"script\", or actual code)

**Examples**:
- \"ask Gemini to review this code: def factorial(n): ...\" → \`mcp__ai-assistant__review\` with code=\"def factorial(n): ...\", model=\"Gemini\"
- \"have DeepSeek check my authentication function\" → \`mcp__ai-assistant__review\` with code=[function content], model=\"DeepSeek\"
- \"get Opus to analyze this SQL query\" → \`mcp__ai-assistant__review\` with code=[SQL query], model=\"Opus\"

#### 3. Brainstorming → \`mcp__ai-assistant__brainstorm\`
**Keywords**: brainstorm, suggest, ideate, propose, recommend (when about ideas/solutions)

**Examples**:
- \"ask Grok to brainstorm API optimization strategies\" → \`mcp__ai-assistant__brainstorm\` with topic=\"API optimization strategies\", model=\"Grok\"
- \"have Gemini suggest database architectures\" → \`mcp__ai-assistant__brainstorm\` with topic=\"database architectures\", model=\"Gemini\"
- \"get O3 to propose solutions for scaling\" → \`mcp__ai-assistant__brainstorm\` with topic=\"solutions for scaling\", model=\"O3\"

#### 4. Performance Analysis → \`mcp__ai-assistant__review_performance\`
**Keywords**: \"analyze performance\", \"check performance\", \"optimize\", \"improve performance\", \"performance review\"

**Examples**:
- \"ask Gemini to analyze performance of my sorting algorithm\" → \`mcp__ai-assistant__review_performance\` with code=[algorithm code], model=\"Gemini\"
- \"have O3 optimize this nested loop\" → \`mcp__ai-assistant__review_performance\` with code=[loop code], model=\"O3\"
- \"get DeepSeek to check performance issues\" → \`mcp__ai-assistant__review_performance\` with code=[relevant code], model=\"DeepSeek\"

#### 5. Security Review → \`mcp__ai-assistant__review_security\`
**Keywords**: \"check security\", \"find vulnerabilities\", \"security review\", \"analyze security\", \"security issues\"

**Examples**:
- \"ask DeepSeek to check security of my login endpoint\" → \`mcp__ai-assistant__review_security\` with code=[endpoint code], model=\"DeepSeek\"
- \"have Opus find vulnerabilities in this SQL\" → \`mcp__ai-assistant__review_security\` with code=[SQL code], model=\"Opus\"
- \"get Gemini to analyze security issues\" → \`mcp__ai-assistant__review_security\` with code=[relevant code], model=\"Gemini\"

## Implementation Guidelines

### 1. Pattern Matching
- Use case-insensitive matching for model names
- Be flexible with whitespace and punctuation
- Support variations like \"ask gemini\", \"Ask Gemini\", \"ASK GEMINI\"

### 2. Content Extraction
- For code-related actions, look for:
  - Code blocks in backticks
  - Code following a colon
  - References to files or functions that need to be read first
- For general queries, everything after the action keyword becomes the prompt/topic

### 3. Model Validation
- If an invalid model name is used, suggest valid options: O3, Gemini, Grok, DeepSeek, Opus
- If no model is specified, use the default (Gemini)

### 4. Context Awareness
- When users reference \"this code\" or \"my function\", check recent context or ask for clarification
- If code needs to be read from a file, use the Read tool first

### 5. Error Handling
- If a pattern is ambiguous, ask for clarification
- If a model doesn't support images but an image is referenced, inform the user

## Examples of Complete Translations

1. **Input**: \"ask gemini to explain how async/await works in Python\"
   **Translation**: 
   \`\`\`
   mcp__ai-assistant__pair
     prompt: \"explain how async/await works in Python\"
     model: \"Gemini\"
   \`\`\`

2. **Input**: \"have deepseek review this function for security issues\"
   **Translation**: 
   \`\`\`
   mcp__ai-assistant__review_security
     code: [function content from context or file]
     model: \"DeepSeek\"
   \`\`\`

3. **Input**: \"get grok to brainstorm ways to reduce database latency\"
   **Translation**: 
   \`\`\`
   mcp__ai-assistant__brainstorm
     topic: \"ways to reduce database latency\"
     model: \"Grok\"
   \`\`\`

## Default Behavior

If a natural language request is detected but doesn't specify a model, use the default model (Gemini) and inform the user which model is being used.

## User Education

When translating natural language requests, briefly show the user what tool is being called so they understand the system better. For example:
\"I'll ask Gemini to explain recursion for you using the AI assistant.\"
<!-- END_AI_ASSISTANT_MCP_SERVER -->"

# Check if CLAUDE.md exists
if [ ! -f "$CLAUDE_FILE" ]; then
    echo "Creating new $CLAUDE_FILE with AI Assistant instructions..."
    echo "$AI_ASSISTANT_CONTENT" > "$CLAUDE_FILE"
    echo "✅ Created $CLAUDE_FILE with AI Assistant instructions"
else
    # Check if AI Assistant instructions are already present
    if grep -q "$AI_ASSISTANT_MARKER" "$CLAUDE_FILE"; then
        echo "✅ AI Assistant instructions already present in $CLAUDE_FILE"
    else
        echo "Appending AI Assistant instructions to existing $CLAUDE_FILE..."
        echo "" >> "$CLAUDE_FILE"
        echo "" >> "$CLAUDE_FILE"
        echo "$AI_ASSISTANT_CONTENT" >> "$CLAUDE_FILE"
        echo "✅ Added AI Assistant instructions to $CLAUDE_FILE"
    fi
fi

echo ""
echo -e "${GREEN}✅ Setup complete!${NC}"
echo ""
echo "🎉 You can now use AI Assistant in Claude Code!"
echo ""
echo "Available models (use short names):"
echo "  • O3 - OpenAI O3 Pro"
echo "  • Gemini - Google Gemini 2.5 Pro Preview (default)"
echo "  • Grok - X.AI Grok 3 Beta"
echo "  • DeepSeek - DeepSeek R1"
echo "  • Opus - Claude Opus 4"
echo ""
echo "📖 Usage Options:"
echo ""
echo "1. Natural Language (recommended):"
echo "   Simply type requests like:"
echo "   • \"ask Gemini to explain recursion\""
echo "   • \"have O3 review this code for performance\""
echo "   • \"get DeepSeek to brainstorm API designs\""
echo "   • \"let Opus check security of my login function\""
echo ""
echo "2. Direct MCP Commands:"
echo "   • mcp__ai-assistant__pair - Collaborate on any topic"
echo "   • mcp__ai-assistant__review - Get comprehensive code review"
echo "   • mcp__ai-assistant__brainstorm - Brainstorm creative solutions"
echo "   • mcp__ai-assistant__review_performance - Analyze code performance"
echo "   • mcp__ai-assistant__review_security - Security-focused review"
echo ""
echo "Example direct command usage:"
echo "  mcp__ai-assistant__pair"
echo "    prompt: \"Explain recursion\""
echo "    model: \"Opus\"  # optional, defaults to Gemini"
echo ""
echo "📝 Natural language instructions have been added to ~/.claude/CLAUDE.md"
echo ""
echo "Run 'claude' to start using it!"