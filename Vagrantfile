def load_env(file)
    """Carrega variáveis de ambiente a partir de um arquivo .env."""
  return {} unless File.exist?(file)

  File.readlines(file).each_with_object({}) do |line, env|
    line = line.strip
    next if line.empty? || line.start_with?("#")

    key, value = line.split("=", 2)
    env[key] = value
  end
end
# Carrega as variáveis de ambiente do arquivo .env para configurar o Vagrantfile
env = load_env(".env")

# Configuração do Vagrant para provisionar um cluster Docker Swarm com um nó master e dois nós workers
Vagrant.configure("2") do |config|
    # Configura a box base para as máquinas virtuais, permitindo que seja personalizada via variável de ambiente
    config.vm.box = env["VM_BOX"] || "bento/ubuntu-22.04"
    # Configura os recursos de hardware para as máquinas virtuais, como memória e CPUs, permitindo personalização via variáveis de ambiente
    config.vm.provider "virtualbox" do |vb|
    vb.memory = env["VM_MEMORY"] || 1024
    vb.cpus = env["VM_CPUS"] || 1
  end

  nodes = [
    {
      name: env["MASTER_HOSTNAME"] || "master",
      ip: env["MASTER_IP"] || "10.10.10.100",
      role: "master"
    },
    {
      name: env["NODE01_HOSTNAME"] || "node01",
      ip: env["NODE01_IP"] || "10.10.10.101",
      role: "worker"
    },
    {
      name: env["NODE02_HOSTNAME"] || "node02",
      ip: env["NODE02_IP"] || "10.10.10.102",
      role: "worker"
    }
    #... Adicione mais nós aqui, se necessário
  ]
#Itera sobre a configuração dos nós para definir cada máquina virtual, 
#configurando hostname, rede, provedor e provisionamento de acordo com o papel (master ou worker) de cada nó
nodes.each do |node|
    config.vm.define node[:name] do |machine|
      machine.vm.hostname = node[:name]
      machine.vm.network "private_network", ip: node[:ip]

      machine.vm.provider "virtualbox" do |vb|
        vb.name = "dio-swarm-#{node[:name]}"
      end

      machine.vm.provision "shell", path: "scripts/common.sh"

      if node[:role] == "master"
        machine.vm.provision "shell",
          path: "scripts/master.sh",
          env: {
            "MASTER_IP" => env["MASTER_IP"] || "10.10.10.100",
            "NGINX_SERVICE_NAME" => env["NGINX_SERVICE_NAME"] || "web-nginx",
            "APACHE_SERVICE_NAME" => env["APACHE_SERVICE_NAME"] || "web-apache",
            "VISUALIZER_SERVICE_NAME" => env["VISUALIZER_SERVICE_NAME"] || "visualizer",
            "NGINX_PORT" => env["NGINX_PORT"] || "8080",
            "APACHE_CONTAINER_PORT" => env["APACHE_CONTAINER_PORT"] || "8081",
            "VISUALIZER_PORT" => env["VISUALIZER_PORT"] || "8088"
          }
      else
        machine.vm.provision "shell",
          path: "scripts/worker.sh",
          env: {
            "MASTER_IP" => env["MASTER_IP"] || "10.10.10.100"
          }
      end
    end
  end
end