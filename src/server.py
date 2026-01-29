#!/usr/bin/env python3
"""
Local Coding AI Server
A self-hosted coding assistant powered by Ollama
"""

import os
import sys
import json
import logging
import argparse
from pathlib import Path
from typing import Generator, Dict, Any

from flask import Flask, render_template, request, jsonify, Response, send_from_directory
import requests
from requests.exceptions import RequestException, ConnectionError, Timeout

# Configuration
DEFAULT_PORT = 5000
DEFAULT_HOST = '127.0.0.1'
OLLAMA_API_URL = 'http://localhost:11434'
DEFAULT_MODEL = 'codellama'

# Initialize Flask app
app = Flask(__name__)
app.config['SECRET_KEY'] = os.urandom(24)
app.config['JSON_SORT_KEYS'] = False

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)


class OllamaClient:
    """Client for interacting with Ollama API"""
    
    def __init__(self, base_url: str = OLLAMA_API_URL):
        self.base_url = base_url
        self.session = requests.Session()
        
    def check_health(self) -> bool:
        """Check if Ollama service is running"""
        try:
            response = self.session.get(f"{self.base_url}/api/tags", timeout=5)
            return response.status_code == 200
        except (ConnectionError, Timeout, RequestException):
            return False
    
    def list_models(self) -> list:
        """List available models"""
        try:
            response = self.session.get(f"{self.base_url}/api/tags", timeout=5)
            if response.status_code == 200:
                return response.json().get('models', [])
            return []
        except (ConnectionError, Timeout, RequestException) as e:
            logger.error(f"Error listing models: {e}")
            return []
    
    def generate_stream(self, model: str, prompt: str, 
                       system_prompt: str = None) -> Generator[Dict[str, Any], None, None]:
        """Generate streaming response from Ollama"""
        payload = {
            'model': model,
            'prompt': prompt,
            'stream': True
        }
        
        if system_prompt:
            payload['system'] = system_prompt
        
        try:
            response = self.session.post(
                f"{self.base_url}/api/generate",
                json=payload,
                stream=True,
                timeout=300
            )
            response.raise_for_status()
            
            for line in response.iter_lines():
                if line:
                    try:
                        yield json.loads(line.decode('utf-8'))
                    except json.JSONDecodeError as e:
                        logger.error(f"JSON decode error: {e}")
                        continue
                        
        except (ConnectionError, Timeout) as e:
            logger.error(f"Connection error: {e}")
            yield {'error': 'Connection to Ollama failed. Is Ollama running?'}
        except RequestException as e:
            logger.error(f"Request error: {e}")
            yield {'error': f'Request failed: {str(e)}'}


# Initialize Ollama client
ollama = OllamaClient()


@app.route('/')
def index():
    """Serve the main web interface"""
    return render_template('index.html')


@app.route('/api/health')
def health_check():
    """Health check endpoint"""
    ollama_status = ollama.check_health()
    models = ollama.list_models() if ollama_status else []
    
    return jsonify({
        'status': 'healthy' if ollama_status else 'degraded',
        'ollama_connected': ollama_status,
        'models_available': len(models),
        'models': [m.get('name', 'unknown') for m in models]
    })


@app.route('/api/models')
def get_models():
    """Get list of available models"""
    models = ollama.list_models()
    return jsonify({
        'models': [
            {
                'name': m.get('name', 'unknown'),
                'size': m.get('size', 0),
                'modified': m.get('modified_at', '')
            }
            for m in models
        ]
    })


@app.route('/api/chat', methods=['POST'])
def chat():
    """Chat endpoint for code assistance"""
    data = request.json
    
    if not data:
        return jsonify({'error': 'No data provided'}), 400
    
    user_message = data.get('message', '').strip()
    model = data.get('model', DEFAULT_MODEL)
    
    if not user_message:
        return jsonify({'error': 'Message is required'}), 400
    
    # System prompt for coding assistance
    system_prompt = """You are an expert coding assistant. You help developers with:
- Writing clean, efficient code
- Debugging and fixing errors
- Explaining complex algorithms
- Code reviews and optimization
- Best practices and design patterns

Provide clear, concise answers with code examples when relevant.
Use markdown formatting for code blocks with language specification."""
    
    def generate():
        """Generate streaming response"""
        try:
            for chunk in ollama.generate_stream(model, user_message, system_prompt):
                if 'error' in chunk:
                    yield f"data: {json.dumps({'error': chunk['error']})}\n\n"
                    break
                    
                if 'response' in chunk:
                    yield f"data: {json.dumps({'response': chunk['response']})}\n\n"
                
                if chunk.get('done', False):
                    stats = {
                        'total_duration': chunk.get('total_duration', 0),
                        'load_duration': chunk.get('load_duration', 0),
                        'prompt_eval_count': chunk.get('prompt_eval_count', 0),
                        'eval_count': chunk.get('eval_count', 0)
                    }
                    yield f"data: {json.dumps({'done': True, 'stats': stats})}\n\n"
                    
        except Exception as e:
            logger.error(f"Streaming error: {e}")
            yield f"data: {json.dumps({'error': str(e)})}\n\n"
        finally:
            yield "data: [DONE]\n\n"
    
    return Response(generate(), mimetype='text/event-stream')


@app.route('/api/chat/simple', methods=['POST'])
def chat_simple():
    """Simple non-streaming chat endpoint"""
    data = request.json
    
    if not data:
        return jsonify({'error': 'No data provided'}), 400
    
    user_message = data.get('message', '').strip()
    model = data.get('model', DEFAULT_MODEL)
    
    if not user_message:
        return jsonify({'error': 'Message is required'}), 400
    
    try:
        response = requests.post(
            f"{OLLAMA_API_URL}/api/generate",
            json={
                'model': model,
                'prompt': user_message,
                'stream': False
            },
            timeout=300
        )
        response.raise_for_status()
        
        return jsonify(response.json())
        
    except (ConnectionError, Timeout) as e:
        logger.error(f"Connection error: {e}")
        return jsonify({
            'error': 'Connection to Ollama failed. Is Ollama running?'
        }), 503
        
    except RequestException as e:
        logger.error(f"Request error: {e}")
        return jsonify({'error': str(e)}), 500


@app.errorhandler(404)
def not_found(error):
    """Handle 404 errors"""
    return jsonify({'error': 'Endpoint not found'}), 404


@app.errorhandler(500)
def internal_error(error):
    """Handle 500 errors"""
    logger.error(f"Internal server error: {error}")
    return jsonify({'error': 'Internal server error'}), 500


def parse_arguments():
    """Parse command line arguments"""
    parser = argparse.ArgumentParser(
        description='Local Coding AI Server',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  %(prog)s                          # Start with defaults
  %(prog)s --port 8080              # Custom port
  %(prog)s --host 0.0.0.0           # Allow network access
  %(prog)s --debug                  # Enable debug mode
        """
    )
    
    parser.add_argument(
        '--port',
        type=int,
        default=DEFAULT_PORT,
        help=f'Port to run the server on (default: {DEFAULT_PORT})'
    )
    
    parser.add_argument(
        '--host',
        type=str,
        default=DEFAULT_HOST,
        help=f'Host to bind to (default: {DEFAULT_HOST})'
    )
    
    parser.add_argument(
        '--debug',
        action='store_true',
        help='Enable debug mode'
    )
    
    parser.add_argument(
        '--ollama-url',
        type=str,
        default=OLLAMA_API_URL,
        help=f'Ollama API URL (default: {OLLAMA_API_URL})'
    )
    
    return parser.parse_args()


def check_dependencies():
    """Check if required dependencies are installed"""
    try:
        import flask
        import requests
        logger.info("✓ All dependencies found")
        return True
    except ImportError as e:
        logger.error(f"✗ Missing dependency: {e}")
        logger.error("Install dependencies with: pip3 install -r requirements.txt")
        return False


def check_ollama_connection():
    """Check if Ollama is running and accessible"""
    if ollama.check_health():
        models = ollama.list_models()
        logger.info(f"✓ Connected to Ollama ({len(models)} models available)")
        
        if models:
            logger.info("Available models:")
            for model in models:
                logger.info(f"  - {model.get('name', 'unknown')}")
        else:
            logger.warning("⚠ No models found. Download one with: ollama pull codellama")
        
        return True
    else:
        logger.error("✗ Cannot connect to Ollama")
        logger.error("Make sure Ollama is running: ollama serve")
        return False


def main():
    """Main entry point"""
    args = parse_arguments()
    
    # Update global Ollama URL if specified
    global OLLAMA_API_URL
    OLLAMA_API_URL = args.ollama_url
    
    # ASCII banner
    print("\n" + "=" * 60)
    print("  🤖  LOCAL CODING AI SERVER")
    print("=" * 60)
    print()
    
    # Check dependencies
    if not check_dependencies():
        sys.exit(1)
    
    # Check Ollama connection
    if not check_ollama_connection():
        logger.warning("⚠ Server will start but won't work without Ollama")
    
    print()
    print("=" * 60)
    print(f"  Server starting on: http://{args.host}:{args.port}")
    print(f"  Debug mode: {'Enabled' if args.debug else 'Disabled'}")
    print(f"  Ollama URL: {args.ollama_url}")
    print("=" * 60)
    print()
    print("Press Ctrl+C to stop the server")
    print()
    
    # Start server
    try:
        app.run(
            host=args.host,
            port=args.port,
            debug=args.debug,
            threaded=True
        )
    except KeyboardInterrupt:
        print("\n\n👋 Shutting down server...")
    except Exception as e:
        logger.error(f"Failed to start server: {e}")
        sys.exit(1)


if __name__ == '__main__':
    main()
