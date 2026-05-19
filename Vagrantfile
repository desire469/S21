Vagrant.configure("2") do |config|
    config.vm.box = "ubuntu/jammy64"
    config.vm.provider "virtualbox" do |vb|
      vb.memory = "4096"
      vb.cpus = 2
      vb.customize ["modifyvm", :id, "--nictype1", "virtio"]
      vb.customize ["modifyvm", :id, "--nictype2", "virtio"]
    end
  
    config.vm.define "manager01" do |manager|
      manager.vm.hostname = "manager01"

      manager.vm.network "private_network", ip: "192.168.56.11"
      manager.vm.network "forwarded_port", guest: 9443, host: 9443, host_ip: "127.0.0.1", id: "portainer_api_9443"
      manager.vm.network "forwarded_port", guest: 9090, host: 9090, host_ip: "127.0.0.1", id: "prometheus_api_9090"
      manager.vm.network "forwarded_port", guest: 8087, host: 8087, host_ip: "127.0.0.1", id: "nginx_api_8087"
      manager.vm.network "forwarded_port", guest: 8081, host: 8081, host_ip: "127.0.0.1", id: "nginx_api_8081"
      manager.vm.network "forwarded_port", guest: 3000, host: 3000, host_ip: "127.0.0.1", id: "grafana_3000"

      manager.vm.synced_folder "./src", "/home/vagrant/src"
      
      manager.vm.synced_folder "./src/metrics", "/home/vagrant/metrics"

      manager.vm.provision "shell", path: "./src/scripts/install_docker.sh", name: "install_docker_manager"
      manager.vm.provision "shell", path: "./src/scripts/init_swarm_manager.sh", args: ["192.168.56.11"], name: "init_swarm_manager"
      manager.vm.provision "shell", inline: "docker stack deploy -c src/docker-compose.stack.yml mystack", name: "deploy_stack"
    end
  
    config.vm.define "worker01" do |worker|
      worker.vm.hostname = "worker01"
      worker.vm.network "private_network", ip: "192.168.56.12"
  
      worker.vm.synced_folder "./src/scripts", "/home/vagrant/scripts"
      worker.vm.synced_folder "./src/metrics", "/home/vagrant/metrics"
      worker.vm.provision "shell", path: "./src/scripts/install_docker.sh", name: "install_docker_worker1"
      worker.vm.provision "shell", path: "./src/scripts/join_swarm_worker.sh", name: "join_swarm_worker1"
    end
  
    config.vm.define "worker02" do |worker|
      worker.vm.hostname = "worker02"
      worker.vm.network "private_network", ip: "192.168.56.13"
  
      worker.vm.synced_folder "./src/metrics", "/home/vagrant/metrics"
      worker.vm.synced_folder "./src/scripts", "/home/vagrant/scripts"
      worker.vm.provision "shell", path: "./src/scripts/install_docker.sh", name: "install_docker_worker2"
      worker.vm.provision "shell", path: "./src/scripts/join_swarm_worker.sh", name: "join_swarm_worker2"
    end
  end