# 🚀 Quick Start Guide

Get your local coding AI running in 5 minutes!

## One-Line Installation

```bash
wget https://github.com/yourusername/local-coding-ai/archive/main.tar.gz && \
tar -xzf main.tar.gz && \
cd local-coding-ai-main && \
./scripts/install.sh
```

## Step-by-Step Installation

### 1. Download & Extract

```bash
# Clone from GitHub
git clone https://github.com/yourusername/local-coding-ai.git
cd local-coding-ai

# OR download the release
wget https://github.com/yourusername/local-coding-ai/releases/latest/download/local-coding-ai.tar.gz
tar -xzf local-coding-ai.tar.gz
cd local-coding-ai
```

### 2. Run Installation

```bash
chmod +x scripts/install.sh
./scripts/install.sh
```

The installer will:
- ✅ Check system requirements
- ✅ Install Python dependencies
- ✅ Install Ollama
- ✅ Download an AI model (you choose which one)

### 3. Start the Server

```bash
./start.sh
```

Or manually:
```bash
python3 src/server.py
```

### 4. Open Your Browser

Navigate to: **http://localhost:5000**

## 🎯 First Steps

### Try These Prompts

```
1. "Write a Python function to calculate fibonacci numbers"

2. "Explain this code: [paste your code]"

3. "Find the bug: [paste buggy code]"

4. "Optimize this SQL query: [paste query]"

5. "Create a REST API endpoint in Flask for user registration"
```

## ⚙️ Configuration

### Change Port

```bash
python3 src/server.py --port 8080
```

### Switch Model

Use the dropdown in the web UI, or:

```bash
ollama pull deepseek-coder  # Download new model
# Then select it in the UI
```

### Enable Remote Access

Edit `src/server.py` and change:
```python
app.run(host='0.0.0.0', port=5000)  # WARNING: Exposes to network
```

## 🐛 Troubleshooting

### Ollama Not Running

```bash
# Start Ollama
ollama serve

# Or check if it's running
ps aux | grep ollama
```

### No Models Available

```bash
# Download a model
ollama pull codellama

# List installed models
ollama list
```

### Port Already in Use

```bash
# Find what's using port 5000
sudo lsof -i :5000

# Use a different port
python3 src/server.py --port 8080
```

### Slow Responses

- Try a smaller model: `ollama pull codellama` (instead of phind-codellama)
- Close other applications to free RAM
- Check if GPU is being used: `nvidia-smi` (if you have NVIDIA GPU)

## 📚 Next Steps

- Read the [full README](README.md)
- Check [troubleshooting guide](docs/TROUBLESHOOTING.md)
- Learn about [available models](docs/MODELS.md)
- Contribute! See [CONTRIBUTING.md](docs/CONTRIBUTING.md)

## 💡 Tips

1. **Use Ctrl+C** to stop the server
2. **Shift+Enter** for multi-line input in the chat
3. **Switch models** for different tasks (CodeLlama for general, DeepSeek for complex code)
4. **Check logs** if something breaks: `/tmp/ollama.log`

## 🆘 Get Help

- **GitHub Issues**: Report bugs
- **Discussions**: Ask questions
- **Documentation**: Check the docs/ folder

---

**That's it! You're ready to code with AI! 🎉**
