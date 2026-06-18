#!/bin/bash

# ==============================================================================
# Script de instalação do n8n via Docker e Docker Compose em Ubuntu ARM
# ==============================================================================

# Variável para armazenar o endereço IP do servidor
N8N_HOST=""

# Define o fuso horário (ex: America/Sao_Paulo)
TIMEZONE="America/Sao_Paulo"

# Nome do diretório para o n8n
N8N_DIR="n8n-docker"

# ------------------------------------------------------------------------------
# Função para verificar se a instalação de um programa foi bem-sucedida
# ------------------------------------------------------------------------------
check_installation() {
    if [ $? -eq 0 ]; then
        echo "✅ $1 instalado com sucesso."
    else
        echo "❌ Falha na instalação de $1. Abortando."
        exit 1
    fi
}

# ------------------------------------------------------------------------------
# Pergunta e valida o IP do servidor
# ------------------------------------------------------------------------------
get_ip_address() {
    read -p "Digite o endereço IP do seu servidor (ou localhost): " N8N_HOST
    if [[ -z "$N8N_HOST" ]]; then
        echo "❌ O endereço IP não pode ser vazio. Por favor, tente novamente."
        get_ip_address
    fi
}

# ------------------------------------------------------------------------------
# Instalação do Docker e Docker Compose
# ------------------------------------------------------------------------------
install_docker() {
    echo "▶️ Iniciando a instalação do Docker e Docker Compose..."

    echo "▶️ Atualizando o sistema..."
    sudo apt-get update -y
    sudo apt-get upgrade -y
    sudo apt-get install -y ca-certificates curl gnupg lsb-release

    # Adiciona a chave GPG oficial do Docker
    echo "▶️ Adicionando a chave GPG oficial do Docker..."
    sudo install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    sudo chmod a+r /etc/apt/keyrings/docker.gpg
    check_installation "Chave GPG do Docker"

    # Adiciona o repositório do Docker
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

    # Instala o Docker Engine e o plugin do Docker Compose
    echo "▶️ Instalando o Docker Engine e o Docker Compose (plugin)..."
    sudo apt-get update -y
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
    check_installation "Docker e Docker Compose"

    # Adiciona o usuário atual ao grupo docker para executar comandos sem sudo
    echo "▶️ Adicionando o usuário '$USER' ao grupo 'docker'..."
    sudo usermod -aG docker $USER
    check_installation "Adição do usuário ao grupo docker"

    echo "✅ Instalação do Docker e Docker Compose concluída!"
    echo "⚠️ Por favor, saia e entre novamente no terminal para que as alterações do grupo 'docker' tenham efeito."
}

# ------------------------------------------------------------------------------
# Configuração dos arquivos para o n8n
# ------------------------------------------------------------------------------
configure_n8n() {
    echo "▶️ Criando diretórios e arquivos de configuração para o n8n..."

    # Cria o diretório para o n8n
    mkdir -p ~/$N8N_DIR
    cd ~/$N8N_DIR

    # Cria o arquivo .env
    echo "N8N_HOST=$N8N_HOST" > .env
    echo "GENERIC_TIMEZONE=$TIMEZONE" >> .env
    check_installation "Arquivo .env"

    # Cria o arquivo docker-compose.yml
    cat << EOF > docker-compose.yml
version: '3.8'

services:
  n8n:
    image: n8nio/n8n
    restart: always
    ports:
      - "5678:5678"
    volumes:
      - n8n_data:/home/node/.n8n
    environment:
      - N8N_HOST=\${N8N_HOST}
      - N8N_PORT=5678
      - N8N_PROTOCOL=http
      - WEBHOOK_URL=http://\${N8N_HOST}:5678/
      - VUE_APP_URL_BASE_API=http://\${N8N_HOST}:5678/
      - GENERIC_TIMEZONE=\${GENERIC_TIMEZONE}

volumes:
  n8n_data:
EOF
    check_installation "Arquivo docker-compose.yml"

    echo "✅ Configuração do n8n concluída!"
}

# ------------------------------------------------------------------------------
# Inicia o n8n
# ------------------------------------------------------------------------------
start_n8n() {
    echo "▶️ Iniciando o contêiner do n8n com Docker Compose..."
    cd ~/$N8N_DIR
    docker compose up -d
    check_installation "Início do contêiner do n8n"

    echo "✅ n8n iniciado com sucesso! Acompanhe o log com 'docker compose logs -f'."
    echo "🌐 Acesse o n8n em http://$N8N_HOST:5678"
}

# ------------------------------------------------------------------------------
# Execução do script
# ------------------------------------------------------------------------------
main() {
    get_ip_address
    install_docker
    configure_n8n
    start_n8n
}

main