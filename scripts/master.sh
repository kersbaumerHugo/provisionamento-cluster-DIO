#!/bin/bash
# Script de provisionamento para o nó master do cluster Docker Swarm
#-----------------------------------------------#
#Primeira etapa: provisionamento comum
#-----------------------------------------------#
set -e
#Pegar IP do vagrant para o nó master
MASTER_IP="10.10.10.100"


echo "=== Configurando nó master do Docker Swarm ==="

if ! docker info | grep -q "Swarm: active"; then
    echo "=== Inicializando Docker Swarm ==="
    docker swarm init --advertise-addr ${MASTER_IP}
else
    echo "=== Swarm já está ativo neste nó ==="
fi

echo "=== Gerando comando para workers entrarem no cluster ==="
docker swarm join-token worker -q > /vagrant/worker-token

cat > /vagrant/join-worker.sh <<EOF
#!/bin/bash
docker swarm join --token $(cat /vagrant/worker-token) ${MASTER_IP}:2377
EOF

chmod +x /vagrant/join-worker.sh

echo "=== Criando rede overlay ==="
docker network create --driver overlay --attachable app-net || true

echo "=== Criando serviço web replicado com Nginx ==="
docker service create \
  --name web-nginx \
  --replicas 3 \
  --publish 8080:80 \
  --network app-net \
  nginx:latest || true

echo "=== Criando serviço Apache HTTPD replicado ==="
docker service create \
  --name web-apache \
  --replicas 3 \
  --publish 8081:80 \
  --network app-net \
  httpd:latest || true

echo "=== Criando serviço visualizer do cluster ==="
docker service create \
  --name visualizer \
  --publish 8088:8080 \
  --constraint node.role==manager \
  --mount type=bind,src=/var/run/docker.sock,dst=/var/run/docker.sock \
  dockersamples/visualizer || true

echo "=== Status do cluster ==="
docker node ls

echo "=== Serviços publicados ==="
docker service ls

echo "=== Master configurado com sucesso ==="