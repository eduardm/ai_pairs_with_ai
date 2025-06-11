import json
import logging
import os
import sys
from typing import Dict, Optional, Any
import warnings

import requests
from mcp.server import Server
from mcp.server.stdio import stdio_server
from mcp.server.models import InitializationOptions
from mcp.types import TextContent, Tool, JSONRPCError, ErrorData, ServerCapabilities

# Set up unbuffered output
os.environ['PYTHONUNBUFFERED'] = '1'
sys.stdout = os.fdopen(sys.stdout.fileno(), 'w', 1)
sys.stderr = os.fdopen(sys.stderr.fileno(), 'w', 1)

# Set up logging
logging.basicConfig(
    level=logging.DEBUG if os.getenv('DEBUG', '0') == '1' else logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.StreamHandler(sys.stderr),
        logging.FileHandler(os.path.expanduser('~/.claude-mcp-servers/ai-assistant/server.log'), mode='a')
    ]
)
logger = logging.getLogger(__name__)

# Suppress specific warnings
warnings.filterwarnings("ignore", category=DeprecationWarning, module="pydantic")

class AIAssistantMCPServer:
    """MCP Server for AI Assistant using OpenRouter"""
    
    def __init__(self):
        self.server = Server("ai-assistant")
        self.config = self._load_config()
        self.api_key = self._get_api_key()
        self.base_url = "https://openrouter.ai/api/v1/chat/completions"
        self._setup_tools()
        self._setup_handlers()
        logger.info("AI Assistant MCP Server initialized")
    
    def _load_config(self) -> dict:
        """Load configuration from config.json"""
        config_path = os.path.join(os.path.dirname(__file__), 'config.json')
        try:
            with open(config_path, 'r') as f:
                config = json.load(f)
                logger.info("Configuration loaded successfully")
                return config
        except Exception as e:
            logger.error(f"Failed to load config: {str(e)}")
            raise RuntimeError("Configuration file is required")
    
    def _get_api_key(self) -> str:
        """Get OpenRouter API key"""
        api_key = os.getenv(self.config.get('api_key_env', 'OPENROUTER_API_KEY'))
        if not api_key:
            logger.error("OpenRouter API key not found")
            logger.info("Please set the OPENROUTER_API_KEY environment variable")
            raise RuntimeError("OpenRouter API key is required")
        return api_key
    
    async def _call_openrouter(self, prompt: str, model: str, temperature: float = 0.3, max_tokens: int = 4096) -> str:
        """Make API call to OpenRouter"""
        if model not in self.config.get('models', {}):
            available = ", ".join(self.config.get('models', {}).keys())
            raise ValueError(f"Model '{model}' not available. Available models: {available}")
        
        model_config = self.config['models'][model]
        model_id = model_config['model_id']
        supports_images = model_config.get('supports_images', False)
        
        headers = {
            "Authorization": f"Bearer {self.api_key}",
            "Content-Type": "application/json",
            "HTTP-Referer": "https://github.com/claude-mcp/ai-assistant",
            "X-Title": "AI Assistant MCP Server"
        }
        
        # For now, we'll use simple text format for all models
        # Future enhancement: Add image support based on supports_images flag
        data = {
            "model": model_id,
            "messages": [{"role": "user", "content": prompt}],
            "temperature": temperature,
            "max_tokens": model_config.get('max_tokens', max_tokens)
        }
        
        logger.debug(f"OpenRouter request - Model: {model} ({model_id}), Temperature: {temperature}")
        
        try:
            response = requests.post(self.base_url, headers=headers, json=data, timeout=120)
            response.raise_for_status()
            result = response.json()
            content = result['choices'][0]['message']['content']
            logger.debug(f"OpenRouter response received - Length: {len(content)}")
            return content
        except Exception as e:
            logger.error(f"OpenRouter API error: {str(e)}")
            if hasattr(e, 'response') and hasattr(e.response, 'text'):
                logger.error(f"Response details: {e.response.text}")
            raise
    
    def _setup_tools(self):
        """Set up available tools"""
        available_models = ", ".join(self.config.get('models', {}).keys())
        
        self.tools = [
            Tool(
                name="pair",
                description="Collaborate with AI on any topic - ask questions, brainstorm ideas, or work through problems together",
                inputSchema={
                    "type": "object",
                    "properties": {
                        "prompt": {
                            "type": "string",
                            "description": "Your question or topic to discuss"
                        },
                        "model": {
                            "type": "string",
                            "description": f"Model to use: {available_models}",
                            "default": self.config.get('default_model', 'Gemini')
                        },
                        "temperature": {
                            "type": "number",
                            "description": "Response creativity (0.0-1.0)",
                            "default": 0.5
                        }
                    },
                    "required": ["prompt"]
                }
            ),
            Tool(
                name="review",
                description="Get comprehensive code review with actionable feedback",
                inputSchema={
                    "type": "object",
                    "properties": {
                        "code": {
                            "type": "string",
                            "description": "Code to review"
                        },
                        "context": {
                            "type": "string",
                            "description": "Additional context about the code",
                            "default": ""
                        },
                        "model": {
                            "type": "string",
                            "description": f"Model to use: {available_models}",
                            "default": self.config.get('default_model', 'Gemini')
                        }
                    },
                    "required": ["code"]
                }
            ),
            Tool(
                name="brainstorm",
                description="Brainstorm creative solutions and explore ideas",
                inputSchema={
                    "type": "object",
                    "properties": {
                        "topic": {
                            "type": "string",
                            "description": "Topic to brainstorm about"
                        },
                        "constraints": {
                            "type": "string",
                            "description": "Any constraints or requirements",
                            "default": ""
                        },
                        "model": {
                            "type": "string",
                            "description": f"Model to use: {available_models}",
                            "default": self.config.get('default_model', 'Gemini')
                        }
                    },
                    "required": ["topic"]
                }
            ),
            Tool(
                name="review_performance",
                description="Analyze code for performance issues and optimization opportunities",
                inputSchema={
                    "type": "object",
                    "properties": {
                        "code": {
                            "type": "string",
                            "description": "Code to analyze for performance"
                        },
                        "context": {
                            "type": "string",
                            "description": "Context about expected usage patterns",
                            "default": ""
                        },
                        "model": {
                            "type": "string",
                            "description": f"Model to use: {available_models}",
                            "default": self.config.get('default_model', 'Gemini')
                        }
                    },
                    "required": ["code"]
                }
            ),
            Tool(
                name="review_security",
                description="Security-focused code review to identify vulnerabilities",
                inputSchema={
                    "type": "object",
                    "properties": {
                        "code": {
                            "type": "string",
                            "description": "Code to analyze for security issues"
                        },
                        "context": {
                            "type": "string",
                            "description": "Security context or requirements",
                            "default": ""
                        },
                        "model": {
                            "type": "string",
                            "description": f"Model to use: {available_models}",
                            "default": self.config.get('default_model', 'Gemini')
                        }
                    },
                    "required": ["code"]
                }
            )
        ]
    
    def _setup_handlers(self):
        """Set up request handlers"""
        
        @self.server.list_tools()
        async def list_tools():
            logger.debug("list_tools called")
            return self.tools
        
        @self.server.call_tool()
        async def call_tool(name: str, arguments: Dict[str, Any]) -> list[TextContent]:
            logger.info(f"Tool called: {name} with model: {arguments.get('model', self.config.get('default_model'))}")
            
            try:
                if name == "pair":
                    prompt = arguments['prompt']
                    model = arguments.get('model', self.config.get('default_model'))
                    temperature = arguments.get('temperature', 0.5)
                    
                    response = await self._call_openrouter(prompt, model, temperature)
                    
                elif name == "review":
                    code = arguments['code']
                    context = arguments.get('context', '')
                    model = arguments.get('model', self.config.get('default_model'))
                    
                    prompt = f"""Please provide a comprehensive code review for the following code.

Context: {context if context else "No additional context provided"}

Code to review:
```
{code}
```

Please analyze:
1. Code quality and readability
2. Potential bugs or issues
3. Performance considerations
4. Security concerns
5. Best practices and improvements
6. Overall architecture and design

Provide specific, actionable feedback with examples where appropriate."""
                    
                    response = await self._call_openrouter(prompt, model, temperature=0.3)
                    
                elif name == "brainstorm":
                    topic = arguments['topic']
                    constraints = arguments.get('constraints', '')
                    model = arguments.get('model', self.config.get('default_model'))
                    
                    prompt = f"""Let's brainstorm creative ideas and solutions for: {topic}

{f'Constraints/Requirements: {constraints}' if constraints else ''}

Please provide:
1. Multiple creative approaches or solutions
2. Pros and cons of each approach
3. Unconventional or innovative ideas
4. Practical implementation considerations
5. Potential challenges and how to address them

Be creative and think outside the box!"""
                    
                    response = await self._call_openrouter(prompt, model, temperature=0.7)
                    
                elif name == "review_performance":
                    code = arguments['code']
                    context = arguments.get('context', '')
                    model = arguments.get('model', self.config.get('default_model'))
                    
                    prompt = f"""Please analyze the following code for performance issues and optimization opportunities.

Usage context: {context if context else "General purpose usage"}

Code to analyze:
```
{code}
```

Please identify:
1. Performance bottlenecks
2. Time complexity analysis
3. Space complexity concerns
4. Optimization opportunities
5. Caching strategies
6. Algorithm improvements
7. Resource usage concerns

Provide specific recommendations with code examples where applicable."""
                    
                    response = await self._call_openrouter(prompt, model, temperature=0.3)
                    
                elif name == "review_security":
                    code = arguments['code']
                    context = arguments.get('context', '')
                    model = arguments.get('model', self.config.get('default_model'))
                    
                    prompt = f"""Please perform a security-focused review of the following code.

Security context: {context if context else "Standard security requirements"}

Code to analyze:
```
{code}
```

Please identify:
1. Security vulnerabilities (injection, XSS, etc.)
2. Authentication/authorization issues
3. Data validation concerns
4. Cryptographic weaknesses
5. Information disclosure risks
6. OWASP Top 10 considerations
7. Security best practices violations

Provide specific vulnerabilities with severity levels and remediation recommendations."""
                    
                    response = await self._call_openrouter(prompt, model, temperature=0.2)
                    
                else:
                    raise JSONRPCError(code=-32601, message=f"Tool '{name}' not found")
                
                logger.info(f"Tool {name} completed successfully using model {arguments.get('model', self.config.get('default_model'))}")
                
                return [TextContent(type="text", text=response)]
                
            except Exception as e:
                logger.error(f"Error in tool {name}: {str(e)}")
                if isinstance(e, JSONRPCError):
                    raise
                else:
                    raise JSONRPCError(code=-32603, message=str(e))
    
    async def run(self):
        """Run the MCP server"""
        logger.info("Starting AI Assistant MCP Server...")
        logger.info(f"Available models: {', '.join(self.config.get('models', {}).keys())}")
        logger.info(f"Default model: {self.config.get('default_model', 'Gemini')}")
        
        # Create initialization options
        init_options = InitializationOptions(
            server_name="ai-assistant",
            server_version="1.0.0",
            capabilities=ServerCapabilities(tools={})
        )
        
        async with stdio_server() as (read_stream, write_stream):
            try:
                await self.server.run(read_stream, write_stream, init_options)
            except Exception as e:
                logger.error(f"Server error: {str(e)}")
                raise

async def main():
    """Main entry point"""
    try:
        server = AIAssistantMCPServer()
        await server.run()
    except KeyboardInterrupt:
        logger.info("Server stopped by user")
    except Exception as e:
        logger.error(f"Fatal error: {str(e)}")
        sys.exit(1)

if __name__ == "__main__":
    import asyncio
    asyncio.run(main())