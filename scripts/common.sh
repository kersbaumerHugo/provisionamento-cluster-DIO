#!/bin/bash
# Script de provisionamento comum para master e workers
#-----------------------------------------------#
#Primeira etapa: atualizar o sistema
#-----------------------------------------------#

#Set -e para garantir que o script pare em caso de erro
set -e

echo "=== Atualizando pacotes ==="
sudo apt-get update -y

echo "=== Instalando pacotes base ==="
sudo apt-get install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release \
    git \
    vim \
    htop \
    net-tools \
    jq \
    apache2

#-----------------------------------------------#
#Segunda etapa: configuração do Apache local
#-----------------------------------------------#
echo "=== Configurando Apache local ==="
HOSTNAME=$(hostname)

sudo tee /var/www/html/index.html > /dev/null <<EOF
<!DOCTYPE html>
<html>
<head>
    <title>Servidor ${HOSTNAME}</title>
</head>
<body>
    <h1>Servidor ${HOSTNAME}</h1>
    <p>Apache instalado automaticamente via Vagrant Provisioning.</p>
    <p>Projeto DIO - Docker Swarm com Vagrant.</p>
</body>
</html>
EOF
#Habilitando e reiniciando o serviço Apache
sudo systemctl enable apache2
sudo systemctl restart apache2
#-----------------------------------------------#
#Terceira etapa: instalação do Docker
#-----------------------------------------------#
echo "=== Removendo possíveis versões conflitantes do Docker ==="
for pkg in docker.io docker-doc docker-compose podman-docker containerd runc; do
    sudo apt-get remove -y $pkg || true
done

echo "=== Instalando Docker via repositório oficial ==="
sudo install -m 0755 -d /etc/apt/keyrings

#Caso a chave GPG do Docker ainda não esteja presente, faça o download e armazene-a
#Isso garante que o repositório do Docker seja confiável e que os pacotes possam ser verificados corretamente
if [ ! -f /etc/apt/keyrings/docker.gpg ]; then
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
    sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
fi

#Garantindo que a chave GPG do Docker tenha as permissões corretas para leitura por todos os usuários
sudo chmod a+r /etc/apt/keyrings/docker.gpg

#Adicionando o repositório do Docker à lista de fontes do APT, utilizando a chave GPG para garantir a autenticidade dos pacotes
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

#Atualizando a lista de pacotes para incluir os do repositório do Docker
sudo apt-get update -y
#Instalando os pacotes do Docker, incluindo o Docker Engine, CLI, containerd e plugins de buildx e compose
sudo apt-get install -y \
    docker-ce \
    docker-ce-cli \
    containerd.io \
    docker-buildx-plugin \
    docker-compose-plugin

echo "=== Habilitando Docker ==="
sudo systemctl enable docker
sudo systemctl start docker

echo "=== Adicionando usuário vagrant ao grupo docker ==="
sudo usermod -aG docker vagrant

echo "=== Versões instaladas ==="
docker --version
apache2 -v

echo "=== Provisionamento comum finalizado em ${HOSTNAME} ==="