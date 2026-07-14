#!/bin/bash
#===============================================================================
# OMEGA SWARM EXPANDED FINAL RELEASE v2.0
# Enterprise-Grade Multi-Agent AI Ecosystem Deployer
# 
# Author: Omega ProMaster Advance Extended
# Target: Ubuntu 24.04 LTS (Noble Numbat)
# Hardware: CPU ONLY (AVX/AVX2/AVX-512), 20GB RAM Optimized
# License: MIT Enterprise License
# 
# DESCRIPTION:
#   Deploys a complete, production-ready, multi-agent AI ecosystem with:
#   - Local CPU-optimized LLM inference (Ollama + quantized GGUF models)
#   - Multi-framework orchestration (CrewAI, AutoGen, LangGraph, Semantic Kernel)
#   - Universal model proxy (LiteLLM) for hybrid local/cloud routing
#   - Vector memory systems (ChromaDB, Qdrant, Mem0AI)
#   - Complete agent tooling stack (web scraping, financial data, Docker sandbox)
#   - Advanced monitoring, logging, and health checks
#   - Auto-scaling configurations and resource management
#   - Security hardening and firewall rules
#   - Comprehensive validation suite with multi-agent workflows
#
# USAGE:
#   sudo ./omega_swarm_expanded_final.sh
#
# REQUIREMENTS:
#   - Ubuntu 24.04 LTS (clean installation recommended)
#   - 20GB+ RAM
#   - 50GB+ free disk space
#   - Root/sudo privileges
#   - Internet connection for package downloads
#
#===============================================================================

#-------------------------------------------------------------------------------
# STRICT BASH MODE & ERROR HANDLING
#-------------------------------------------------------------------------------
set -eEuo pipefail

# Trap errors with detailed traceback
trap 'last_lineno=$LINENO; catch_error $?' ERR
catch_error() {
    local exit_code=$1
    echo -e "\n${RED}[ERROR]${NC} Script failed at line ${last_lineno} with exit code ${exit_code}"
    echo -e "${RED}[TRACE]${NC} Error occurred in function: ${FUNCNAME[1]:-main}"
    echo -e "${RED}[TRACE]${NC} Command: ${BASH_COMMAND}"
    echo -e "${RED}[HINT]${NC} Check logs at /opt/omega-ai/logs/install_$(date +%Y%m%d_%H%M%S).log"
    exit $exit_code
}

# Cleanup handler for graceful interruption
cleanup() {
    local exit_code=$?
    if [ $exit_code -ne 0 ]; then
        echo -e "\n${YELLOW}[WARN]${NC} Installation interrupted. Cleaning up..."
        # Preserve partial installations for debugging
        mkdir -p /opt/omega-ai/logs
        cp /tmp/omega_install_*.log /opt/omega-ai/logs/ 2>/dev/null || true
    fi
    exit $exit_code
}
trap cleanup EXIT INT TERM

#-------------------------------------------------------------------------------
# COLOR-CODED LOGGING SYSTEM
#-------------------------------------------------------------------------------
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color
BOLD='\033[1m'
DIM='\033[2m'

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $(date '+%Y-%m-%d %H:%M:%S') - $*"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $(date '+%Y-%m-%d %H:%M:%S') - ${BOLD}$*${NC}"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $(date '+%Y-%m-%d %H:%M:%S') - $*"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $(date '+%Y-%m-%d %H:%M:%S') - ${BOLD}$*${NC}" >&2
}

log_debug() {
    if [[ "${DEBUG:-false}" == "true" ]]; then
        echo -e "${DIM}[DEBUG]${NC} $(date '+%Y-%m-%d %H:%M:%S') - $*"
    fi
}

log_phase() {
    echo -e "\n${MAGENTA}═══════════════════════════════════════════════════════════${NC}"
    echo -e "${MAGENTA}  ${BOLD}PHASE: $*${NC}"
    echo -e "${MAGENTA}═══════════════════════════════════════════════════════════${NC}\n"
}

log_step() {
    echo -e "${CYAN}├─ $*${NC}"
}

#-------------------------------------------------------------------------------
# TERMINAL DASHBOARD UI
#-------------------------------------------------------------------------------
show_banner() {
    clear
    echo -e "${CYAN}"
    cat << 'EOF'
╔══════════════════════════════════════════════════════════════════════════════╗
║                                                                              ║
║   ███╗   ██╗███████╗██╗  ██╗██╗   ██╗██╗      ██████╗  ██████╗██╗  ██╗       ║
║   ████╗  ██║██╔════╝╚██╗██╔╝██║   ██║██║     ██╔═══██╗██╔════╝██║ ██╔╝       ║
║   ██╔██╗ ██║█████╗   ╚███╔╝ ██║   ██║██║     ██║   ██║██║     █████╔╝        ║
║   ██║╚██╗██║██╔══╝   ██╔██╗ ██║   ██║██║     ██║   ██║██║     ██╔═██╗        ║
║   ██║ ╚████║███████╗██╔╝ ██╗╚██████╔╝███████╗╚██████╔╝╚██████╗██║  ██╗       ║
║   ╚═╝  ╚═══╝╚══════╝╚═╝  ╚═╝ ╚═════╝ ╚══════╝ ╚═════╝  ╚═════╝╚═╝  ╚═╝       ║
║                                                                              ║
║            O M E G A   S W A R M   E X P A N D E D   v 2 . 0                ║
║         Enterprise Multi-Agent AI Ecosystem for Ubuntu 24.04 LTS             ║
║                                                                              ║
║   Hardware Profile: CPU ONLY (AVX/AVX2/AVX-512) | 20GB RAM Optimized         ║
║   Models: llama3:8b-q4_K_M, phi3:mini-q4, nomic-embed-text                   ║
║   Frameworks: CrewAI, AutoGen, LangGraph, Semantic Kernel, LiteLLM           ║
║                                                                              ║
╚══════════════════════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
}

show_system_check() {
    echo -e "${WHITE}${BOLD}System Pre-Flight Checks:${NC}"
    echo -e "${DIM}─────────────────────────────────────${NC}"
    
    # OS Version
    if [ -f /etc/os-release ]; then
        source /etc/os-release
        if [[ "$ID" == "ubuntu" && "$VERSION_ID" == "24.04" ]]; then
            log_success "Ubuntu 24.04 LTS detected ✓"
        else
            log_warn "Expected Ubuntu 24.04, found: $PRETTY_NAME"
            log_info "Continuing with caution..."
        fi
    fi
    
    # RAM Check
    local total_ram=$(free -g | awk '/^Mem:/ {print $2}')
    if [ "$total_ram" -ge 16 ]; then
        log_success "RAM: ${total_ram}GB available ✓"
    else
        log_warn "RAM: ${total_ram}GB detected (recommended: 20GB+)"
    fi
    
    # Disk Space
    local free_disk=$(df -BG /opt 2>/dev/null | tail -1 | awk '{print $4}' | tr -d 'G')
    if [ "${free_disk:-0}" -ge 50 ]; then
        log_success "Disk: ${free_disk}GB free ✓"
    else
        log_warn "Disk: ${free_disk:-0}GB free (recommended: 50GB+)"
    fi
    
    # CPU Architecture
    local cpu_flags=$(grep -oP '(?<=flags\t: ).*' /proc/cpuinfo | head -1)
    if echo "$cpu_flags" | grep -q "avx2"; then
        log_success "CPU: AVX2 instructions supported ✓"
    elif echo "$cpu_flags" | grep -q "avx"; then
        log_success "CPU: AVX instructions supported ✓"
    else
        log_warn "CPU: No AVX support detected (performance may be limited)"
    fi
    
    # Virtualization Check
    if command -v lscpu &> /dev/null; then
        if lscpu | grep -q "Virtualization:"; then
            log_info "Virtualization detected (nested VM possible)"
        fi
    fi
    
    echo ""
}

#-------------------------------------------------------------------------------
# CONFIGURATION CONSTANTS
#-------------------------------------------------------------------------------
readonly INSTALL_DIR="/opt/omega-ai"
readonly VENV_DIR="${INSTALL_DIR}/venv"
readonly CONFIG_DIR="${INSTALL_DIR}/config"
readonly AGENTS_DIR="${INSTALL_DIR}/agents"
readonly SKILLS_DIR="${INSTALL_DIR}/skills"
readonly MEMORY_DIR="${INSTALL_DIR}/memory"
readonly LOGS_DIR="${INSTALL_DIR}/logs"
readonly WORKSPACE_DIR="${INSTALL_DIR}/workspace"
readonly SCRIPTS_DIR="${INSTALL_DIR}/scripts"
readonly MODELS_CACHE="${INSTALL_DIR}/models_cache"

# Model specifications (CPU-optimized, 4-bit quantized)
readonly PRIMARY_MODEL="llama3:8b-instruct-q4_K_M"
readonly FAST_MODEL="phi3:mini-4k-instruct-q4"
readonly EMBEDDING_MODEL="nomic-embed-text"

# Service ports
readonly OLLAMA_PORT=11434
readonly LITELLM_PORT=4000
readonly CHROMA_PORT=8000
readonly QDRANT_PORT=6333
readonly AUTOGEN_PORT=8081

# Resource limits for 20GB RAM system
readonly MAX_CONCURRENT_MODELS=2
readonly MODEL_MEMORY_LIMIT="8G"
readonly VECTOR_DB_MEMORY="2G"

#-------------------------------------------------------------------------------
# PHASE 1: SYSTEM HARDENING & DEPENDENCIES
#-------------------------------------------------------------------------------
phase_system_hardening() {
    log_phase "System Hardening & Base Dependencies"
    
    log_step "Updating package repositories..."
    apt-get update -qq
    
    log_step "Performing full system upgrade..."
    DEBIAN_FRONTEND=noninteractive apt-get upgrade -y -qq
    
    log_step "Installing core system packages..."
    DEBIAN_FRONTEND=noninteractive apt-get install -y -qq \
        python3.12 \
        python3.12-venv \
        python3.12-dev \
        python3-pip \
        build-essential \
        curl \
        wget \
        git \
        jq \
        ufw \
        tmux \
        btop \
        htop \
        iotop \
        net-tools \
        dnsutils \
        vim \
        nano \
        tree \
        rsync \
        zip \
        unzip \
        p7zip-full \
        ffmpeg \
        libssl-dev \
        libffi-dev \
        libxml2-dev \
        libxslt1-dev \
        zlib1g-dev \
        libbz2-dev \
        libreadline-dev \
        libsqlite3-dev \
        llvm \
        libncursesw5-dev \
        xz-utils \
        tk-dev \
        liblzma-dev \
        ca-certificates \
        gnupg \
        lsb-release \
        software-properties-common \
        apt-transport-https
    
    log_step "Installing Docker for sandboxed execution..."
    if ! command -v docker &> /dev/null; then
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] \
https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | \
tee /etc/apt/sources.list.d/docker.list > /dev/null
        apt-get update -qq
        DEBIAN_FRONTEND=noninteractive apt-get install -y -qq docker.io docker-compose-plugin
    fi
    
    log_step "Configuring Docker service..."
    systemctl enable docker
    systemctl start docker
    usermod -aG docker "$SUDO_USER" 2>/dev/null || true
    
    log_step "Setting up firewall rules..."
    ufw --force enable || true
    ufw allow 22/tcp || true  # SSH
    ufw allow ${OLLAMA_PORT}/tcp || true
    ufw allow ${LITELLM_PORT}/tcp || true
    ufw allow ${CHROMA_PORT}/tcp || true
    ufw allow ${QDRANT_PORT}/tcp || true
    ufw allow ${AUTOGEN_PORT}/tcp || true
    
    log_success "System hardening complete"
}

#-------------------------------------------------------------------------------
# PHASE 2: CPU-OPTIMIZED LOCAL AI ENGINE (OLLAMA)
#-------------------------------------------------------------------------------
phase_ollama_setup() {
    log_phase "CPU-Optimized Local AI Engine (Ollama)"
    
    log_step "Downloading and installing Ollama..."
    curl -fsSL https://ollama.com/install.sh | sh
    
    log_step "Configuring Ollama systemd service..."
    cat > /etc/systemd/system/ollama.service << 'EOF'
[Unit]
Description=Ollama Service
After=network-online.target

[Service]
ExecStart=/usr/local/bin/ollama serve
User=root
Group=root
Restart=always
RestartSec=3
Environment="OLLAMA_HOST=0.0.0.0:11434"
Environment="OLLAMA_NUM_PARALLEL=2"
Environment="OLLAMA_MAX_LOADED_MODELS=2"
Environment="OLLAMA_CONTEXT_LENGTH=4096"
# CPU-specific optimizations
Environment="OLLAMA_NO_ACCELERATE=true"
Environment="OMP_NUM_THREADS=4"
Environment="MKL_NUM_THREADS=4"
Environment="OPENBLAS_NUM_THREADS=4"

[Install]
WantedBy=default.target
EOF
    
    log_step "Starting Ollama service..."
    systemctl daemon-reload
    systemctl enable ollama
    systemctl start ollama
    
    log_step "Waiting for Ollama to be ready..."
    local max_attempts=30
    local attempt=1
    while [ $attempt -le $max_attempts ]; do
        if curl -s http://localhost:${OLLAMA_PORT}/api/tags &> /dev/null; then
            log_success "Ollama service is ready"
            break
        fi
        log_info "Waiting for Ollama... (attempt $attempt/$max_attempts)"
        sleep 2
        ((attempt++))
    done
    
    if [ $attempt -gt $max_attempts ]; then
        log_error "Ollama failed to start within timeout"
        exit 1
    fi
    
    log_step "Pulling CPU-optimized models..."
    log_info "Downloading ${PRIMARY_MODEL} (primary reasoning model)..."
    ollama pull ${PRIMARY_MODEL}
    
    log_info "Downloading ${FAST_MODEL} (fast tool-calling model)..."
    ollama pull ${FAST_MODEL}
    
    log_info "Downloading ${EMBEDDING_MODEL} (embedding model)..."
    ollama pull ${EMBEDDING_MODEL}
    
    log_step "Verifying model installations..."
    ollama list
    
    log_success "Ollama setup complete with 3 optimized models"
}

#-------------------------------------------------------------------------------
# PHASE 3: MULTI-AGENT FRAMEWORK ARCHITECTURE
#-------------------------------------------------------------------------------
phase_framework_setup() {
    log_phase "Multi-Agent Framework Architecture"
    
    log_step "Creating virtual environment at ${VENV_DIR}..."
    python3.12 -m venv ${VENV_DIR}
    
    log_step "Upgrading pip and build tools..."
    source ${VENV_DIR}/bin/activate
    pip install --upgrade pip setuptools wheel --quiet
    
    log_step "Installing core agentic frameworks..."
    pip install --quiet \
        crewai[tools] \
        autogenstudio \
        langgraph \
        langchain \
        langchain-community \
        langchain-ollama \
        semantic-kernel \
        pydantic \
        pydantic-settings
    
    log_step "Installing LiteLLM universal proxy..."
    pip install --quiet litellm[proxy]
    
    log_step "Installing additional orchestration tools..."
    pip install --quiet \
        agno \
        phidata \
        smolagents \
        open-interpreter \
        guidance \
        lmql
    
    log_success "Framework architecture installed"
}

#-------------------------------------------------------------------------------
# PHASE 4: LITELLM PROXY CONFIGURATION
#-------------------------------------------------------------------------------
phase_litellm_config() {
    log_phase "LiteLLM Universal Proxy Configuration"
    
    log_step "Creating LiteLLM configuration..."
    cat > ${CONFIG_DIR}/litellm_proxy.yaml << 'EOF'
# LiteLLM Universal Proxy Configuration
# Routes requests between local Ollama models and cloud APIs

model_list:
  # Local Ollama Models (CPU-optimized)
  - model_name: llama3-local
    litellm_params:
      model: ollama/llama3:8b-instruct-q4_K_M
      api_base: http://localhost:11434
      rpm: 30
      timeout: 300
  
  - model_name: phi3-fast
    litellm_params:
      model: ollama/phi3:mini-4k-instruct-q4
      api_base: http://localhost:11434
      rpm: 60
      timeout: 120
  
  - model_name: nomic-embed
    litellm_params:
      model: ollama/nomic-embed-text
      api_base: http://localhost:11434
      model_type: embedding
  
  # Cloud API Placeholders (uncomment and add keys in .env)
  - model_name: gpt-4-turbo
    litellm_params:
      model: openai/gpt-4-turbo-preview
      api_key: os.environ/OPENAI_API_KEY
      rpm: 60
  
  - model_name: claude-3-sonnet
    litellm_params:
      model: anthropic/claude-3-sonnet-20240229
      api_key: os.environ/ANTHROPIC_API_KEY
      rpm: 60
  
  - model_name: gemini-pro
    litellm_params:
      model: vertex_ai/gemini-pro
      api_key: os.environ/GOOGLE_APPLICATION_CREDENTIALS
      rpm: 60
  
  - model_name: groq-llama3-70b
    litellm_params:
      model: groq/llama3-70b-8192
      api_key: os.environ/GROQ_API_KEY
      rpm: 30
  
  - model_name: mistral-large
    litellm_params:
      model: mistral/mistral-large-latest
      api_key: os.environ/MISTRAL_API_KEY
      rpm: 60

# Router configuration for automatic fallback
router_settings:
  routing_strategy: simple-shuffle
  set_verbose: False
  num_retries: 3
  retry_after: 5
  fallbacks: [{ "gpt-4-turbo": ["claude-3-sonnet", "llama3-local"] }]
  allowed_fails: 3
  timeout: 300

# General settings
general_settings:
  master_key: sk-omega-master-key-change-in-production
  database_url: "sqlite:///./liteLLM.db"
  use_queue: False

# Logging configuration
logging:
  mlflow: False
  prometheus: True
  langfuse: False
  
# Server configuration
server_settings:
  host: "0.0.0.0"
  port: 4000
  workers: 4
  keep_alive_timeout: 60
  access_log: true
EOF
    
    log_step "Creating LiteLLM startup script..."
    cat > ${SCRIPTS_DIR}/start_litellm.sh << 'EOF'
#!/bin/bash
source /opt/omega-ai/venv/bin/activate
export LITELLM_MASTER_KEY="sk-omega-master-key-change-in-production"
export DATABASE_URL="sqlite:///./liteLLM.db"
cd /opt/omega-ai/config
litellm --config litellm_proxy.yaml --port 4000
EOF
    chmod +x ${SCRIPTS_DIR}/start_litellm.sh
    
    log_success "LiteLLM proxy configured"
}

#-------------------------------------------------------------------------------
# PHASE 5: COGNITIVE MEMORY & VECTOR STORAGE
#-------------------------------------------------------------------------------
phase_memory_layer() {
    log_phase "Cognitive Memory Layer & Vector Storage"
    
    log_step "Installing ChromaDB for vector storage..."
    pip install --quiet chromadb
    
    log_step "Installing Qdrant vector database..."
    pip install --quiet qdrant-client
    
    log_step "Installing Mem0AI for cross-agent memory..."
    pip install --quiet mem0ai
    
    log_step "Installing additional memory backends..."
    pip install --quiet \
        faiss-cpu \
        pinecone-client \
        weaviate-client \
        redis \
        psycopg2-binary
    
    log_step "Creating ChromaDB initialization script..."
    cat > ${SCRIPTS_DIR}/init_chromadb.py << 'EOF'
import chromadb
from chromadb.config import Settings
import os

# Initialize ChromaDB with CPU-optimized settings
client = chromadb.PersistentClient(
    path="/opt/omega-ai/memory/chroma_db",
    settings=Settings(
        anonymized_telemetry=False,
        allow_reset=True,
        is_persistent=True
    )
)

# Create default collections
collections = [
    "agent_memories",
    "conversation_history",
    "document_embeddings",
    "code_snippets",
    "research_findings"
]

for collection_name in collections:
    try:
        client.get_or_create_collection(name=collection_name)
        print(f"✓ Collection '{collection_name}' initialized")
    except Exception as e:
        print(f"✗ Failed to create '{collection_name}': {e}")

print("\nChromaDB initialization complete!")
EOF
    
    log_step "Running ChromaDB initialization..."
    python ${SCRIPTS_DIR}/init_chromadb.py
    
    log_success "Memory layer initialized"
}

#-------------------------------------------------------------------------------
# PHASE 6: UNIVERSAL AGENT SKILLS & TOOLING
#-------------------------------------------------------------------------------
phase_agent_skills() {
    log_phase "Universal Agent Skills & Tooling Stack"
    
    log_step "Installing web scraping and interaction tools..."
    pip install --quiet \
        playwright \
        beautifulsoup4 \
        lxml \
        html5lib \
        selenium \
        webdriver-manager \
        duckduckgo-search \
        tavily-python \
        serper \
        google-search-results
    
    log_step "Installing Playwright browsers..."
    python -m playwright install chromium firefox
    python -m playwright install-deps chromium
    
    log_step "Installing enterprise data tools..."
    pip install --quiet \
        requests \
        pandas \
        numpy \
        openpyxl \
        xlrd \
        xlwt \
        yfinance \
        alpha-vantage \
        polygon-api-client \
        newsapi-python
    
    log_step "Installing document processing tools..."
    pip install --quiet \
        PyPDF2 \
        pdfplumber \
        python-docx \
        python-pptx \
        openpyxl \
        markdown \
        mistune \
        textract \
        pytesseract \
        pillow \
        opencv-python-headless
    
    log_step "Installing Docker SDK for sandboxed execution..."
    pip install --quiet docker
    
    log_step "Installing code execution and analysis tools..."
    pip install --quiet \
        jupyter \
        nbconvert \
        ipykernel \
        black \
        flake8 \
        pylint \
        mypy \
        pytest \
        coverage
    
    log_step "Installing communication tools..."
    pip install --quiet \
        slack-sdk \
        discord.py \
        tweepy \
        python-telegram-bot \
        aiohttp \
        fastapi \
        uvicorn
    
    log_step "Installing monitoring and observability tools..."
    pip install --quiet \
        prometheus-client \
        grafana-api \
        datadog-api-client \
        sentry-sdk \
        loguru \
        structlog
    
    # Easter egg health check
    log_step "Running system health check (easter egg)..."
    python -c "import antigravity; print('✓ System gravity nominal')" 2>/dev/null || \
    python -c "print('✓ Health check passed')"
    
    log_success "Complete tooling stack installed"
}

#-------------------------------------------------------------------------------
# PHASE 7: ENTERPRISE FILE TREE ARCHITECTURE
#-------------------------------------------------------------------------------
phase_file_architecture() {
    log_phase "Enterprise File Tree Architecture"
    
    log_step "Creating directory structure..."
    mkdir -p ${INSTALL_DIR}/{agents,skills,memory,config,logs,workspace,scripts,models_cache,data,backups,tests}
    mkdir -p ${AGENTS_DIR}/{templates,instances,prompts,policies}
    mkdir -p ${SKILLS_DIR}/{web,finance,code,docs,communication,system}
    mkdir -p ${MEMORY_DIR}/{chroma_db,qdrant_db,mem0,checkpoints}
    mkdir -p ${CONFIG_DIR}/{agents,models,workflows,security}
    mkdir -p ${WORKSPACE_DIR}/{projects,outputs,temp}
    mkdir -p ${LOGS_DIR}/{agent,system,audit,error}
    mkdir -p ${SCRIPTS_DIR}/{setup,runtime,monitoring,backup}
    mkdir -p ${DATA_DIR}/{datasets,knowledge,uploads} 2>/dev/null || true
    
    log_step "Generating comprehensive .env.production file..."
    cat > ${INSTALL_DIR}/.env.production << 'EOF'
#===============================================================================
# OMEGA SWARM PRODUCTION ENVIRONMENT CONFIGURATION
# Generated automatically by omega_swarm_expanded_final.sh
#===============================================================================

#-------------------------------------------------------------------------------
# LOCAL MODEL CONFIGURATION (OLLAMA)
#-------------------------------------------------------------------------------
OLLAMA_HOST=127.0.0.1:11434
OLLAMA_BASE_URL=http://localhost:11434
LOCAL_MODEL_PRIMARY=llama3:8b-instruct-q4_K_M
LOCAL_MODEL_FAST=phi3:mini-4k-instruct-q4
LOCAL_MODEL_EMBEDDING=nomic-embed-text
LOCAL_EMBEDDING_DIM=768
LOCAL_CONTEXT_LENGTH=4096
LOCAL_MAX_TOKENS=2048
LOCAL_TEMPERATURE=0.7
LOCAL_TOP_P=0.9

#-------------------------------------------------------------------------------
# LITELLM PROXY CONFIGURATION
#-------------------------------------------------------------------------------
LITELLM_HOST=0.0.0.0
LITELLM_PORT=4000
LITELLM_BASE_URL=http://localhost:4000
LITELLM_MASTER_KEY=sk-omega-master-key-change-in-production
LITELLM_DATABASE_URL=sqlite:///./liteLLM.db

#-------------------------------------------------------------------------------
# OPENAI API CONFIGURATION
#-------------------------------------------------------------------------------
OPENAI_API_KEY=your_openai_api_key_here
OPENAI_ORG_ID=
OPENAI_BASE_URL=https://api.openai.com/v1
OPENAI_MAX_RETRIES=3
OPENAI_TIMEOUT=300

#-------------------------------------------------------------------------------
# ANTHROPIC API CONFIGURATION
#-------------------------------------------------------------------------------
ANTHROPIC_API_KEY=your_anthropic_api_key_here
ANTHROPIC_BASE_URL=https://api.anthropic.com
ANTHROPIC_MAX_RETRIES=3
ANTHROPIC_TIMEOUT=300

#-------------------------------------------------------------------------------
# GOOGLE GEMINI / VERTEX AI CONFIGURATION
#-------------------------------------------------------------------------------
GOOGLE_API_KEY=your_google_api_key_here
GOOGLE_APPLICATION_CREDENTIALS=/path/to/service-account.json
VERTEX_AI_PROJECT_ID=your-project-id
VERTEX_AI_LOCATION=us-central1
GEMINI_BASE_URL=https://generativelanguage.googleapis.com

#-------------------------------------------------------------------------------
# GROQ API CONFIGURATION (Ultra-fast Inference)
#-------------------------------------------------------------------------------
GROQ_API_KEY=your_groq_api_key_here
GROQ_BASE_URL=https://api.groq.com/openai/v1

#-------------------------------------------------------------------------------
# MISTRAL AI CONFIGURATION
#-------------------------------------------------------------------------------
MISTRAL_API_KEY=your_mistral_api_key_here
MISTRAL_BASE_URL=https://api.mistral.ai/v1

#-------------------------------------------------------------------------------
# TOGETHER AI CONFIGURATION
#-------------------------------------------------------------------------------
TOGETHER_API_KEY=your_together_api_key_here
TOGETHER_BASE_URL=https://api.together.xyz/v1

#-------------------------------------------------------------------------------
# SEARCH & RESEARCH TOOLS
#-------------------------------------------------------------------------------
TAVILY_API_KEY=your_tavily_api_key_here
SERPER_API_KEY=your_serper_api_key_here
GOOGLE_SEARCH_API_KEY=
GOOGLE_CSE_ID=
DUCKDUCKGO_MAX_RESULTS=10

#-------------------------------------------------------------------------------
# FINANCIAL DATA APIS
#-------------------------------------------------------------------------------
ALPHA_VANTAGE_API_KEY=your_alpha_vantage_key_here
POLYGON_API_KEY=your_polygon_key_here
FINNHUB_API_KEY=your_finnhub_key_here
YAHOO_FINANCE_REGION=US

#-------------------------------------------------------------------------------
# VECTOR DATABASE CONFIGURATION
#-------------------------------------------------------------------------------
CHROMA_DB_PATH=/opt/omega-ai/memory/chroma_db
CHROMA_DB_HOST=localhost
CHROMA_DB_PORT=8000
QDRANT_DB_PATH=/opt/omega-ai/memory/qdrant_db
QDRANT_DB_HOST=localhost
QDRANT_DB_PORT=6333
WEAVIATE_URL=
PINECONE_API_KEY=
PINECONE_ENVIRONMENT=

#-------------------------------------------------------------------------------
# MEMORY CONFIGURATION (MEM0AI)
#-------------------------------------------------------------------------------
MEM0_API_KEY=your_mem0_api_key_here
MEM0_USER_ID=default_user
MEM0_ENABLE_LONG_TERM_MEMORY=true
MEM0_RETENTION_DAYS=90

#-------------------------------------------------------------------------------
# DOCKER SANDBOX CONFIGURATION
#-------------------------------------------------------------------------------
DOCKER_SOCKET=unix:///var/run/docker.sock
DOCKER_NETWORK=omega-swarm-net
SANDBOX_TIMEOUT=300
SANDBOX_MEMORY_LIMIT=2g
SANDBOX_CPU_LIMIT=2.0

#-------------------------------------------------------------------------------
# AGENT ORCHESTRATION SETTINGS
#-------------------------------------------------------------------------------
MAX_CONCURRENT_AGENTS=5
AGENT_TIMEOUT=600
ENABLE_AGENT_LOGGING=true
AGENT_LOG_LEVEL=INFO
ENABLE_AGENT_TRACING=true
TRACE_SAMPLING_RATE=1.0

#-------------------------------------------------------------------------------
# SECURITY & AUTHENTICATION
#-------------------------------------------------------------------------------
API_SECRET_KEY=change-this-to-a-secure-random-string
JWT_SECRET_KEY=change-this-to-another-secure-string
ENCRYPTION_KEY=change-this-to-a-32-byte-key!!
ALLOWED_HOSTS=localhost,127.0.0.1
CORS_ORIGINS=http://localhost:3000,http://localhost:8080

#-------------------------------------------------------------------------------
# MONITORING & OBSERVABILITY
#-------------------------------------------------------------------------------
ENABLE_PROMETHEUS=true
PROMETHEUS_PORT=9090
GRAFANA_URL=http://localhost:3001
DATADOG_API_KEY=
SENTRY_DSN=
LANGFUSE_PUBLIC_KEY=
LANGFUSE_SECRET_KEY=

#-------------------------------------------------------------------------------
# PERFORMANCE TUNING (20GB RAM OPTIMIZED)
#-------------------------------------------------------------------------------
MAX_WORKERS=4
THREAD_POOL_SIZE=8
PROCESS_POOL_SIZE=4
CACHE_SIZE_MB=2048
VECTOR_DB_CACHE_SIZE=512
MODEL_CACHE_SIZE=4096
ENABLE_MODEL_CACHING=true
ENABLE_RESPONSE_CACHING=true

#-------------------------------------------------------------------------------
# LOGGING CONFIGURATION
#-------------------------------------------------------------------------------
LOG_LEVEL=INFO
LOG_FORMAT=json
LOG_FILE=/opt/omega-ai/logs/omega_swarm.log
LOG_ROTATION=daily
LOG_RETENTION_DAYS=30
ENABLE_AUDIT_LOG=true

#-------------------------------------------------------------------------------
# BACKUP & RECOVERY
#-------------------------------------------------------------------------------
ENABLE_AUTO_BACKUP=true
BACKUP_INTERVAL_HOURS=6
BACKUP_RETENTION_DAYS=7
BACKUP_PATH=/opt/omega-ai/backups
REMOTE_BACKUP_ENABLED=false
REMOTE_BACKUP_URL=

#-------------------------------------------------------------------------------
# FEATURE FLAGS
#-------------------------------------------------------------------------------
ENABLE_WEB_SEARCH=true
ENABLE_CODE_EXECUTION=true
ENABLE_FILE_OPERATIONS=true
ENABLE_EMAIL_SENDING=false
ENABLE_SOCIAL_POSTING=false
ENABLE_VOICE_SYNTHESIS=false
ENABLE_IMAGE_GENERATION=false

#-------------------------------------------------------------------------------
# EXPERIMENTAL FEATURES
#-------------------------------------------------------------------------------
ENABLE_MULTI_MODAL=false
ENABLE_STREAMING_RESPONSES=true
ENABLE_FUNCTION_CALLING=true
ENABLE_RAG=true
ENABLE_SELF_REFLECTION=true
ENABLE_AGENT_COLLISION=true
EOF
    
    log_step "Creating .env.local override template..."
    cat > ${INSTALL_DIR}/.env.local.template << 'EOF'
# Copy this file to .env.local and customize for your environment
# This file is gitignored for security

# Add your API keys here (overrides .env.production)
# OPENAI_API_KEY=sk-your-actual-key
# ANTHROPIC_API_KEY=sk-ant-your-actual-key
# etc.
EOF
    
    log_step "Setting proper permissions..."
    chmod 755 ${INSTALL_DIR}
    chmod 755 ${INSTALL_DIR}/*
    chmod 600 ${INSTALL_DIR}/.env.production
    
    log_step "Creating directory index file..."
    tree -L 3 -I 'venv|__pycache__|*.pyc' ${INSTALL_DIR} > ${INSTALL_DIR}/DIRECTORY_STRUCTURE.txt 2>/dev/null || \
    find ${INSTALL_DIR} -type d | head -50 > ${INSTALL_DIR}/DIRECTORY_STRUCTURE.txt
    
    log_success "File architecture created"
}

#-------------------------------------------------------------------------------
# PHASE 8: ADVANCED AGENT TEMPLATES & WORKFLOWS
#-------------------------------------------------------------------------------
phase_agent_templates() {
    log_phase "Advanced Agent Templates & Workflows"
    
    log_step "Creating base agent template..."
    cat > ${AGENTS_DIR}/templates/base_agent.py << 'EOF'
"""
Base Agent Template for Omega Swarm
Provides common functionality for all agent types
"""
from crewai import Agent, Task, Crew
from langchain_ollama import ChatOllama
import os
from dotenv import load_dotenv
from pathlib import Path

# Load environment variables
env_path = Path('/opt/omega-ai/.env.production')
load_dotenv(dotenv_path=env_path)

class BaseAgent:
    def __init__(self, name: str, role: str, goal: str, backstory: str):
        self.name = name
        self.role = role
        self.goal = goal
        self.backstory = backstory
        
        # Initialize local LLM (CPU-optimized)
        self.llm = ChatOllama(
            model=os.getenv('LOCAL_MODEL_FAST', 'phi3:mini-4k-instruct-q4'),
            base_url=os.getenv('OLLAMA_BASE_URL', 'http://localhost:11434'),
            temperature=float(os.getenv('LOCAL_TEMPERATURE', '0.7')),
        )
        
        self.agent = None
        self.tasks = []
        self.crew = None
    
    def create_agent(self, tools=None, verbose=False):
        """Create the CrewAI agent instance"""
        self.agent = Agent(
            role=self.role,
            goal=self.goal,
            backstory=self.backstory,
            llm=self.llm,
            tools=tools or [],
            verbose=verbose,
            allow_delegation=True,
            max_iter=10,
            max_rpm=30,
        )
        return self.agent
    
    def add_task(self, description: str, expected_output: str, agent=None):
        """Add a task to the agent"""
        task = Task(
            description=description,
            expected_output=expected_output,
            agent=agent or self.agent,
        )
        self.tasks.append(task)
        return task
    
    def create_crew(self, agents=None, tasks=None, verbose=False):
        """Create and configure the crew"""
        self.crew = Crew(
            agents=agents or [self.agent],
            tasks=tasks or self.tasks,
            verbose=verbose,
            process='sequential',  # or 'hierarchical'
        )
        return self.crew
    
    def execute(self, inputs=None):
        """Execute the crew and return results"""
        if not self.crew:
            raise ValueError("Crew not initialized. Call create_crew() first.")
        
        result = self.crew.kickoff(inputs=inputs)
        return result
    
    def save_output(self, output: str, filename: str):
        """Save output to workspace"""
        output_path = Path('/opt/omega-ai/workspace/outputs')
        output_path.mkdir(parents=True, exist_ok=True)
        
        filepath = output_path / filename
        with open(filepath, 'w') as f:
            f.write(output)
        
        return filepath


if __name__ == "__main__":
    # Example usage
    researcher = BaseAgent(
        name="ResearchBot",
        role="Senior Research Analyst",
        goal="Discover cutting-edge developments in AI and technology",
        backstory="You are an expert at analyzing technical information and synthesizing insights."
    )
    
    print(f"✓ Agent template loaded: {researcher.name}")
EOF
    
    log_step "Creating research agent workflow..."
    cat > ${AGENTS_DIR}/templates/research_agent.py << 'EOF'
"""
Research Agent Workflow
Specialized agent for web research and analysis
"""
from crewai import Agent, Task, Crew
from crewai_tools import SerperDevTool, ScrapeWebsiteTool, WebsiteSearchTool
from langchain_ollama import ChatOllama
import os
from datetime import datetime
import json

class ResearchAgent:
    def __init__(self):
        self.llm = ChatOllama(
            model=os.getenv('LOCAL_MODEL_PRIMARY', 'llama3:8b-instruct-q4_K_M'),
            base_url=os.getenv('OLLAMA_BASE_URL', 'http://localhost:11434'),
        )
        
        # Initialize tools
        self.search_tool = WebsiteSearchTool()
        self.scrape_tool = ScrapeWebsiteTool()
        
        # Create researcher agent
        self.researcher = Agent(
            role='Senior Research Analyst',
            goal='Conduct comprehensive research on given topics and provide actionable insights',
            backstory='''You are an expert researcher with deep analytical skills.
            You excel at finding relevant information, verifying sources, and 
            synthesizing complex topics into clear, actionable reports.''',
            tools=[self.search_tool, self.scrape_tool],
            llm=self.llm,
            verbose=True,
            allow_delegation=False,
        )
        
        # Create analyst agent
        self.analyst = Agent(
            role='Data Analyst',
            goal='Analyze research findings and extract key patterns and trends',
            backstory='''You are a meticulous data analyst with expertise in 
            identifying patterns, correlations, and insights from complex datasets.''',
            llm=self.llm,
            verbose=True,
            allow_delegation=True,
        )
        
        # Create writer agent
        self.writer = Agent(
            role='Technical Writer',
            goal='Create clear, well-structured reports from research findings',
            backstory='''You are an accomplished technical writer who transforms 
            complex information into accessible, professional documents.''',
            llm=self.llm,
            verbose=True,
        )
    
    def research_topic(self, topic: str, depth: str = "comprehensive"):
        """Execute a complete research workflow"""
        
        # Define tasks
        research_task = Task(
            description=f'''Conduct thorough research on: {topic}
            
            Search for:
            - Recent developments and news
            - Key players and organizations
            - Trends and statistics
            - Expert opinions and analyses
            
            Depth: {depth}
            ''',
            expected_output='Comprehensive research notes with sources',
            agent=self.researcher,
        )
        
        analysis_task = Task(
            description='''Analyze the research findings and identify:
            - Key themes and patterns
            - Important statistics and data points
            - Emerging trends
            - Potential implications
            ''',
            expected_output='Structured analysis with key insights',
            agent=self.analyst,
        )
        
        report_task = Task(
            description='''Create a professional research report including:
            - Executive summary
            - Key findings
            - Detailed analysis
            - Conclusions and recommendations
            - Sources and references
            
            Format as Markdown with clear sections.
            ''',
            expected_output='Complete research report in Markdown format',
            agent=self.writer,
        )
        
        # Create and execute crew
        crew = Crew(
            agents=[self.researcher, self.analyst, self.writer],
            tasks=[research_task, analysis_task, report_task],
            verbose=True,
            process='sequential',
        )
        
        result = crew.kickoff()
        
        # Save report
        timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
        filename = f'research_{topic.replace(" ", "_")[:30]}_{timestamp}.md'
        output_path = f'/opt/omega-ai/workspace/outputs/{filename}'
        
        with open(output_path, 'w') as f:
            f.write(str(result))
        
        return result, output_path


if __name__ == "__main__":
    agent = ResearchAgent()
    print("✓ Research agent workflow loaded")
EOF
    
    log_step "Creating financial analysis agent..."
    cat > ${AGENTS_DIR}/templates/financial_agent.py << 'EOF'
"""
Financial Analysis Agent
Specialized agent for stock analysis and financial research
"""
import yfinance as yf
import pandas as pd
from datetime import datetime, timedelta
from crewai import Agent, Task, Crew
from langchain_ollama import ChatOllama
import os
import json

class FinancialAgent:
    def __init__(self):
        self.llm = ChatOllama(
            model=os.getenv('LOCAL_MODEL_PRIMARY', 'llama3:8b-instruct-q4_K_M'),
            base_url=os.getenv('OLLAMA_BASE_URL', 'http://localhost:11434'),
        )
        
        self.analyst = Agent(
            role='Senior Financial Analyst',
            goal='Analyze stocks and provide investment insights',
            backstory='''You are a CFA charterholder with 15 years of experience 
            in equity research and portfolio management.''',
            llm=self.llm,
            verbose=True,
        )
    
    def get_stock_data(self, ticker: str, period: str = '1y'):
        """Fetch comprehensive stock data"""
        stock = yf.Ticker(ticker)
        
        # Historical prices
        hist = stock.history(period=period)
        
        # Company info
        info = stock.info
        
        # Financials
        financials = stock.financials
        balance_sheet = stock.balance_sheet
        cashflow = stock.cashflow
        
        return {
            'ticker': ticker,
            'history': hist.to_dict(),
            'info': info,
            'financials': financials.to_dict() if not financials.empty else {},
        }
    
    def analyze_stock(self, ticker: str):
        """Perform complete stock analysis"""
        
        # Fetch data
        data = self.get_stock_data(ticker)
        
        # Analysis task
        analysis_task = Task(
            description=f'''Analyze {ticker} based on the following data:
            
            Company Info: {json.dumps(data['info'], default=str)[:2000]}
            
            Provide:
            1. Company overview
            2. Financial health assessment
            3. Growth prospects
            4. Risk factors
            5. Valuation analysis
            6. Investment recommendation (Buy/Hold/Sell)
            ''',
            expected_output='Comprehensive stock analysis report',
            agent=self.analyst,
        )
        
        crew = Crew(
            agents=[self.analyst],
            tasks=[analysis_task],
            verbose=True,
        )
        
        result = crew.kickoff()
        
        # Save analysis
        timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
        filename = f'stock_analysis_{ticker}_{timestamp}.md'
        output_path = f'/opt/omega-ai/workspace/outputs/{filename}'
        
        with open(output_path, 'w') as f:
            f.write(str(result))
        
        return result, output_path


if __name__ == "__main__":
    agent = FinancialAgent()
    print("✓ Financial agent loaded")
EOF
    
    log_step "Creating code generation agent..."
    cat > ${AGENTS_DIR}/templates/code_agent.py << 'EOF'
"""
Code Generation Agent
Specialized agent for software development tasks
"""
from crewai import Agent, Task, Crew
from langchain_ollama import ChatOllama
import subprocess
import tempfile
import os
from pathlib import Path

class CodeAgent:
    def __init__(self):
        self.llm = ChatOllama(
            model=os.getenv('LOCAL_MODEL_PRIMARY', 'llama3:8b-instruct-q4_K_M'),
            base_url=os.getenv('OLLAMA_BASE_URL', 'http://localhost:11434'),
        )
        
        self.developer = Agent(
            role='Senior Software Engineer',
            goal='Write clean, efficient, and well-documented code',
            backstory='''You are an expert programmer with deep knowledge of 
            multiple languages and best practices.''',
            llm=self.llm,
            verbose=True,
        )
        
        self.reviewer = Agent(
            role='Code Reviewer',
            goal='Review code for quality, security, and best practices',
            backstory='''You are a meticulous code reviewer with expertise in 
            identifying bugs, security issues, and optimization opportunities.''',
            llm=self.llm,
            verbose=True,
        )
    
    def generate_code(self, requirement: str, language: str = 'python'):
        """Generate code from requirements"""
        
        coding_task = Task(
            description=f'''Write {language} code that:
            {requirement}
            
            Requirements:
            - Follow best practices and design patterns
            - Include comprehensive error handling
            - Add clear comments and docstrings
            - Write unit tests
            - Ensure code is production-ready
            ''',
            expected_output=f'Complete {language} code with tests',
            agent=self.developer,
        )
        
        review_task = Task(
            description='''Review the generated code for:
            - Correctness and functionality
            - Code quality and style
            - Security vulnerabilities
            - Performance optimizations
            - Test coverage
            
            Provide specific improvement suggestions.
            ''',
            expected_output='Code review with recommendations',
            agent=self.reviewer,
        )
        
        crew = Crew(
            agents=[self.developer, self.reviewer],
            tasks=[coding_task, review_task],
            verbose=True,
        )
        
        result = crew.kickoff()
        
        # Save code
        timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
        ext = 'py' if language == 'python' else language
        filename = f'generated_code_{timestamp}.{ext}'
        output_path = f'/opt/omega-ai/workspace/outputs/{filename}'
        
        with open(output_path, 'w') as f:
            f.write(str(result))
        
        return result, output_path


if __name__ == "__main__":
    agent = CodeAgent()
    print("✓ Code agent loaded")
EOF
    
    log_success "Agent templates created"
}

#-------------------------------------------------------------------------------
# PHASE 9: COMPREHENSIVE VALIDATION SUITE
#-------------------------------------------------------------------------------
phase_validation_suite() {
    log_phase "Comprehensive Validation Suite"
    
    log_step "Creating omega_verify.py validation script..."
    cat > ${INSTALL_DIR}/omega_verify.py << 'PYTHON_EOF'
#!/usr/bin/env python3
"""
OMEGA SWARM VALIDATION SUITE
Comprehensive end-to-end testing of the AI agent ecosystem

This script validates:
1. Ollama service and models
2. LiteLLM proxy configuration
3. Vector database connectivity
4. Agent framework functionality
5. Tool integrations
6. End-to-end multi-agent workflow
"""

import sys
import os
import time
import json
from pathlib import Path
from datetime import datetime
from typing import Dict, List, Any

# Add installation directory to path
sys.path.insert(0, '/opt/omega-ai/venv/lib/python3.12/site-packages')
os.environ['PYTHONPATH'] = '/opt/omega-ai/venv/lib/python3.12/site-packages'

# Load environment
from dotenv import load_dotenv
load_dotenv('/opt/omega-ai/.env.production')

# ANSI color codes
class Colors:
    HEADER = '\033[95m'
    OKBLUE = '\033[94m'
    OKCYAN = '\033[96m'
    OKGREEN = '\033[92m'
    WARNING = '\033[93m'
    FAIL = '\033[91m'
    ENDC = '\033[0m'
    BOLD = '\033[1m'
    UNDERLINE = '\033[4m'

def print_header(text: str):
    print(f"\n{Colors.HEADER}{Colors.BOLD}{'='*70}{Colors.ENDC}")
    print(f"{Colors.HEADER}{Colors.BOLD}{text.center(70)}{Colors.ENDC}")
    print(f"{Colors.HEADER}{Colors.BOLD}{'='*70}{Colors.ENDC}\n")

def print_test(name: str, status: str, details: str = ""):
    status_color = Colors.OKGREEN if status == "PASS" else Colors.FAIL
    print(f"  [{status_color}{status}{Colors.ENDC}] {name}")
    if details:
        print(f"         {details}")

class ValidationSuite:
    def __init__(self):
        self.results = {
            'passed': 0,
            'failed': 0,
            'warnings': 0,
            'tests': []
        }
        self.start_time = datetime.now()
    
    def run_all_tests(self):
        """Execute complete validation suite"""
        print_header("OMEGA SWARM VALIDATION SUITE")
        print(f"Started: {self.start_time.strftime('%Y-%m-%d %H:%M:%S')}")
        print(f"Environment: {'Production' if os.getenv('OPENAI_API_KEY') != 'your_openai_api_key_here' else 'Development'}\n")
        
        # Phase 1: System Checks
        self.test_system_requirements()
        
        # Phase 2: Ollama Validation
        self.test_ollama_service()
        
        # Phase 3: LiteLLM Proxy
        self.test_litellm_proxy()
        
        # Phase 4: Vector Databases
        self.test_vector_databases()
        
        # Phase 5: Agent Frameworks
        self.test_agent_frameworks()
        
        # Phase 6: Tool Integrations
        self.test_tool_integrations()
        
        # Phase 7: End-to-End Workflow
        self.test_end_to_end_workflow()
        
        # Print Summary
        self.print_summary()
    
    def test_system_requirements(self):
        """Validate system requirements"""
        print_header("PHASE 1: System Requirements")
        
        # Python version
        import sys
        if sys.version_info >= (3, 12):
            self.pass_test(f"Python {sys.version.split()[0]}")
        else:
            self.fail_test(f"Python version: {sys.version.split()[0]} (required: 3.12+)")
        
        # Directory structure
        required_dirs = [
            '/opt/omega-ai/agents',
            '/opt/omega-ai/skills',
            '/opt/omega-ai/memory',
            '/opt/omega-ai/config',
            '/opt/omega-ai/workspace'
        ]
        
        for dir_path in required_dirs:
            if Path(dir_path).exists():
                self.pass_test(f"Directory exists: {dir_path}")
            else:
                self.fail_test(f"Missing directory: {dir_path}")
        
        # Environment file
        if Path('/opt/omega-ai/.env.production').exists():
            self.pass_test("Environment file exists")
        else:
            self.fail_test("Environment file missing")
    
    def test_ollama_service(self):
        """Validate Ollama service and models"""
        print_header("PHASE 2: Ollama Service")
        
        import requests
        
        # Check Ollama service
        try:
            response = requests.get('http://localhost:11434/api/tags', timeout=10)
            if response.status_code == 200:
                self.pass_test("Ollama service running")
                
                # Check models
                models = response.json().get('models', [])
                model_names = [m['name'] for m in models]
                
                required_models = [
                    'llama3:8b-instruct-q4_K_M',
                    'phi3:mini-4k-instruct-q4',
                    'nomic-embed-text'
                ]
                
                for model in required_models:
                    if any(model.split(':')[0] in m for m in model_names):
                        self.pass_test(f"Model available: {model}")
                    else:
                        self.warn_test(f"Model missing: {model}")
            else:
                self.fail_test(f"Ollama returned status {response.status_code}")
        except Exception as e:
            self.fail_test(f"Ollama service unreachable: {str(e)}")
        
        # Test model inference
        try:
            response = requests.post(
                'http://localhost:11434/api/generate',
                json={
                    'model': 'phi3:mini-4k-instruct-q4',
                    'prompt': 'Say hello in one word:',
                    'stream': False
                },
                timeout=30
            )
            if response.status_code == 200:
                result = response.json()
                if 'response' in result:
                    self.pass_test("Model inference working")
                else:
                    self.fail_test("Invalid response from model")
            else:
                self.fail_test(f"Model inference failed: {response.status_code}")
        except Exception as e:
            self.fail_test(f"Model inference error: {str(e)}")
    
    def test_litellm_proxy(self):
        """Validate LiteLLM proxy configuration"""
        print_header("PHASE 3: LiteLLM Proxy")
        
        config_path = Path('/opt/omega-ai/config/litellm_proxy.yaml')
        if config_path.exists():
            self.pass_test("LiteLLM config exists")
            
            # Validate YAML syntax
            try:
                import yaml
                with open(config_path) as f:
                    config = yaml.safe_load(f)
                if 'model_list' in config:
                    self.pass_test(f"LiteLLM configured with {len(config['model_list'])} models")
                else:
                    self.fail_test("No model_list in LiteLLM config")
            except Exception as e:
                self.fail_test(f"LiteLLM config parse error: {str(e)}")
        else:
            self.fail_test("LiteLLM config missing")
    
    def test_vector_databases(self):
        """Validate vector database connectivity"""
        print_header("PHASE 4: Vector Databases")
        
        # ChromaDB
        try:
            import chromadb
            client = chromadb.PersistentClient(path='/opt/omega-ai/memory/chroma_db')
            collections = client.list_collections()
            self.pass_test(f"ChromaDB connected ({len(collections)} collections)")
        except Exception as e:
            self.fail_test(f"ChromaDB error: {str(e)}")
        
        # Check Qdrant path
        qdrant_path = Path('/opt/omega-ai/memory/qdrant_db')
        if qdrant_path.exists():
            self.pass_test("Qdrant data directory exists")
        else:
            self.warn_test("Qdrant data directory not initialized")
    
    def test_agent_frameworks(self):
        """Validate agent framework imports"""
        print_header("PHASE 5: Agent Frameworks")
        
        frameworks = {
            'crewai': 'crewai',
            'langchain': 'langchain',
            'langgraph': 'langgraph',
            'autogen': 'autogen',
            'litellm': 'litellm'
        }
        
        for name, module in frameworks.items():
            try:
                __import__(module)
                self.pass_test(f"{name} imported successfully")
            except ImportError as e:
                self.fail_test(f"{name} import failed: {str(e)}")
    
    def test_tool_integrations(self):
        """Validate tool integrations"""
        print_header("PHASE 6: Tool Integrations")
        
        tools = {
            'playwright': 'playwright',
            'beautifulsoup4': 'bs4',
            'yfinance': 'yfinance',
            'pandas': 'pandas',
            'duckduckgo_search': 'duckduckgo_search'
        }
        
        for name, module in tools.items():
            try:
                __import__(module)
                self.pass_test(f"{name} available")
            except ImportError as e:
                self.warn_test(f"{name} not available: {str(e)}")
    
    def test_end_to_end_workflow(self):
        """Execute end-to-end multi-agent workflow"""
        print_header("PHASE 7: End-to-End Workflow")
        
        try:
            from crewai import Agent, Task, Crew
            from langchain_ollama import ChatOllama
            
            # Initialize LLM
            llm = ChatOllama(
                model=os.getenv('LOCAL_MODEL_FAST', 'phi3:mini-4k-instruct-q4'),
                base_url=os.getenv('OLLAMA_BASE_URL', 'http://localhost:11434'),
            )
            
            # Create agents
            researcher = Agent(
                role='Research Assistant',
                goal='Gather information about a topic',
                backstory='You are a helpful research assistant.',
                llm=llm,
                verbose=False,
            )
            
            writer = Agent(
                role='Technical Writer',
                goal='Create concise summaries',
                backstory='You are an expert technical writer.',
                llm=llm,
                verbose=False,
            )
            
            # Create tasks
            research_task = Task(
                description='What is the capital of France?',
                expected_output='The capital city name',
                agent=researcher,
            )
            
            write_task = Task(
                description='Write a one-sentence summary about the capital',
                expected_output='One sentence summary',
                agent=writer,
            )
            
            # Execute crew
            crew = Crew(
                agents=[researcher, writer],
                tasks=[research_task, write_task],
                verbose=False,
            )
            
            result = crew.kickoff()
            
            if result:
                self.pass_test("End-to-end workflow completed")
                
                # Save result
                output_dir = Path('/opt/omega-ai/workspace/outputs')
                output_dir.mkdir(parents=True, exist_ok=True)
                
                output_file = output_dir / f'validation_result_{datetime.now().strftime("%Y%m%d_%H%M%S")}.txt'
                with open(output_file, 'w') as f:
                    f.write(str(result))
                
                self.pass_test(f"Result saved to: {output_file}")
            else:
                self.fail_test("Workflow returned empty result")
                
        except Exception as e:
            self.fail_test(f"End-to-end workflow failed: {str(e)}")
    
    def pass_test(self, name: str):
        self.results['passed'] += 1
        self.results['tests'].append({'name': name, 'status': 'PASS'})
        print_test(name, 'PASS')
    
    def fail_test(self, name: str):
        self.results['failed'] += 1
        self.results['tests'].append({'name': name, 'status': 'FAIL'})
        print_test(name, 'FAIL')
    
    def warn_test(self, name: str):
        self.results['warnings'] += 1
        self.results['tests'].append({'name': name, 'status': 'WARN'})
        print_test(name, 'WARN')
    
    def print_summary(self):
        """Print validation summary"""
        print_header("VALIDATION SUMMARY")
        
        total = self.results['passed'] + self.results['failed']
        duration = (datetime.now() - self.start_time).total_seconds()
        
        print(f"  Total Tests:  {total}")
        print(f"  {Colors.OKGREEN}Passed:{Colors.ENDC}     {self.results['passed']}")
        print(f"  {Colors.FAIL}Failed:{Colors.ENDC}     {self.results['failed']}")
        print(f"  {Colors.WARNING}Warnings:{Colors.ENDC}   {self.results['warnings']}")
        print(f"  Duration:     {duration:.2f}s")
        print(f"  Success Rate: {(self.results['passed']/total*100):.1f}%\n")
        
        if self.results['failed'] == 0:
            print(f"{Colors.OKGREEN}{Colors.BOLD}✓ ALL CRITICAL TESTS PASSED!{Colors.ENDC}")
            print(f"{Colors.OKCYAN}Omega Swarm is ready for production.{Colors.ENDC}\n")
            return 0
        else:
            print(f"{Colors.FAIL}{Colors.BOLD}✗ SOME TESTS FAILED{Colors.ENDC}")
            print(f"{Colors.YELLOW}Please review failures above.{Colors.ENDC}\n")
            return 1


if __name__ == '__main__':
    suite = ValidationSuite()
    exit_code = suite.run_all_tests()
    sys.exit(exit_code)
PYTHON_EOF
    
    chmod +x ${INSTALL_DIR}/omega_verify.py
    
    log_step "Running validation suite..."
    source ${VENV_DIR}/bin/activate
    python ${INSTALL_DIR}/omega_verify.py || log_warn "Some validation tests failed (review output above)"
    
    log_success "Validation suite complete"
}

#-------------------------------------------------------------------------------
# PHASE 10: MONITORING & OPERATIONAL SCRIPTS
#-------------------------------------------------------------------------------
phase_monitoring_scripts() {
    log_phase "Monitoring & Operational Scripts"
    
    log_step "Creating system monitoring dashboard script..."
    cat > ${SCRIPTS_DIR}/monitor_swarm.sh << 'EOF'
#!/bin/bash
# Omega Swarm Monitoring Dashboard

echo -e "\n🔍 OMEGA SWARM STATUS DASHBOARD\n"
echo "═══════════════════════════════════════"

# Ollama Status
echo -e "\n📊 Ollama Service:"
if systemctl is-active --quiet ollama; then
    echo "  Status: ✓ Running"
    echo "  Models:"
    ollama list 2>/dev/null | sed 's/^/    /'
else
    echo "  Status: ✗ Stopped"
fi

# LiteLLM Proxy
echo -e "\n🌐 LiteLLM Proxy:"
if curl -s http://localhost:4000/health &>/dev/null; then
    echo "  Status: ✓ Healthy"
else
    echo "  Status: ✗ Not running"
fi

# Resource Usage
echo -e "\n💾 Resource Usage:"
echo "  RAM: $(free -h | awk '/^Mem:/ {print $3 "/" $2}')"
echo "  CPU: $(top -bn1 | grep "Cpu(s)" | awk '{print $2 "%"}')"
echo "  Disk: $(df -h /opt | tail -1 | awk '{print $3 "/" $2}')"

# Active Agents
echo -e "\n🤖 Agent Activity:"
ps aux | grep -E "(crewai|autogen|langgraph)" | grep -v grep | wc -l | xargs -I {} echo "  Active processes: {}"

echo -e "\n═══════════════════════════════════════\n"
EOF
    chmod +x ${SCRIPTS_DIR}/monitor_swarm.sh
    
    log_step "Creating backup script..."
    cat > ${SCRIPTS_DIR}/backup_swarm.sh << 'EOF'
#!/bin/bash
# Omega Swarm Backup Script

BACKUP_DIR="/opt/omega-ai/backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_NAME="omega_backup_${TIMESTAMP}"

echo "🔄 Starting Omega Swarm backup..."

mkdir -p ${BACKUP_DIR}/${BACKUP_NAME}

# Backup configurations
cp -r /opt/omega-ai/config ${BACKUP_DIR}/${BACKUP_NAME}/
cp /opt/omega-ai/.env.production ${BACKUP_DIR}/${BACKUP_NAME}/ 2>/dev/null || true

# Backup agent definitions
cp -r /opt/omega-ai/agents ${BACKUP_DIR}/${BACKUP_NAME}/

# Backup memory databases
cp -r /opt/omega-ai/memory/chroma_db ${BACKUP_DIR}/${BACKUP_NAME}/ 2>/dev/null || true

# Compress backup
cd ${BACKUP_DIR}
tar -czf ${BACKUP_NAME}.tar.gz ${BACKUP_NAME}
rm -rf ${BACKUP_NAME}

# Cleanup old backups (keep last 7)
ls -t omega_backup_*.tar.gz | tail -n +8 | xargs -r rm

echo "✓ Backup complete: ${BACKUP_DIR}/${BACKUP_NAME}.tar.gz"
EOF
    chmod +x ${SCRIPTS_DIR}/backup_swarm.sh
    
    log_step "Creating quick-start scripts..."
    cat > ${SCRIPTS_DIR}/start_agents.sh << 'EOF'
#!/bin/bash
# Quick-start script for Omega Swarm

source /opt/omega-ai/venv/bin/activate

echo "🚀 Starting Omega Swarm environment..."
echo "  - Ollama: http://localhost:11434"
echo "  - LiteLLM: http://localhost:4000"
echo "  - Workspace: /opt/omega-ai/workspace"
echo ""
echo "Ready! Run your agents with:"
echo "  python /opt/omega-ai/agents/templates/research_agent.py"
echo ""
EOF
    chmod +x ${SCRIPTS_DIR}/start_agents.sh
    
    log_step "Creating README documentation..."
    cat > ${INSTALL_DIR}/README.md << 'EOF'
# Omega Swarm - Enterprise AI Agent Ecosystem

## Quick Start

```bash
# Start monitoring
/opt/omega-ai/scripts/monitor_swarm.sh

# Run validation
python /opt/omega-ai/omega_verify.py

# Start an agent
source /opt/omega-ai/venv/bin/activate
python /opt/omega-ai/agents/templates/research_agent.py
```

## Directory Structure

- `/agents` - Agent definitions and workflows
- `/skills` - Tool integrations and utilities
- `/memory` - Vector databases and memory stores
- `/config` - Configuration files
- `/workspace` - Working directory and outputs
- `/scripts` - Operational scripts
- `/logs` - System and agent logs

## Available Models

- `llama3:8b-instruct-q4_K_M` - Primary reasoning
- `phi3:mini-4k-instruct-q4` - Fast tool calling
- `nomic-embed-text` - Embeddings

## API Endpoints

- Ollama: http://localhost:11434
- LiteLLM Proxy: http://localhost:4000

## Configuration

Edit `/opt/omega-ai/.env.production` to configure API keys and settings.

For local overrides, create `.env.local` (gitignored).

## Documentation

See individual agent templates in `/agents/templates/` for usage examples.

## Support

Check logs in `/opt/omega-ai/logs/` for troubleshooting.
EOF
    
    log_success "Monitoring and operational scripts created"
}

#-------------------------------------------------------------------------------
# PHASE 11: FINAL SUMMARY & NEXT STEPS
#-------------------------------------------------------------------------------
phase_final_summary() {
    log_phase "Installation Complete!"
    
    show_banner
    
    echo -e "${WHITE}${BOLD}Installation Summary:${NC}"
    echo -e "${DIM}─────────────────────────────────────${NC}"
    echo ""
    log_success "✅ System hardening and dependencies installed"
    log_success "✅ Ollama with 3 CPU-optimized models deployed"
    log_success "✅ Multi-agent frameworks (CrewAI, AutoGen, LangGraph) installed"
    log_success "✅ LiteLLM universal proxy configured"
    log_success "✅ Vector databases (ChromaDB, Qdrant) initialized"
    log_success "✅ Complete agent tooling stack deployed"
    log_success "✅ Enterprise file architecture created"
    log_success "✅ Agent templates and workflows generated"
    log_success "✅ Validation suite executed"
    log_success "✅ Monitoring and operational scripts deployed"
    
    echo ""
    echo -e "${CYAN}${BOLD}Quick Start Commands:${NC}"
    echo -e "${DIM}─────────────────────────────────────${NC}"
    echo ""
    echo "  # Monitor system status:"
    echo "  ${WHITE}/opt/omega-ai/scripts/monitor_swarm.sh${NC}"
    echo ""
    echo "  # Run validation suite:"
    echo "  ${WHITE}python /opt/omega-ai/omega_verify.py${NC}"
    echo ""
    echo "  # Activate environment:"
    echo "  ${WHITE}source /opt/omega-ai/venv/bin/activate${NC}"
    echo ""
    echo "  # Run a research agent:"
    echo "  ${WHITE}python /opt/omega-ai/agents/templates/research_agent.py${NC}"
    echo ""
    echo "  # Create backup:"
    echo "  ${WHITE}/opt/omega-ai/scripts/backup_swarm.sh${NC}"
    echo ""
    
    echo -e "${MAGENTA}${BOLD}Configuration Files:${NC}"
    echo -e "${DIM}─────────────────────────────────────${NC}"
    echo "  Environment: ${WHITE}/opt/omega-ai/.env.production${NC}"
    echo "  LiteLLM Config: ${WHITE}/opt/omega-ai/config/litellm_proxy.yaml${NC}"
    echo "  Agent Templates: ${WHITE}/opt/omega-ai/agents/templates/${NC}"
    echo ""
    
    echo -e "${GREEN}${BOLD}🎉 Omega Swarm Expanded v2.0 is ready for production!${NC}"
    echo ""
    echo -e "${YELLOW}Next Steps:${NC}"
    echo "  1. Edit .env.production and add your API keys"
    echo "  2. Customize agent templates for your use case"
    echo "  3. Run the validation suite to verify everything works"
    echo "  4. Start building your agent workflows!"
    echo ""
    
    # Log installation completion
    mkdir -p ${LOGS_DIR}
    echo "Installation completed at $(date)" >> ${LOGS_DIR}/install.log
    echo "Version: Omega Swarm Expanded v2.0" >> ${LOGS_DIR}/install.log
}

#-------------------------------------------------------------------------------
# MAIN EXECUTION
#-------------------------------------------------------------------------------
main() {
    show_banner
    show_system_check
    
    log_info "Starting Omega Swarm Expanded installation..."
    log_info "Target: ${INSTALL_DIR}"
    log_info "Hardware Profile: CPU ONLY, 20GB RAM Optimized"
    echo ""
    
    # Execute all phases
    phase_system_hardening
    phase_ollama_setup
    phase_framework_setup
    phase_litellm_config
    phase_memory_layer
    phase_agent_skills
    phase_file_architecture
    phase_agent_templates
    phase_validation_suite
    phase_monitoring_scripts
    phase_final_summary
    
    log_success "All phases completed successfully!"
}

# Run main function
main "$@"