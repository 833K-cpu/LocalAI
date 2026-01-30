# Contributing to LocalAI

First off, thank you for considering contributing to LocalAI! 🎉

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [How Can I Contribute?](#how-can-i-contribute)
- [Development Setup](#development-setup)
- [Coding Standards](#coding-standards)
- [Commit Guidelines](#commit-guidelines)
- [Pull Request Process](#pull-request-process)

## Code of Conduct

This project adheres to a code of conduct. By participating, you are expected to uphold this code. Please report unacceptable behavior to the project maintainers.

### Our Standards

- **Be respectful** and inclusive
- **Be collaborative** and constructive
- **Focus on what's best** for the community
- **Show empathy** towards others

## How Can I Contribute?

### Reporting Bugs

Before creating bug reports, please check existing issues. When creating a bug report, include:

- **Clear title** and description
- **Steps to reproduce** the problem
- **Expected vs actual** behavior
- **System information** (OS, Python version, etc.)
- **Screenshots** if applicable

**Template:**
```markdown
## Description
Brief description of the bug

## Steps to Reproduce
1. Go to '...'
2. Click on '...'
3. See error

## Expected Behavior
What should happen

## Actual Behavior
What actually happens

## System Information
- OS: Ubuntu 22.04
- Python: 3.10.5
- Browser: Chrome 120
```

### Suggesting Features

Feature requests are welcome! Please provide:

- **Clear use case**: Why is this feature needed?
- **Detailed description**: What should it do?
- **Alternatives**: Have you considered alternatives?
- **Impact**: Who would benefit?

### Code Contributions

We love pull requests! Here's how to contribute code:

1. **Fork** the repository
2. **Create** a feature branch
3. **Make** your changes
4. **Test** thoroughly
5. **Submit** a pull request

## Development Setup

### Prerequisites

- Python 3.8+
- Ollama installed
- Git

### Setup Steps

```bash
# 1. Fork and clone
git clone https://github.com/833K-cpu/localai.git
cd localai

# 2. Create virtual environment (optional but recommended)
python3 -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate

# 3. Install dependencies
pip install -r requirements.txt

# 4. Install dev dependencies
pip install pytest flake8 black isort

# 5. Start Ollama
ollama serve

# 6. Pull a test model
ollama pull codellama

# 7. Run the server
python3 src/server.py
```

### Project Structure

```
localai/
├── src/
│   ├── server.py          # Main Flask application
│   └── templates/         # HTML templates
├── scripts/
│   └── install.sh         # Installation script
├── docs/                  # Documentation
├── tests/                 # Test files
└── README.md
```

## Coding Standards

### Python Style Guide

We follow [PEP 8](https://pep8.org/) with some modifications:

```python
# Good
def calculate_response_time(start_time: float, end_time: float) -> float:
    """Calculate response time in seconds."""
    return end_time - start_time

# Bad
def calc(s,e):
    return e-s
```

**Key Points:**
- Use **4 spaces** for indentation (no tabs)
- **Maximum line length**: 100 characters
- Use **type hints** where possible
- Write **docstrings** for functions and classes
- Use **descriptive variable names**

### Code Formatting

We use `black` for automatic code formatting:

```bash
# Format all Python files
black src/

# Check without modifying
black --check src/
```

### Import Organization

Use `isort` to organize imports:

```bash
isort src/
```

**Import Order:**
1. Standard library imports
2. Third-party imports
3. Local application imports

```python
# Standard library
import os
import sys
from typing import Dict, List

# Third-party
from flask import Flask, request
import requests

# Local
from .utils import helper_function
```

### Documentation

- **Docstrings**: Use Google-style docstrings
- **Comments**: Explain why, not what
- **README**: Update if you add features

**Example Docstring:**
```python
def generate_response(prompt: str, model: str = "codellama") -> str:
    """
    Generate AI response using Ollama.
    
    Args:
        prompt: User's input message
        model: Name of the model to use
        
    Returns:
        Generated response text
        
    Raises:
        ConnectionError: If Ollama is not accessible
    """
    pass
```

## Commit Guidelines

### Commit Messages

We follow [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>(<scope>): <subject>

<body>

<footer>
```

**Types:**
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting, etc.)
- `refactor`: Code refactoring
- `test`: Adding or updating tests
- `chore`: Maintenance tasks

**Examples:**

```bash
# Good
git commit -m "feat(api): add streaming support for chat responses"
git commit -m "fix(ui): resolve message overflow on mobile devices"
git commit -m "docs: update installation instructions for Fedora"

# Bad
git commit -m "fixed stuff"
git commit -m "update"
```

### Commit Best Practices

- **One commit per logical change**
- **Write clear commit messages**
- **Reference issues** when applicable
- **Keep commits small** and focused

## Pull Request Process

### Before Submitting

1. **Update documentation** if needed
2. **Add tests** for new features
3. **Run tests** locally
4. **Format code** with black
5. **Check linting** with flake8

```bash
# Run all checks
black src/
isort src/
flake8 src/
pytest tests/
```

### PR Template

```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Documentation update
- [ ] Performance improvement

## Testing
- [ ] Tested locally
- [ ] Added new tests
- [ ] All tests pass

## Checklist
- [ ] Code follows style guidelines
- [ ] Documentation updated
- [ ] No breaking changes
- [ ] Commit messages are clear

## Screenshots (if applicable)
Add screenshots here
```

### Review Process

1. **Submit PR** with clear description
2. **Wait for review** (usually 1-3 days)
3. **Address feedback** if requested
4. **Merge** after approval

## Testing

### Running Tests

```bash
# Run all tests
pytest

# Run with coverage
pytest --cov=src tests/

# Run specific test file
pytest tests/test_api.py
```

### Writing Tests

```python
# tests/test_api.py
import pytest
from src.server import app

@pytest.fixture
def client():
    app.config['TESTING'] = True
    with app.test_client() as client:
        yield client

def test_health_endpoint(client):
    """Test health check endpoint."""
    response = client.get('/api/health')
    assert response.status_code == 200
    assert 'status' in response.json
```

## Getting Help

- **Issues**: For bug reports and feature requests
- **Discussions**: For questions and general discussion
- **Email**: For private concerns

## Recognition

Contributors will be recognized in:
- README.md contributors section
- Release notes
- Project documentation

## License

By contributing, you agree that your contributions will be licensed under the MIT License.

---

Thank you for contributing to Local Coding AI! 🚀
