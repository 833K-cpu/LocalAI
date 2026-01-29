#!/bin/bash

# Local Coding AI - Installation Script
# Automated setup for Linux systems

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configuration
MIN_PYTHON_VERSION="3.8"
REQUIRED_DISK_SPACE=10  # GB
REQUIRED_RAM=8  # GB

# Print functions
print_header() {
    echo -e "${PURPLE}"
    echo "╔════════════════════════════════════════════════════════════╗"
    echo "║                                                            ║"
    echo "║              🤖  LOCAL CODING AI INSTALLER  🤖             ║"
    echo "║                                                            ║"
    echo "║          Self-hosted AI coding assistant for Linux         ║"
    echo "║                                                            ║"
    echo "╚════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

print_step() {
    echo -e "\n${CYAN}▶ $1${NC}"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Get Linux distribution
get_distro() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        echo "$ID"
    else
        echo "unknown"
    fi
}

# Check Python version
check_python_version() {
    if command_exists python3; then
        PYTHON_VERSION=$(python3 -c 'import sys; print(".".join(map(str, sys.version_info[:2])))')
        
        if [ "$(printf '%s\n' "$MIN_PYTHON_VERSION" "$PYTHON_VERSION" | sort -V | head -n1)" = "$MIN_PYTHON_VERSION" ]; then
            return 0
        fi
    fi
    return 1
}

# Check system requirements
check_system_requirements() {
    print_step "Checking system requirements..."
    
    local errors=0
    
    # Check OS
    if [ "$(uname -s)" != "Linux" ]; then
        print_error "This script only supports Linux systems"
        errors=$((errors + 1))
    else
        print_success "Operating System: Linux ($(get_distro))"
    fi
    
    # Check Python
    if check_python_version; then
        print_success "Python: $PYTHON_VERSION"
    else
        print_error "Python 3.8+ is required (found: ${PYTHON_VERSION:-not installed})"
        errors=$((errors + 1))
    fi
    
    # Check RAM
    TOTAL_RAM=$(free -g | awk '/^Mem:/{print $2}')
    if [ "$TOTAL_RAM" -ge "$REQUIRED_RAM" ]; then
        print_success "RAM: ${TOTAL_RAM}GB"
    else
        print_warning "RAM: ${TOTAL_RAM}GB (recommended: ${REQUIRED_RAM}GB+)"
        print_info "The system will work but may be slower with larger models"
    fi
    
    # Check disk space
    DISK_SPACE=$(df -BG . | awk 'NR==2 {print $4}' | sed 's/G//')
    if [ "$DISK_SPACE" -ge "$REQUIRED_DISK_SPACE" ]; then
        print_success "Disk space: ${DISK_SPACE}GB available"
    else
        print_error "Insufficient disk space (${DISK_SPACE}GB available, ${REQUIRED_DISK_SPACE}GB required)"
        errors=$((errors + 1))
    fi
    
    # Check internet connection
    if ping -c 1 google.com &> /dev/null; then
        print_success "Internet connection: Available"
    else
        print_warning "Internet connection: Not available"
        print_info "Internet is required for downloading models"
    fi
    
    if [ $errors -gt 0 ]; then
        echo ""
        print_error "System requirements not met. Please resolve the issues above."
        exit 1
    fi
}

# Install Python dependencies
install_python_deps() {
    print_step "Installing Python dependencies..."
    
    # Check if pip is installed
    if ! command_exists pip3; then
        print_warning "pip3 not found, attempting to install..."
        
        DISTRO=$(get_distro)
        case $DISTRO in
            ubuntu|debian)
                sudo apt-get update
                sudo apt-get install -y python3-pip
                ;;
            fedora)
                sudo dnf install -y python3-pip
                ;;
            arch)
                sudo pacman -S --noconfirm python-pip
                ;;
            *)
                print_error "Could not install pip3 automatically for $DISTRO"
                print_info "Please install pip3 manually and re-run this script"
                exit 1
                ;;
        esac
    fi
    
    print_success "pip3 is available"
    
    # Install dependencies
    print_info "Installing Flask and requests..."
    
    # Try with --break-system-packages first (for newer systems)
    if pip3 install flask requests --break-system-packages &> /dev/null; then
        print_success "Dependencies installed successfully"
    elif pip3 install flask requests &> /dev/null; then
        print_success "Dependencies installed successfully"
    else
        print_error "Failed to install Python dependencies"
        print_info "Try manually: pip3 install flask requests"
        exit 1
    fi
}

# Install Ollama
install_ollama() {
    print_step "Setting up Ollama..."
    
    if command_exists ollama; then
        print_success "Ollama is already installed"
        OLLAMA_VERSION=$(ollama --version 2>&1 | head -n1 || echo "unknown")
        print_info "Version: $OLLAMA_VERSION"
    else
        print_info "Installing Ollama..."
        
        if curl -fsSL https://ollama.com/install.sh | sh; then
            print_success "Ollama installed successfully"
        else
            print_error "Failed to install Ollama"
            print_info "Visit https://ollama.com for manual installation"
            exit 1
        fi
    fi
}

# Start Ollama service
start_ollama() {
    print_step "Starting Ollama service..."
    
    # Check if already running
    if pgrep -x "ollama" > /dev/null; then
        print_success "Ollama is already running"
        return 0
    fi
    
    # Try systemd first
    if command_exists systemctl; then
        if systemctl is-active --quiet ollama 2>/dev/null; then
            print_success "Ollama service is running"
            return 0
        elif systemctl start ollama 2>/dev/null; then
            print_success "Started Ollama via systemd"
            return 0
        fi
    fi
    
    # Fallback to background process
    print_info "Starting Ollama in background..."
    nohup ollama serve > /tmp/ollama.log 2>&1 &
    sleep 3
    
    if pgrep -x "ollama" > /dev/null; then
        print_success "Ollama started successfully"
    else
        print_error "Failed to start Ollama"
        print_info "Try manually: ollama serve"
        exit 1
    fi
}

# Download AI model
download_model() {
    print_step "Selecting AI model to download..."
    echo ""
    
    echo "Available models:"
    echo "  ${GREEN}1)${NC} CodeLlama (7B)         - Recommended, ~4GB RAM"
    echo "  ${GREEN}2)${NC} DeepSeek Coder (6.7B) - Excellent for code, ~4GB RAM"
    echo "  ${GREEN}3)${NC} Phind CodeLlama (34B) - Best quality, ~20GB RAM"
    echo "  ${GREEN}4)${NC} Mistral (7B)          - General purpose, ~4GB RAM"
    echo "  ${GREEN}5)${NC} Skip for now          - Download manually later"
    echo ""
    
    read -p "Enter your choice (1-5) [1]: " choice
    choice=${choice:-1}
    
    case $choice in
        1)
            MODEL="codellama"
            ;;
        2)
            MODEL="deepseek-coder"
            ;;
        3)
            MODEL="phind-codellama"
            print_warning "This model requires ~20GB RAM"
            read -p "Continue? (y/N): " confirm
            if [[ ! $confirm =~ ^[Yy]$ ]]; then
                MODEL="codellama"
                print_info "Falling back to CodeLlama"
            fi
            ;;
        4)
            MODEL="mistral"
            ;;
        5)
            print_info "Skipping model download"
            print_info "You can download models later with: ollama pull <model-name>"
            return 0
            ;;
        *)
            print_warning "Invalid choice, using CodeLlama"
            MODEL="codellama"
            ;;
    esac
    
    print_info "Downloading $MODEL... (this may take a few minutes)"
    
    if ollama pull $MODEL; then
        print_success "Model $MODEL downloaded successfully"
    else
        print_error "Failed to download model"
        print_info "You can try again later with: ollama pull $MODEL"
    fi
}

# Create requirements.txt
create_requirements() {
    print_step "Creating requirements.txt..."
    
    cat > requirements.txt << EOF
flask>=2.3.0
requests>=2.31.0
EOF
    
    print_success "Created requirements.txt"
}

# Create startup script
create_startup_script() {
    print_step "Creating startup script..."
    
    cat > start.sh << 'EOF'
#!/bin/bash

echo "🚀 Starting Local Coding AI..."
echo ""

# Check if Ollama is running
if ! pgrep -x "ollama" > /dev/null; then
    echo "Starting Ollama..."
    nohup ollama serve > /tmp/ollama.log 2>&1 &
    sleep 2
fi

# Start the server
python3 src/server.py "$@"
EOF
    
    chmod +x start.sh
    print_success "Created start.sh"
}

# Final setup
final_setup() {
    print_step "Final setup..."
    
    # Make server executable
    if [ -f "src/server.py" ]; then
        chmod +x src/server.py
        print_success "Made server.py executable"
    fi
    
    # Create .gitignore if it doesn't exist
    if [ ! -f ".gitignore" ]; then
        cat > .gitignore << EOF
__pycache__/
*.py[cod]
*$py.class
*.so
.env
.venv
venv/
*.log
.DS_Store
EOF
        print_success "Created .gitignore"
    fi
}

# Installation summary
print_summary() {
    echo ""
    echo -e "${GREEN}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║                                                            ║${NC}"
    echo -e "${GREEN}║             ✅  INSTALLATION COMPLETED!  ✅                ║${NC}"
    echo -e "${GREEN}║                                                            ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    print_info "Quick Start:"
    echo ""
    echo "  1. Start the server:"
    echo "     ${CYAN}./start.sh${NC}"
    echo "     or"
    echo "     ${CYAN}python3 src/server.py${NC}"
    echo ""
    echo "  2. Open your browser:"
    echo "     ${CYAN}http://localhost:5000${NC}"
    echo ""
    
    print_info "Useful Commands:"
    echo ""
    echo "  List models:     ${CYAN}ollama list${NC}"
    echo "  Download model:  ${CYAN}ollama pull <model-name>${NC}"
    echo "  Remove model:    ${CYAN}ollama rm <model-name>${NC}"
    echo "  Stop Ollama:     ${CYAN}pkill ollama${NC}"
    echo ""
    
    print_info "Documentation:"
    echo "  README:    ./README.md"
    echo "  GitHub:    https://github.com/833K-cpu/localai"
    echo ""
    
    echo -e "${PURPLE}Happy coding with AI! 🚀${NC}"
    echo ""
}

# Main installation flow
main() {
    print_header
    
    # Check if running in project directory
    if [ ! -f "README.md" ]; then
        print_warning "README.md not found. Are you in the project directory?"
        read -p "Continue anyway? (y/N): " confirm
        if [[ ! $confirm =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi
    
    # Run installation steps
    check_system_requirements
    install_python_deps
    install_ollama
    start_ollama
    download_model
    create_requirements
    create_startup_script
    final_setup
    
    # Show summary
    print_summary
}

# Run main function
main "$@"
