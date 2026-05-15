# Docker Swarm Cluster com Vagrant

Projeto desenvolvido como parte de um desafio da DIO, com o objetivo de criar um ambiente automatizado de cluster Docker Swarm utilizando Vagrant, VirtualBox e Shell Script.

A proposta original foi expandida para entregar um laboratório mais completo de infraestrutura como código, incluindo provisionamento automático de máquinas virtuais, instalação do Docker, instalação do Apache, configuração de cluster Swarm e deploy de serviços replicados.

---

## Objetivo do Projeto

O objetivo deste projeto é demonstrar, de forma prática, a criação automatizada de um cluster Docker Swarm local utilizando máquinas virtuais provisionadas com Vagrant.

O ambiente é composto por três máquinas virtuais Ubuntu:

- um nó `master`, responsável por inicializar e gerenciar o cluster;
- dois nós `workers`, responsáveis por executar os containers distribuídos pelo Swarm.

Além da criação do cluster, o projeto também realiza automaticamente:

- instalação do Docker Engine;
- instalação do Apache2 em cada VM;
- configuração de uma página web local em cada máquina;
- inicialização do Docker Swarm;
- entrada automática dos workers no cluster;
- criação de rede overlay;
- deploy de serviços web replicados;
- publicação de portas para acesso aos serviços;
- deploy de um visualizador gráfico do cluster.

---

## Arquitetura do Ambiente

| Máquina | IP | Função |
|---|---:|---|
| master | 10.10.10.100 | Manager do Docker Swarm |
| node01 | 10.10.10.101 | Worker |
| node02 | 10.10.10.102 | Worker |

Representação simplificada:

```text
+----------------------+
|      Host Local      |
| Vagrant + VirtualBox |
+----------+-----------+
           |
           |
+----------+-----------+
|                      |
| Docker Swarm Cluster |
|                      |
+----------+-----------+
           |
           |
+----------------+     +----------------+     +----------------+
|    master      |     |    node01      |     |    node02      |
| 10.10.10.100   |     | 10.10.10.101   |     | 10.10.10.102   |
| Swarm Manager  |     | Swarm Worker   |     | Swarm Worker   |
+----------------+     +----------------+     +----------------+
```

---

## Tecnologias Utilizadas

- Vagrant
- VirtualBox
- Ubuntu Server
- Docker Engine
- Docker Swarm
- Apache2
- Shell Script
- Nginx
- HTTPD
- Docker Visualizer

---

## Estrutura do Projeto

```text
docker-swarm-vagrant-lab/
├── Vagrantfile
├── README.md
├── .env.example
├── .gitignore
└── scripts/
    ├── common.sh
    ├── master.sh
    └── worker.sh
```

### Descrição dos arquivos

| Arquivo | Descrição |
|---|---|
| `Vagrantfile` | Define as máquinas virtuais, IPs, recursos e scripts de provisionamento |
| `.env.example` | Arquivo de exemplo com as variáveis de configuração do ambiente |
| `scripts/common.sh` | Script executado em todas as VMs para instalar Docker, Apache e utilitários |
| `scripts/master.sh` | Script responsável por inicializar o Swarm e publicar os serviços |
| `scripts/worker.sh` | Script responsável por conectar os workers ao cluster |
| `.gitignore` | Evita o versionamento de arquivos locais, tokens e arquivos gerados |

---

## Pré-requisitos

Antes de executar o projeto, é necessário ter instalado na máquina host:

- Vagrant
- VirtualBox
- Git

Também é recomendado ter pelo menos:

- 4 GB de RAM disponível;
- 2 CPUs disponíveis;
- conexão com a internet para download das imagens e pacotes.

---

## Configuração do Ambiente

O projeto utiliza um arquivo `.env` para centralizar configurações como IPs, nomes das máquinas, portas dos serviços e recursos das VMs.

Primeiro, copie o arquivo de exemplo:

```bash
cp .env.example .env
```

Exemplo de configuração:

```env
MASTER_HOSTNAME=master
MASTER_IP=10.10.10.100

NODE01_HOSTNAME=node01
NODE01_IP=10.10.10.101

NODE02_HOSTNAME=node02
NODE02_IP=10.10.10.102

VM_BOX=bento/ubuntu-22.04
VM_MEMORY=1024
VM_CPUS=1

NGINX_SERVICE_NAME=web-nginx
APACHE_SERVICE_NAME=web-apache
VISUALIZER_SERVICE_NAME=visualizer

NGINX_PORT=8080
APACHE_CONTAINER_PORT=8081
VISUALIZER_PORT=8088
```

O uso do `.env` evita que informações de configuração fiquem espalhadas pelos scripts, facilitando manutenção e alterações futuras.

---

## Como Executar o Projeto

Clone o repositório:

```bash
git clone https://github.com/seu-usuario/seu-repositorio.git
```

Acesse o diretório do projeto:

```bash
cd seu-repositorio
```

Crie o arquivo `.env`:

```bash
cp .env.example .env
```

Suba as máquinas virtuais:

```bash
vagrant up
```

Durante esse processo, o Vagrant irá:

1. criar as três máquinas virtuais;
2. configurar os IPs privados;
3. instalar os pacotes necessários;
4. instalar o Docker;
5. instalar o Apache;
6. inicializar o cluster Swarm no master;
7. conectar os workers ao cluster;
8. realizar o deploy dos serviços.

---

## Como Acessar as Máquinas

Para acessar o nó master:

```bash
vagrant ssh master
```

Para acessar o node01:

```bash
vagrant ssh node01
```

Para acessar o node02:

```bash
vagrant ssh node02
```

---

## Validação do Cluster

Após o provisionamento, acesse o master:

```bash
vagrant ssh master
```

Liste os nós do cluster:

```bash
docker node ls
```

A saída esperada deve apresentar três nós:

```text
ID                            HOSTNAME   STATUS    AVAILABILITY   MANAGER STATUS
xxxxxxxxxxxx                  master     Ready     Active         Leader
xxxxxxxxxxxx                  node01     Ready     Active
xxxxxxxxxxxx                  node02     Ready     Active
```

---

## Validação dos Serviços

Liste os serviços publicados no cluster:

```bash
docker service ls
```

Serviços esperados:

| Serviço | Porta | Descrição |
|---|---:|---|
| `web-nginx` | 8080 | Serviço Nginx replicado no Swarm |
| `web-apache` | 8081 | Serviço Apache HTTPD replicado no Swarm |
| `visualizer` | 8088 | Interface visual para observar o cluster |

Para verificar onde as réplicas estão rodando:

```bash
docker service ps web-nginx
docker service ps web-apache
docker service ps visualizer
```

---

## Acessando os Serviços

### Apache instalado diretamente nas VMs

Cada máquina virtual possui Apache instalado diretamente no sistema operacional.

Acesse pelo navegador:

```text
http://10.10.10.100
http://10.10.10.101
http://10.10.10.102
```

Ou teste via terminal:

```bash
curl http://10.10.10.100
curl http://10.10.10.101
curl http://10.10.10.102
```

---

### Serviço Nginx no Docker Swarm

```text
http://10.10.10.100:8080
```

Teste via terminal:

```bash
curl http://10.10.10.100:8080
```

---

### Serviço Apache HTTPD no Docker Swarm

```text
http://10.10.10.100:8081
```

Teste via terminal:

```bash
curl http://10.10.10.100:8081
```

---

### Docker Swarm Visualizer

```text
http://10.10.10.100:8088
```

O visualizer permite observar graficamente em quais nós os containers estão sendo executados.

---

## Comandos Úteis

Ver status das VMs:

```bash
vagrant status
```

Acessar o master:

```bash
vagrant ssh master
```

Listar nós do Swarm:

```bash
docker node ls
```

Listar serviços:

```bash
docker service ls
```

Ver detalhes de um serviço:

```bash
docker service ps web-nginx
```

Ver containers em execução:

```bash
docker ps
```

Ver redes Docker:

```bash
docker network ls
```

Ver informações do Docker:

```bash
docker info
```

Reexecutar o provisionamento:

```bash
vagrant provision
```

Destruir o ambiente:

```bash
vagrant destroy -f
```

Subir tudo novamente:

```bash
vagrant up
```

---

## Serviços Criados Automaticamente

### Serviço Nginx

O serviço `web-nginx` é criado com três réplicas:

```bash
docker service create \
  --name web-nginx \
  --replicas 3 \
  --publish 8080:80 \
  --network app-net \
  nginx:latest
```

Esse serviço demonstra o balanceamento e distribuição de containers entre os nós do cluster.

---

### Serviço Apache HTTPD

O serviço `web-apache` também é criado com três réplicas:

```bash
docker service create \
  --name web-apache \
  --replicas 3 \
  --publish 8081:80 \
  --network app-net \
  httpd:latest
```

Ele serve como segundo exemplo de aplicação web executando dentro do Swarm.

---

### Serviço Visualizer

O serviço `visualizer` é criado apenas no nó manager:

```bash
docker service create \
  --name visualizer \
  --publish 8088:8080 \
  --constraint node.role==manager \
  --mount type=bind,src=/var/run/docker.sock,dst=/var/run/docker.sock \
  dockersamples/visualizer
```

Esse serviço permite visualizar de forma gráfica a distribuição dos containers no cluster.

---

## Rede Overlay

O projeto cria uma rede overlay chamada `app-net`:

```bash
docker network create --driver overlay --attachable app-net
```

Essa rede permite que os serviços do Swarm se comuniquem entre si, mesmo quando os containers estão executando em nós diferentes.

---

## Boas Práticas Aplicadas

Este projeto utiliza algumas práticas importantes de automação e infraestrutura:

- configuração centralizada em `.env`;
- separação entre lógica de configuração e scripts de provisionamento;
- scripts separados por responsabilidade;
- provisionamento automatizado com Vagrant;
- não versionamento de arquivos sensíveis ou gerados;
- criação automatizada de cluster;
- uso de serviços replicados;
- uso de rede overlay;
- validação por comandos Docker;
- documentação detalhada do ambiente.

---

## Arquivos Gerados em Tempo de Execução

Durante o provisionamento, o nó master gera automaticamente arquivos auxiliares para permitir a entrada dos workers no cluster:

```text
worker-token
join-worker.sh
```

Esses arquivos não devem ser versionados, pois contêm informações específicas do cluster local.

Por isso, eles devem estar no `.gitignore`:

```gitignore
.vagrant/
.env
worker-token
join-worker.sh
```

---

## Possíveis Problemas e Soluções

### Erro ao subir as máquinas

Caso ocorra erro no provisionamento, uma opção é destruir e recriar o ambiente:

```bash
vagrant destroy -f
vagrant up
```

---

### Workers não entraram no cluster

Acesse o master e verifique se o Swarm está ativo:

```bash
docker node ls
```

Verifique se o arquivo de join foi criado:

```bash
ls -la /vagrant/join-worker.sh
```

Reexecute o provisionamento:

```bash
vagrant provision
```

---

### Serviço não está acessível

Verifique se o serviço está rodando:

```bash
docker service ls
```

Verifique as tarefas do serviço:

```bash
docker service ps web-nginx
```

Verifique se as portas foram publicadas corretamente:

```bash
docker service inspect web-nginx
```

---

## Melhorias Futuras

Algumas melhorias possíveis para evolução do projeto:

- adicionar Docker Compose com stack deploy;
- criar uma aplicação web personalizada;
- adicionar banco de dados em container;
- adicionar monitoramento com Prometheus e Grafana;
- adicionar logs centralizados;
- implementar backup dos volumes;
- criar pipeline CI/CD para deploy automático;
- utilizar Ansible no lugar dos scripts shell;
- adicionar testes automatizados de validação do ambiente.

---

## Conclusão

Este projeto demonstra a criação de um ambiente de cluster Docker Swarm de forma totalmente automatizada utilizando Vagrant e Shell Script.

Além da proposta original do desafio, o ambiente foi expandido para incluir instalação de pacotes, configuração de Apache nas VMs, centralização de variáveis em arquivo `.env`, deploy de múltiplos serviços replicados e visualização gráfica do cluster.

Com isso, o projeto se aproxima de um cenário real de infraestrutura como código, automação de ambientes e orquestração de containers.

---

## Autor

Desenvolvido por Hugo Kersbaumer como parte dos estudos em Docker, DevOps e infraestrutura como código.
