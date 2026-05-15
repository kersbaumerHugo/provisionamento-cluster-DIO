#!/bin/bash
# Script de provisionamento para os nós workers do cluster Docker Swarm
#-----------------------------------------------#
#Primeira etapa: provisionamento comum
#-----------------------------------------------#
set -e

echo "=== Configurando worker $(hostname) ==="

echo "=== Aguardando comando de join do master ==="
while [ ! -f /vagrant/join-worker.sh ]; do
    echo "Arquivo /vagrant/join-worker.sh ainda não encontrado. Aguardando..."
    sleep 5
done
#Executando o comando de join para entrar no cluster Swarm
if docker info | grep -q "Swarm: active"; then
    echo "=== Este nó já participa de um Swarm ==="
else
    echo "=== Entrando no cluster Swarm ==="
    bash /vagrant/join-worker.sh
fi

echo "=== Worker $(hostname) configurado com sucesso ==="