# AI Assistant Natural Language Interface

## Overview

This document provides instructions for Claude Code to automatically detect and translate natural language requests into AI assistant tool calls.

## Natural Language Detection Rules

### Pattern Recognition

When you detect prompts matching these patterns, automatically translate them to the appropriate MCP tool call:

#### General Patterns
- `"ask [Model] to [action] [content]"`
- `"have [Model] [action] [content]"`
- `"get [Model] to [action] [content]"`
- `"let [Model] [action] [content]"`

Where:
- `[Model]` = O3, Gemini, Grok, DeepSeek, or Opus (case-insensitive)
- `[action]` = action keywords listed below
- `[content]` = the rest of the user's request

### Action Keyword Mappings

#### 1. General Collaboration → `mcp__ai-assistant__pair`
**Keywords**: explain, help, discuss, answer, solve, implement, create, write, build, design, develop, clarify, demonstrate, show, teach, guide, assist

**Examples**:
- "ask Gemini to explain recursion" → `mcp__ai-assistant__pair` with prompt="explain recursion", model="Gemini"
- "have O3 help with implementing a binary tree" → `mcp__ai-assistant__pair` with prompt="help with implementing a binary tree", model="O3"
- "get DeepSeek to solve this algorithm problem" → `mcp__ai-assistant__pair` with prompt="solve this algorithm problem", model="DeepSeek"

#### 2. Code Review → `mcp__ai-assistant__review`
**Keywords**: review, check, analyze, inspect, examine, critique, evaluate (when followed by "code", "function", "script", or actual code)

**Examples**:
- "ask Gemini to review this code: def factorial(n): ..." → `mcp__ai-assistant__review` with code="def factorial(n): ...", model="Gemini"
- "have DeepSeek check my authentication function" → `mcp__ai-assistant__review` with code=[function content], model="DeepSeek"
- "get Opus to analyze this SQL query" → `mcp__ai-assistant__review` with code=[SQL query], model="Opus"

#### 3. Brainstorming → `mcp__ai-assistant__brainstorm`
**Keywords**: brainstorm, suggest, ideate, propose, recommend (when about ideas/solutions)

**Examples**:
- "ask Grok to brainstorm API optimization strategies" → `mcp__ai-assistant__brainstorm` with topic="API optimization strategies", model="Grok"
- "have Gemini suggest database architectures" → `mcp__ai-assistant__brainstorm` with topic="database architectures", model="Gemini"
- "get O3 to propose solutions for scaling" → `mcp__ai-assistant__brainstorm` with topic="solutions for scaling", model="O3"

#### 4. Performance Analysis → `mcp__ai-assistant__review_performance`
**Keywords**: "analyze performance", "check performance", "optimize", "improve performance", "performance review"

**Examples**:
- "ask Gemini to analyze performance of my sorting algorithm" → `mcp__ai-assistant__review_performance` with code=[algorithm code], model="Gemini"
- "have O3 optimize this nested loop" → `mcp__ai-assistant__review_performance` with code=[loop code], model="O3"
- "get DeepSeek to check performance issues" → `mcp__ai-assistant__review_performance` with code=[relevant code], model="DeepSeek"

#### 5. Security Review → `mcp__ai-assistant__review_security`
**Keywords**: "check security", "find vulnerabilities", "security review", "analyze security", "security issues"

**Examples**:
- "ask DeepSeek to check security of my login endpoint" → `mcp__ai-assistant__review_security` with code=[endpoint code], model="DeepSeek"
- "have Opus find vulnerabilities in this SQL" → `mcp__ai-assistant__review_security` with code=[SQL code], model="Opus"
- "get Gemini to analyze security issues" → `mcp__ai-assistant__review_security` with code=[relevant code], model="Gemini"

## Implementation Guidelines

### 1. Pattern Matching
- Use case-insensitive matching for model names
- Be flexible with whitespace and punctuation
- Support variations like "ask gemini", "Ask Gemini", "ASK GEMINI"

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
- When users reference "this code" or "my function", check recent context or ask for clarification
- If code needs to be read from a file, use the Read tool first

### 5. Error Handling
- If a pattern is ambiguous, ask for clarification
- If a model doesn't support images but an image is referenced, inform the user

## Examples of Complete Translations

1. **Input**: "ask gemini to explain how async/await works in Python"
   **Translation**: 
   ```
   mcp__ai-assistant__pair
     prompt: "explain how async/await works in Python"
     model: "Gemini"
   ```

2. **Input**: "have deepseek review this function for security issues"
   **Translation**: 
   ```
   mcp__ai-assistant__review_security
     code: [function content from context or file]
     model: "DeepSeek"
   ```

3. **Input**: "get grok to brainstorm ways to reduce database latency"
   **Translation**: 
   ```
   mcp__ai-assistant__brainstorm
     topic: "ways to reduce database latency"
     model: "Grok"
   ```

## Default Behavior

If a natural language request is detected but doesn't specify a model, use the default model (Gemini) and inform the user which model is being used.

## User Education

When translating natural language requests, briefly show the user what tool is being called so they understand the system better. For example:
"I'll ask Gemini to explain recursion for you using the AI assistant."