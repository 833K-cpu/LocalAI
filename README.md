# 🤖 Local Coding AI

<div align="center">

![Python Version](https://img.shields.io/badge/python-3.8%2B-blue)
![License](https://img.shields.io/badge/license-MIT-green)
![Platform](https://img.shields.io/badge/platform-linux-lightgrey)
![Ollama](https://img.shields.io/badge/ollama-powered-orange)

**A powerful, privacy-focused coding assistant that runs entirely on your local machine**

[Features](#-features) •
[Quick Start](#-quick-start) •
[Installation](#-installation) •
[Usage](#-usage) •
[Documentation](#-documentation)

![Demo Screenshot](https://via.placeholder.com/800x400/667eea/ffffff?text=LocalAI+Demo)

</div>

---

## 🎯 Overview

Local Coding AI is a self-hosted coding assistant powered by Ollama that runs completely offline. No cloud dependencies, no data collection, no API keys required. Your code and conversations stay on your machine.

### Why Local Coding AI?

- **🔒 Privacy First**: All processing happens locally - your code never leaves your machine
- **⚡ Zero Latency**: No network delays, instant responses
- **💰 Free Forever**: No subscriptions, API costs, or usage limits
- **🎨 Modern UI**: Beautiful, responsive web interface
- **🧠 Multiple Models**: Switch between different AI models on the fly
- **📝 Code-Optimized**: Specially tuned for programming tasks

---

## ✨ Features

### Core Capabilities

- **Multi-Language Support**: Python, JavaScript, TypeScript, Java, C++, Rust, Go, and more
- **Real-Time Streaming**: See AI responses as they're generated
- **Syntax Highlighting**: Beautiful code formatting in the chat
- **Model Selection**: Choose from CodeLlama, DeepSeek Coder, Mistral, and more
- **Context-Aware**: Maintains conversation context for better responses
- **Lightweight**: Minimal dependencies, runs on modest hardware

### Use Cases

✅ Generate code snippets and functions  
✅ Debug and fix code issues  
✅ Explain complex algorithms  
✅ Refactor and optimize code  
✅ Write documentation  
✅ Create unit tests  
✅ Learn new programming concepts  
✅ Get architecture suggestions  

---

## 🚀 Quick Start

Get up and running in 3 commands:

```bash
# 1. Clone the repository
git clone https://github.com/833K-cpu/localai.git
cd local-coding-ai

# 2. Run the installation script
./scripts/install.sh

# 3. Start the server
python3 src/server.py
```

Open your browser to `http://localhost:5000` and start coding with AI! 🎉

---

## 📦 Installation

### Prerequisites

- **OS**: Linux (Ubuntu 20.04+, Debian 11+, Fedora 35+, Arch)
- **Python**: 3.8 or higher
- **RAM**: 8 GB minimum (16 GB recommended)
- **Storage**: 10 GB free space
- **Optional**: NVIDIA GPU with CUDA for acceleration

### Method 1: Automated Installation (Recommended)

```bash
chmod +x scripts/install.sh
./scripts/install.sh
```

The script will:
- ✅ Verify system requirements
- ✅ Install Python dependencies
- ✅ Install and configure Ollama
- ✅ Download your preferred AI model
- ✅ Set up the server

### Method 2: Manual Installation

<details>
<summary>Click to expand manual installation steps</summary>

#### 1. Install Ollama

```bash
curl -fsSL https://ollama.com/install.sh | sh
```

#### 2. Install Python Dependencies

```bash
pip3 install -r requirements.txt
```

Or manually:
```bash
pip3 install flask requests --break-system-packages
```

#### 3. Download an AI Model

```bash
# Recommended: CodeLlama (balanced performance)
ollama pull codellama

# Alternative: DeepSeek Coder (specialized for code)
ollama pull deepseek-coder

# For powerful systems: Phind CodeLlama (highest quality)
ollama pull phind-codellama
```

#### 4. Start Ollama Service

```bash
ollama serve
```

</details>

---

## 🎮 Usage

### Starting the Server

```bash
# Standard mode
python3 src/server.py

# Custom port
python3 src/server.py --port 8080

# Development mode (with auto-reload)
python3 src/server.py --debug
```

### Web Interface

Navigate to `http://localhost:5000` in your browser.

**Example Prompts:**

```
Write a Python function to reverse a string

Explain this code: [paste your code]

Find the bug in this JavaScript: [paste code with error]

Optimize this SQL query for better performance: [paste query]

Create a binary search tree implementation in C++

Write unit tests for this function: [paste function]
```

### API Usage

You can also use the REST API directly:

```bash
curl -X POST http://localhost:5000/api/chat \
  -H "Content-Type: application/json" \
  -d '{
    "message": "Write a fibonacci function in Python",
    "model": "codellama"
  }'
```

---

## 🧠 Available Models

| Model | Size | RAM Needed | Best For | Command |
|-------|------|------------|----------|---------|
| **CodeLlama** | 7B | 8 GB | General coding (Recommended) | `ollama pull codellama` |
| **DeepSeek Coder** | 6.7B | 8 GB | Code generation | `ollama pull deepseek-coder` |
| **Phind CodeLlama** | 34B | 20 GB | Advanced coding (High-end) | `ollama pull phind-codellama` |
| **Mistral** | 7B | 8 GB | General purpose | `ollama pull mistral` |
| **CodeGemma** | 7B | 8 GB | Google's code model | `ollama pull codegemma` |

### Switching Models

You can switch models in the web UI using the dropdown menu, or specify it via API:

```python
import requests

response = requests.post('http://localhost:5000/api/chat', json={
    'message': 'Your prompt here',
    'model': 'deepseek-coder'  # Specify model
})
```

---

## ⚙️ Configuration

### Environment Variables

Create a `.env` file in the project root:

```env
# Server Configuration
PORT=5000
HOST=0.0.0.0
DEBUG=false

# Ollama Configuration
OLLAMA_HOST=http://localhost:11434
DEFAULT_MODEL=codellama

# Performance
MAX_TOKENS=2048
TEMPERATURE=0.7
```

### Advanced Configuration

Edit `src/config.py` for more options:

```python
# Response streaming
STREAM_ENABLED = True

# Max conversation history
MAX_HISTORY = 10

# Timeout settings
REQUEST_TIMEOUT = 300

# CORS settings (for external access)
CORS_ENABLED = False
```

---

## 🏗️ Project Structure

```
local-coding-ai/
├── src/
│   ├── server.py              # Main Flask application
│   ├── config.py              # Configuration management
│   ├── api/
│   │   ├── chat.py           # Chat API endpoints
│   │   └── models.py         # Model management
│   ├── templates/
│   │   └── index.html        # Web UI template
│   └── static/
│       ├── css/
│       ├── js/
│       └── assets/
├── scripts/
│   ├── install.sh            # Installation script
│   ├── start.sh              # Startup script
│   └── update_models.sh      # Model update script
├── docs/
│   ├── CONTRIBUTING.md       # Contribution guidelines
│   ├── API.md                # API documentation
│   └── TROUBLESHOOTING.md    # Common issues and solutions
├── tests/
│   ├── test_api.py           # API tests
│   └── test_models.py        # Model tests
├── .github/
│   └── workflows/
│       └── ci.yml            # GitHub Actions CI
├── requirements.txt          # Python dependencies
├── .env.example             # Environment template
├── LICENSE                  # MIT License
└── README.md               # This file
```

---

## 🐛 Troubleshooting

### Ollama Connection Error

```bash
# Check if Ollama is running
ps aux | grep ollama

# Start Ollama service
ollama serve

# Or use systemd (if available)
sudo systemctl start ollama
```

### Model Not Found

```bash
# List installed models
ollama list

# Pull missing model
ollama pull codellama
```

### Port Already in Use

```bash
# Find process using port 5000
sudo lsof -i :5000

# Kill the process
kill -9 <PID>

# Or use a different port
python3 src/server.py --port 8080
```

### Slow Responses

- Use a smaller model (codellama instead of phind-codellama)
- Close other applications to free RAM
- Enable GPU acceleration if available
- Increase system swap space

For more solutions, see [TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md)

---

## 📊 Performance

### Benchmarks

Tested on Ubuntu 22.04 with different hardware configurations:

| Hardware | Model | Response Time | Quality |
|----------|-------|---------------|---------|
| 16GB RAM, i7-10700 | CodeLlama 7B | ~2-3s | ⭐⭐⭐⭐ |
| 32GB RAM, RTX 3060 | CodeLlama 7B | ~1s | ⭐⭐⭐⭐ |
| 64GB RAM, RTX 4090 | Phind 34B | ~2s | ⭐⭐⭐⭐⭐ |

### Optimization Tips

**For CPU-only systems:**
- Use quantized models (Q4 or Q5)
- Reduce context window size
- Limit conversation history

**For GPU-accelerated systems:**
```bash
# Verify CUDA is available
nvidia-smi

# Ollama will automatically use GPU
```

---

## 🔐 Security & Privacy

### Data Privacy

- ✅ **100% Local Processing**: No data sent to external servers
- ✅ **No Telemetry**: No usage tracking or analytics
- ✅ **No API Keys**: No third-party authentication required
- ✅ **Offline Capable**: Works without internet connection

### Network Security

By default, the server only listens on `localhost`. To enable network access:

```python
# In src/server.py
app.run(host='0.0.0.0', port=5000)  # WARNING: Exposes to network
```

**Recommended**: Use a reverse proxy (nginx) with SSL/TLS for remote access.

---

## 🤝 Contributing

We welcome contributions! Here's how you can help:

1. **Fork the repository**
2. **Create a feature branch**: `git checkout -b feature/amazing-feature`
3. **Commit your changes**: `git commit -m 'Add amazing feature'`
4. **Push to branch**: `git push origin feature/amazing-feature`
5. **Open a Pull Request**

Please read [CONTRIBUTING.md](docs/CONTRIBUTING.md) for details on our code of conduct and development process.

### Development Setup

```bash
# Clone your fork
git clone https://github.com/yourusername/local-coding-ai.git
cd local-coding-ai

# Install dev dependencies
pip3 install -r requirements-dev.txt

# Run tests
python3 -m pytest tests/

# Run linter
flake8 src/
```

---

## 📚 Documentation

- **[API Documentation](docs/API.md)** - REST API reference
- **[Troubleshooting Guide](docs/TROUBLESHOOTING.md)** - Common issues and fixes
- **[Contributing Guide](docs/CONTRIBUTING.md)** - How to contribute
- **[Model Guide](docs/MODELS.md)** - Detailed model comparison
- **[Deployment Guide](docs/DEPLOYMENT.md)** - Production deployment tips

---

## 🗺️ Roadmap

- [ ] **v2.0**: Plugin system for custom tools
- [ ] **v2.1**: Multi-model ensemble responses
- [ ] **v2.2**: Code execution sandbox
- [ ] **v2.3**: Git integration
- [ ] **v2.4**: VS Code extension
- [ ] **v2.5**: Docker container support
- [ ] **v3.0**: Fine-tuning interface

See [ROADMAP.md](docs/ROADMAP.md) for detailed plans.

---

## 🌟 Acknowledgments

Built with amazing open-source projects:

- **[Ollama](https://ollama.ai)** - Local LLM runtime
- **[Flask](https://flask.palletsprojects.com/)** - Web framework
- **[CodeLlama](https://github.com/facebookresearch/codellama)** - Meta's coding model
- **[DeepSeek Coder](https://github.com/deepseek-ai/deepseek-coder)** - DeepSeek's coding model

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## ⭐ Star History

[![Star History Chart](https://api.star-history.com/svg?repos=833K-cpu/localai&type=Date)](https://star-history.com/#833K-cpu/localai&Date)

---

## 💬 Support

- **Issues**: [GitHub Issues](https://github.com/833K-cpu/localai/issues)
- **Discussions**: [GitHub Discussions](https://github.com/833K-cpu/localai/discussions)
- **Email**: xvm0@web.de

---

<div align="center">

Made with ❤️ by developers, for developers

**[⬆ Back to Top](#-localai)**

</div>
