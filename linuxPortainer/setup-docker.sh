#!/bin/bash
set -e

echo "🚀 Iniciando pós-instalação do Docker (root mode)..."

# 1. Atualizar sistema
apt update && apt upgrade -y

# 2. Instalar pacotes básicos
apt install -y curl wget vim git htop net-tools unzip ca-certificates gnupg lsb-release

# 3. Adicionar chave e repositório Docker
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
  $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

# 4. Instalar Docker e Compose plugin
apt update
apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# 5. Habilitar Docker
systemctl enable docker
systemctl start docker

# 6. Configurar daemon.json (otimização de logs e cgroup systemd)
mkdir -p /etc/docker
cat <<EOF > /etc/docker/daemon.json
{
  "data-root": "/var/lib/docker",
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m",
    "max-file": "3"
  },
  "exec-opts": ["native.cgroupdriver=systemd"]
}
EOF

# 7. Reiniciar Docker para aplicar configs
systemctl restart docker

# 8. Testar instalação
docker run --rm hello-world || true

# 9. Instalar Portainer (painel web de gestão Docker)
echo "📦 Instalando Portainer..."
docker volume create portainer_data
docker run -d -p 9443:9443 --name portainer \
    --restart=always \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v portainer_data:/data \
    portainer/portainer-ce:latest

echo "✅ Instalação concluída!"
echo "➡️ Acesse o Portainer em: https://$(hostname -I | awk '{print $1}'):9443"