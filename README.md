# AI Assistant MCP Server

🎯 **The coolest way to chat with AI models in Claude Code** - Just type naturally!

## 🎬 Watch It In Action!

See the magic of natural language AI assistance:

[![AI Assistant Demo](https://img.shields.io/badge/▶️_Watch_Demo-Video-red?style=for-the-badge&logo=youtube)](https://youtu.be/IaJJNgdZD3I?si=vQJrTqCHdCTCQoIw)

## ✨ Natural Language Magic

Forget complex commands! Just talk to your AI assistants naturally:

```bash
# Just type these in Claude Code:
"ask Gemini to explain how async/await works in Python"
"have O3 review my authentication code for security issues"
"get Grok to brainstorm ways to optimize my database"
"let DeepSeek analyze performance of this sorting algorithm"
"ask Opus to help me implement a binary search tree"
```

## 🚀 Features

- **🗣️ Natural Language Interface**: Just say what you want - no complex syntax needed!
- **🤖 Multiple AI Models**: Access to O3, Gemini, Grok, DeepSeek, and Opus models
- **🔄 Unified Interface**: All models accessed through OpenRouter API
- **🖼️ Image Support**: Select models support image inputs
- **🛠️ 5 Specialized Tools**:
  - `pair`: General collaboration and Q&A
  - `review`: Comprehensive code review
  - `brainstorm`: Creative problem-solving
  - `review_performance`: Performance analysis
  - `review_security`: Security vulnerability detection

## 📋 Prerequisites

- Python 3.8+
- Claude Code CLI installed
- OpenRouter API key

## 🔧 Installation

### Quick Install

```bash
# Clone the repository
git clone git@github.com:eduardm/ai_pairs_with_ai.git
cd ai_pairs_with_ai

# Run setup
./setup.sh
```

The setup script will:
1. Install the server in `~/.claude-mcp-servers/ai-assistant/`
2. Configure Claude Code to recognize the MCP server
3. Check for API key and show instructions if not configured
4. Add natural language instructions to ~/.claude/CLAUDE.md

## 🚀 Quick Start - Try It Now!

After installation, just start Claude Code and type:

```bash
claude

# Then just type naturally:
"ask Gemini to explain what makes Python special"
```

That's it! No complex commands to memorize. Just talk naturally! 🎉

### 🎥 See It In Action!

Here are some real examples you can try right now:

```bash
# Monday morning debugging session
"ask O3 why my React app keeps re-rendering infinitely"

# Code review before pushing
"have DeepSeek review my authentication middleware for security issues"

# Stuck on a problem?
"ask Gemini to help me implement a rate limiter in Node.js"

# Performance issues?
"get Opus to analyze why my SQL query takes 30 seconds"

# Need fresh ideas?
"ask Grok to brainstorm ways to make my API more developer-friendly"
```

## 🔑 Configuration

### API Key

Set your OpenRouter API key:

```bash
export OPENROUTER_API_KEY="your-openrouter-api-key"
```

Get a free API key at: https://openrouter.ai/keys

### Configuration File

The `config.json` file defines available models:

```json
{
  "default_model": "Gemini",
  "api_key_env": "OPENROUTER_API_KEY",
  "models": {
    "O3": {
      "model_id": "openai/o3-pro",
      "max_tokens": 8192,
      "temperature": 0.3,
      "supports_images": true
    },
    "Gemini": {
      "model_id": "google/gemini-2.5-pro-preview",
      "max_tokens": 8192,
      "temperature": 0.3,
      "supports_images": true
    },
    "Grok": {
      "model_id": "x-ai/grok-3-beta",
      "max_tokens": 8192,
      "temperature": 0.3,
      "supports_images": false
    },
    "DeepSeek": {
      "model_id": "deepseek/deepseek-r1-0528",
      "max_tokens": 8192,
      "temperature": 0.3,
      "supports_images": false
    },
    "Opus": {
      "model_id": "anthropic/claude-opus-4",
      "max_tokens": 8192,
      "temperature": 0.3,
      "supports_images": true
    }
  }
}
```

## 📖 Usage Examples

### 🌟 Natural Language - The Magic Way! ✨

Just start Claude Code and type naturally:

#### 💬 General Collaboration
```bash
# Ask any AI for help, explanations, or implementation guidance
"ask Gemini to explain recursion with simple examples"
"have O3 help me implement a binary search tree in Python"
"get DeepSeek to solve this algorithm problem"
"let Opus explain the difference between REST and GraphQL"
```

#### 🔍 Code Review
```bash
# Get instant feedback on your code
"ask Gemini to review this function for best practices"
"have DeepSeek check my authentication code"
"get Opus to analyze this SQL query: SELECT * FROM users WHERE..."
"let O3 review my React component for improvements"
```

#### 💡 Brainstorming
```bash
# Generate creative solutions and ideas
"ask Grok to brainstorm ways to reduce API latency"
"have Gemini suggest innovative caching strategies"
"get O3 to propose microservice architectures for my app"
"let DeepSeek ideate on database optimization techniques"
```

#### ⚡ Performance Analysis
```bash
# Optimize your code for speed
"ask O3 to analyze performance of my sorting algorithm"
"have Gemini optimize this nested loop for better efficiency"
"get DeepSeek to check why my API is slow"
"let Opus improve performance of my database queries"
```

#### 🔐 Security Review
```bash
# Find and fix security vulnerabilities
"ask DeepSeek to check security of my login endpoint"
"have Opus find vulnerabilities in my password handling"
"get Gemini to analyze my JWT implementation for security issues"
"let O3 review my SQL queries for injection vulnerabilities"
```

### 🔧 Direct Tool Usage (For Power Users)

If you prefer the traditional approach, you can still use direct MCP commands:

```bash
# General collaboration
mcp__ai-assistant__pair
  prompt: "Explain recursion"
  model: "Gemini"  # optional

# Code review
mcp__ai-assistant__review
  code: "def factorial(n): return n * factorial(n-1)"
  model: "O3"
```

### 🌈 Why Natural Language Rocks!

❌ **Old way** (complex and hard to remember):
```bash
mcp__ai-assistant__review
  code: "def factorial(n): return n * factorial(n-1)"
  model: "Gemini"
```

✅ **New way** (just say what you want!):
```bash
"ask Gemini to review this code: def factorial(n): return n * factorial(n-1)"
```

### 📦 Natural Language Pattern Guide

#### The Magic Formula: `"ask [Model] to [action] [content]"`

| What You Want | Magic Words | Example |
|--------------|-------------|----------|
| 💬 **Help & Explanations** | explain, help, teach, show | `"ask Gemini to explain async/await"` |
| 🔍 **Code Review** | review, check, analyze | `"ask O3 to review my auth function"` |
| 💡 **Ideas & Solutions** | brainstorm, suggest, ideate | `"ask Grok to brainstorm API designs"` |
| ⚡ **Speed It Up** | optimize, analyze performance | `"ask DeepSeek to optimize my loop"` |
| 🔐 **Security Check** | check security, find vulnerabilities | `"ask Opus to check security of my login"` |

#### 🎯 Pro Tips:
- 🎲 **Mix it up!** Use "have", "get", or "let" instead of "ask"
- 🤖 **Any model works!** O3, Gemini, Grok, DeepSeek, or Opus
- 📦 **Be natural!** Claude understands context and variations


## 🤖 Meet Your AI Team!

### 🌟 **Gemini** (Default) - The All-Rounder
- 🎯 Best for: General questions, quick help, everyday coding
- 🖼️ Supports images: Yes
- 💡 Example: `"ask Gemini to explain Docker containers"`

### 🧠 **O3** - The Deep Thinker
- 🎯 Best for: Complex problems, detailed analysis, tough bugs
- 🖼️ Supports images: Yes
- 💡 Example: `"ask O3 to solve this algorithm challenge"`

### 🚀 **Grok** - The Creative One
- 🎯 Best for: Brainstorming, out-of-the-box ideas, innovation
- 🖼️ Supports images: No
- 💡 Example: `"ask Grok to brainstorm startup ideas"`

### 🔬 **DeepSeek** - The Code Expert
- 🎯 Best for: Code review, technical deep-dives, optimization
- 🖼️ Supports images: No
- 💡 Example: `"ask DeepSeek to optimize my database queries"`

### 🎨 **Opus** - The Perfectionist
- 🎯 Best for: High-quality analysis, nuanced problems, best results
- 🖼️ Supports images: Yes
- 💡 Example: `"ask Opus to review my architecture design"`

## 🔍 Debugging

Enable debug logging:
```bash
export DEBUG=1
claude
```

Check server logs:
```bash
tail -f ~/.claude-mcp-servers/ai-assistant/server.log
```

## 🐛 Troubleshooting

**MCP not showing up?**
```bash
# Check if it's installed
claude mcp list

# Reinstall
claude mcp remove ai-assistant
cd /path/to/ai-assistant-mcp
./setup.sh
```

**API Key Issues?**
- Ensure OPENROUTER_API_KEY is set in your shell profile
- Verify your API key at: https://openrouter.ai/keys
- Check your credit balance on OpenRouter dashboard

**Model Not Found?**
- Use the exact model names from config.json (O3, Gemini, Grok, DeepSeek, Opus)
- Model IDs are handled internally - just use the friendly names

## 🤝 Contributing

Pull requests are welcome! Please ensure:
- Code follows Python best practices
- New models include proper configuration
- Documentation is updated

## 📜 License

MIT License - see LICENSE file for details

## 🙏 Acknowledgments

- Built for the Claude Code community
- Powered by OpenRouter's unified API