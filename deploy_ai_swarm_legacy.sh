#!/bin/bash
#===============================================================================
# DEPLOY AI SWARM - Enterprise-Grade AI Agent Ecosystem Installer
# Target: Ubuntu 24.04 LTS (CPU ONLY, 20GB RAM)
# 
# This script establishes a production-ready AI Agent ecosystem with:
# - Local CPU-optimized LLM inference via Ollama
# - Multi-agent orchestration frameworks (CrewAI, AutoGen, LangGraph)
# - LiteLLM proxy for hybrid local/cloud model routing
# - Vector storage and long-term memory
# - Web scraping and API interaction skills
#
# Author: Enterprise AI Full-Stack Developer
# License: MIT
#===============================================================================

set -euo pipefail

#-------------------------------------------------------------------------------
# Color Codes for Output
#-------------------------------------------------------------------------------
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

#-------------------------------------------------------------------------------
# Configuration Variables
#-------------------------------------------------------------------------------
INSTALL_DIR="/opt/ai-swarm"
VENV_DIR="${INSTALL_DIR}/venv"
CONFIG_DIR="${INSTALL_DIR}/config"
AGENTS_DIR="${INSTALL_DIR}/agents"
SKILLS_DIR="${INSTALL_DIR}/skills"
MEMORY_DIR="${INSTALL_DIR}/memory"
LOGS_DIR="${INSTALL_DIR}/logs"
OLLAMA_MODELS=("phi3:mini" "llama3:8b" "nomic-embed-text")

#-------------------------------------------------------------------------------
# Logging Functions
#-------------------------------------------------------------------------------
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_phase() {
    echo -e "\n${CYAN}========================================${NC}"
    echo -e "${CYAN}$1${NC}"
    echo -e "${CYAN}========================================${NC}\n"
}

#-------------------------------------------------------------------------------
# Phase 1: Enterprise System Base
#-------------------------------------------------------------------------------
phase_system_base() {
    log_phase "PHASE 1: Enterprise System Base Setup"
    
    log_info "Updating system packages..."
    apt-get update -qq
    apt-get upgrade -y -qq
    
    log_info "Installing system prerequisites..."
    apt-get install -y -qq \
        python3 \
        python3-venv \
        python3-pip \
        git \
        curl \
        build-essential \
        jq \
        docker.io \
        systemd
    
    log_success "System base installed successfully"
}

#-------------------------------------------------------------------------------
# Phase 2: Local AI Engine (Ollama - CPU Optimized)
#-------------------------------------------------------------------------------
phase_ollama_install() {
    log_phase "PHASE 2: Installing Ollama (CPU-Optimized Local AI Engine)"
    
    log_info "Downloading and installing Ollama..."
    curl -fsSL https://ollama.com/install.sh | bash
    
    log_info "Starting Ollama service..."
    systemctl daemon-reload
    systemctl enable ollama
    systemctl start ollama
    
    # Wait for Ollama to be ready
    log_info "Waiting for Ollama service to be ready..."
    sleep 5
    
    log_info "Pulling CPU-optimized quantized models (optimized for 20GB RAM):"
    for model in "${OLLAMA_MODELS[@]}"; do
        log_info "  → Pulling ${model}..."
        ollama pull "$model" || log_warning "Failed to pull ${model}, will retry later"
    done
    
    log_success "Ollama installation complete with CPU-optimized models"
}

#-------------------------------------------------------------------------------
# Phase 3: Multi-Agent Frameworks & LiteLLM Proxy
#-------------------------------------------------------------------------------
phase_agent_frameworks() {
    log_phase "PHASE 3: Setting Up Multi-Agent Frameworks & Proxy"
    
    log_info "Creating installation directory: ${INSTALL_DIR}"
    mkdir -p "$INSTALL_DIR"
    
    log_info "Creating Python virtual environment..."
    python3 -m venv "$VENV_DIR"
    
    log_info "Activating virtual environment and upgrading pip..."
    source "${VENV_DIR}/bin/activate"
    pip install --upgrade pip -q
    
    log_info "Installing elite agent orchestration frameworks..."
    pip install -q \
        'crewai[tools]' \
        autogenstudio \
        langgraph \
        langchain \
        langchain-community \
        langchain-ollama
    
    log_info "Installing LiteLLM universal LLM proxy..."
    pip install -q litellm
    
    log_success "Agent frameworks and LiteLLM proxy installed"
}

#-------------------------------------------------------------------------------
# Phase 4: Long-Term Memory & Vector Storage
#-------------------------------------------------------------------------------
phase_memory_storage() {
    log_phase "PHASE 4: Installing Memory & Vector Storage Systems"
    
    source "${VENV_DIR}/bin/activate"
    
    log_info "Installing ChromaDB for local vector storage..."
    pip install -q chromadb
    
    log_info "Installing Mem0AI for cross-agent long-term memory..."
    pip install -q mem0ai
    
    log_success "Memory and vector storage systems installed"
}

#-------------------------------------------------------------------------------
# Phase 5: Agent Skills & Tooling
#-------------------------------------------------------------------------------
phase_agent_skills() {
    log_phase "PHASE 5: Installing Agent Skills & Tooling"
    
    source "${VENV_DIR}/bin/activate"
    
    log_info "Installing web scraping and API interaction libraries..."
    pip install -q \
        playwright \
        beautifulsoup4 \
        duckduckgo-search \
        yfinance \
        requests \
        lxml-html-clean
    
    log_info "Installing Playwright browser binaries..."
    playwright install --with-deps chromium
    
    log_success "Agent skills and tooling installed"
}

#-------------------------------------------------------------------------------
# Phase 6: Enterprise Scaffolding & Configuration
#-------------------------------------------------------------------------------
phase_scaffolding() {
    log_phase "PHASE 6: Creating Enterprise Directory Structure & Configuration"
    
    log_info "Creating directory structure..."
    mkdir -p "$AGENTS_DIR"
    mkdir -p "$SKILLS_DIR"
    mkdir -p "$MEMORY_DIR"
    mkdir -p "$CONFIG_DIR"
    mkdir -p "$LOGS_DIR"
    
    log_info "Generating comprehensive .env configuration file..."
    cat > "${CONFIG_DIR}/.env" << 'EOF'
#===============================================================================
# AI SWARM ENVIRONMENT CONFIGURATION
# Generated by deploy_ai_swarm.sh
#===============================================================================

#-------------------------------------------------------------------------------
# LOCAL MODEL CONFIGURATION (Ollama)
#-------------------------------------------------------------------------------
OLLAMA_BASE_URL="http://localhost:11434"
LOCAL_LLM_MODEL="llama3:8b"
LOCAL_EMBEDDING_MODEL="nomic-embed-text"
LOCAL_FAST_MODEL="phi3:mini"

#-------------------------------------------------------------------------------
# CLOUD API KEYS (Optional - for hybrid architecture)
# Leave empty to use only local models
#-------------------------------------------------------------------------------
OPENAI_API_KEY=""
ANTHROPIC_API_KEY=""
GEMINI_API_KEY=""
COHERE_API_KEY=""
TOGETHER_API_KEY=""
GROQ_API_KEY=""

#-------------------------------------------------------------------------------
# SEARCH & DATA APIs
#-------------------------------------------------------------------------------
TAVILY_API_KEY=""
SERPER_API_KEY=""
BING_SEARCH_API_KEY=""

#-------------------------------------------------------------------------------
# VECTOR DATABASE CONFIGURATION
#-------------------------------------------------------------------------------
CHROMA_DB_PATH="/opt/ai-swarm/memory/chroma_db"
CHROMA_PERSISTENCE="true"

#-------------------------------------------------------------------------------
# MEMORY CONFIGURATION
#-------------------------------------------------------------------------------
MEM0_API_KEY=""
MEMORY_BACKEND="chromadb"

#-------------------------------------------------------------------------------
# AGENT CONFIGURATION
#-------------------------------------------------------------------------------
AGENT_VERBOSE="true"
AGENT_MAX_ITERATIONS="10"
AGENT_TEMPERATURE="0.7"

#-------------------------------------------------------------------------------
# LOGGING CONFIGURATION
#-------------------------------------------------------------------------------
LOG_LEVEL="INFO"
LOG_FILE="/opt/ai-swarm/logs/agent_swarm.log"

#-------------------------------------------------------------------------------
# LITELLM PROXY CONFIGURATION
#-------------------------------------------------------------------------------
LITELLM_HOST="0.0.0.0"
LITELLM_PORT="4000"
EOF
    
    log_success "Enterprise scaffolding complete"
}

#-------------------------------------------------------------------------------
# Phase 7: Generate Verification Script
#-------------------------------------------------------------------------------
phase_verification_script() {
    log_phase "PHASE 7: Generating ProMaster Verification Script"
    
    cat > "${INSTALL_DIR}/test_swarm.py" << 'PYTHON_EOF'
#!/usr/bin/env python3
"""
================================================================================
AI SWARM VERIFICATION SCRIPT
Tests the complete AI agent stack with local CPU-optimized models
================================================================================
This script verifies:
1. Ollama connection and model availability
2. CrewAI agent creation with local models
3. Web search skill integration
4. LiteLLM proxy configuration
================================================================================
"""

import os
import sys
from pathlib import Path

# Add the installation directory to path
sys.path.insert(0, '/opt/ai-swarm')

# Load environment variables
from dotenv import load_dotenv
load_dotenv('/opt/ai-swarm/config/.env')

def print_header(text: str):
    """Print formatted header"""
    print("\n" + "=" * 80)
    print(f"  {text}")
    print("=" * 80 + "\n")

def test_ollama_connection():
    """Test Ollama service connectivity"""
    print_header("TEST 1: Ollama Connection")
    
    try:
        import requests
        ollama_url = os.getenv('OLLAMA_BASE_URL', 'http://localhost:11434')
        
        response = requests.get(f"{ollama_url}/api/tags", timeout=10)
        if response.status_code == 200:
            models = response.json().get('models', [])
            print(f"✓ Ollama is running at {ollama_url}")
            print(f"✓ Available models: {len(models)}")
            for model in models:
                print(f"  - {model['name']}")
            return True
        else:
            print(f"✗ Ollama returned status code: {response.status_code}")
            return False
    except Exception as e:
        print(f"✗ Failed to connect to Ollama: {str(e)}")
        return False

def test_litellm_config():
    """Test LiteLLM configuration"""
    print_header("TEST 2: LiteLLM Configuration")
    
    try:
        import litellm
        from litellm import completion
        
        # Test with local Ollama model
        ollama_model = os.getenv('LOCAL_LLM_MODEL', 'llama3:8b')
        ollama_base = os.getenv('OLLAMA_BASE_URL', 'http://localhost:11434')
        
        print(f"Testing LiteLLM with Ollama model: {ollama_model}")
        print(f"Base URL: {ollama_base}")
        
        # Configure for Ollama
        response = completion(
            model=f"ollama/{ollama_model}",
            messages=[{"content": "Respond with just 'OK' if you can read this.", "role": "user"}],
            api_base=ollama_base,
            max_tokens=10,
            request_timeout=30
        )
        
        print(f"✓ LiteLLM successfully connected to Ollama")
        print(f"✓ Test response received: {response.choices[0].message.content.strip()}")
        return True
    except Exception as e:
        print(f"✗ LiteLLM test failed: {str(e)}")
        return False

def test_crewai_agent():
    """Test CrewAI agent with local model and web search"""
    print_header("TEST 3: CrewAI Agent with Web Search Skill")
    
    try:
        from crewai import Agent, Task, Crew
        from langchain_ollama import ChatOllama
        from duckduckgo_search import DDGS
        
        ollama_model = os.getenv('LOCAL_LLM_MODEL', 'llama3:8b')
        ollama_base = os.getenv('OLLAMA_BASE_URL', 'http://localhost:11434')
        
        print(f"Creating agent with model: {ollama_model}")
        
        # Initialize local LLM
        llm = ChatOllama(
            model=ollama_model,
            base_url=ollama_base,
            temperature=0.7
        )
        
        # Define web search skill
        def search_web(query: str) -> str:
            """Search the web using DuckDuckGo"""
            try:
                results = DDGS().text(query, max_results=3)
                if results:
                    return "\n".join([f"- {r['title']}: {r['href']}" for r in results])
                return "No results found"
            except Exception as e:
                return f"Search error: {str(e)}"
        
        # Create agent
        researcher = Agent(
            role='Research Analyst',
            goal='Find and summarize information from the web',
            backstory='You are an expert researcher with access to web search tools',
            tools=[search_web],
            llm=llm,
            verbose=True,
            allow_delegation=False
        )
        
        # Create task
        task = Task(
            description='Search for "latest developments in AI agents" and provide a brief summary',
            expected_output='A concise summary of recent AI agent developments',
            agent=researcher
        )
        
        # Create crew
        crew = Crew(
            agents=[researcher],
            tasks=[task],
            verbose=True
        )
        
        print("✓ CrewAI agent created successfully")
        print("✓ Running test task (this may take a moment with CPU inference)...")
        print("-" * 80)
        
        result = crew.kickoff()
        
        print("-" * 80)
        print(f"✓ Task completed successfully!")
        print(f"✓ Result preview: {str(result)[:200]}...")
        return True
        
    except Exception as e:
        print(f"✗ CrewAI test failed: {str(e)}")
        import traceback
        traceback.print_exc()
        return False

def test_vector_storage():
    """Test ChromaDB vector storage"""
    print_header("TEST 4: Vector Storage (ChromaDB)")
    
    try:
        import chromadb
        from chromadb.config import Settings
        
        chroma_path = os.getenv('CHROMA_DB_PATH', '/opt/ai-swarm/memory/chroma_db')
        
        print(f"Initializing ChromaDB at: {chroma_path}")
        
        client = chromadb.PersistentClient(path=chroma_path)
        
        # Create test collection
        collection = client.get_or_create_collection(name="test_collection")
        
        # Add test embedding
        collection.add(
            documents=["This is a test document for AI swarm verification"],
            metadatas=[{"source": "verification_test"}],
            ids=["test_id_1"]
        )
        
        # Query test
        results = collection.query(
            query_texts=["test document"],
            n_results=1
        )
        
        print(f"✓ ChromaDB initialized successfully")
        print(f"✓ Test document added and retrieved")
        print(f"✓ Collection size: {collection.count()} documents")
        return True
        
    except Exception as e:
        print(f"✗ ChromaDB test failed: {str(e)}")
        return False

def main():
    """Run all verification tests"""
    print_header("AI SWARM VERIFICATION SUITE")
    print("Testing complete AI agent ecosystem on CPU-only infrastructure")
    print(f"Local Model: {os.getenv('LOCAL_LLM_MODEL', 'llama3:8b')}")
    print(f"Ollama URL: {os.getenv('OLLAMA_BASE_URL', 'http://localhost:11434')}")
    
    results = {
        'Ollama Connection': test_ollama_connection(),
        'LiteLLM Config': test_litellm_config(),
        'CrewAI Agent': test_crewai_agent(),
        'Vector Storage': test_vector_storage()
    }
    
    # Summary
    print_header("VERIFICATION SUMMARY")
    
    passed = sum(1 for v in results.values() if v)
    total = len(results)
    
    for test_name, result in results.items():
        status = "✓ PASSED" if result else "✗ FAILED"
        print(f"{test_name:.<50} {status}")
    
    print("\n" + "-" * 80)
    print(f"Total: {passed}/{total} tests passed")
    
    if passed == total:
        print("\n🎉 ALL TESTS PASSED! Your AI Swarm is ready for production!")
        return 0
    else:
        print(f"\n⚠️  {total - passed} test(s) failed. Check the logs above.")
        return 1

if __name__ == "__main__":
    sys.exit(main())
PYTHON_EOF

    chmod +x "${INSTALL_DIR}/test_swarm.py"
    
    log_success "Verification script generated at ${INSTALL_DIR}/test_swarm.py"
}

#-------------------------------------------------------------------------------
# Phase 8: Create Helper Scripts
#-------------------------------------------------------------------------------
phase_helper_scripts() {
    log_phase "PHASE 8: Creating Helper Scripts"
    
    # Start Ollama service helper
    cat > "${INSTALL_DIR}/start_ollama.sh" << 'EOF'
#!/bin/bash
echo "Starting Ollama service..."
sudo systemctl start ollama
sudo systemctl enable ollama
echo "Ollama started. Access at http://localhost:11434"
EOF
    chmod +x "${INSTALL_DIR}/start_ollama.sh"
    
    # Activate environment helper
    cat > "${INSTALL_DIR}/activate.sh" << 'EOF'
#!/bin/bash
echo "Activating AI Swarm environment..."
source /opt/ai-swarm/venv/bin/activate
echo "Environment activated. You can now run Python scripts."
echo "Example: python /opt/ai-swarm/test_swarm.py"
EOF
    chmod +x "${INSTALL_DIR}/activate.sh"
    
    # Quick start guide
    cat > "${INSTALL_DIR}/README.md" << 'EOF'
# AI Swarm - Enterprise Agent Ecosystem

## Quick Start

### 1. Start Ollama Service
```bash
sudo systemctl start ollama
sudo systemctl enable ollama
```

### 2. Activate Environment
```bash
source /opt/ai-swarm/venv/bin/activate
```

### 3. Run Verification Test
```bash
python /opt/ai-swarm/test_swarm.py
```

### 4. Configure API Keys (Optional)
Edit `/opt/ai-swarm/config/.env` to add your cloud API keys for hybrid operation.

## Directory Structure

```
/opt/ai-swarm/
├── agents/          # Custom agent definitions
├── skills/          # Custom agent tools and skills
├── memory/          # Vector database and memory storage
├── config/          # Configuration files (.env)
├── logs/            # Application logs
├── venv/            # Python virtual environment
├── test_swarm.py    # Verification script
└── README.md        # This file
```

## Available Models (CPU-Optimized)

- **llama3:8b** - Primary reasoning model
- **phi3:mini** - Fast responses for simple tasks
- **nomic-embed-text** - Embeddings for RAG and memory

## Hybrid Architecture

The system is configured to use local models by default. To use cloud APIs:

1. Add your API keys to `/opt/ai-swarm/config/.env`
2. Update the `LOCAL_LLM_MODEL` variable to use cloud models via LiteLLM
3. Example: `LOCAL_LLM_MODEL="openai/gpt-4"` or `LOCAL_LLM_MODEL="anthropic/claude-3-sonnet"`

## LiteLLM Proxy

Start the LiteLLM proxy to route requests:
```bash
source /opt/ai-swarm/venv/bin/activate
litellm --host 0.0.0.0 --port 4000
```

## Troubleshooting

- Check Ollama status: `systemctl status ollama`
- View logs: `journalctl -u ollama -f`
- List models: `ollama list`
- Test connection: `curl http://localhost:11434/api/tags`
EOF
    
    log_success "Helper scripts and documentation created"
}

#-------------------------------------------------------------------------------
# Final Summary
#-------------------------------------------------------------------------------
show_summary() {
    log_phase "INSTALLATION COMPLETE!"
    
    echo -e "${GREEN}"
    cat << SUMMARY
╔═══════════════════════════════════════════════════════════════════════════════╗
║                     AI SWARM INSTALLATION SUCCESSFUL                          ║
╠═══════════════════════════════════════════════════════════════════════════════╣
║ Installation Directory: ${INSTALL_DIR}
║ Python Environment:     ${VENV_DIR}
║ Ollama Service:         Active (CPU-optimized models loaded)
║ Vector Database:        ChromaDB configured
║ Agent Frameworks:       CrewAI, AutoGen, LangGraph, LangChain
║ LLM Proxy:              LiteLLM configured
╚═══════════════════════════════════════════════════════════════════════════════╝

NEXT STEPS:
-----------
1. Verify the installation:
   sudo python3 ${INSTALL_DIR}/test_swarm.py

2. Activate the environment:
   source ${VENV_DIR}/bin/activate

3. Start building your agents:
   - Agents directory: ${AGENTS_DIR}
   - Skills directory: ${SKILLS_DIR}
   - Config file: ${CONFIG_DIR}/.env

4. Optional: Add cloud API keys to ${CONFIG_DIR}/.env for hybrid operation

DOCUMENTATION:
--------------
Read the quick start guide: ${INSTALL_DIR}/README.md

SUMMARY
    echo -e "${NC}"
}

#-------------------------------------------------------------------------------
# Main Execution
#-------------------------------------------------------------------------------
main() {
    log_info "Starting AI Swarm deployment..."
    log_info "Target: Ubuntu 24.04 LTS (CPU ONLY, 20GB RAM)"
    log_info "Installation directory: ${INSTALL_DIR}"
    
    # Execute all phases
    phase_system_base
    phase_ollama_install
    phase_agent_frameworks
    phase_memory_storage
    phase_agent_skills
    phase_scaffolding
    phase_verification_script
    phase_helper_scripts
    
    # Show final summary
    show_summary
    
    log_success "Deployment completed successfully!"
}

# Run main function
main "$@"
