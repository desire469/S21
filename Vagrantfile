Vagrant.configure("2") do |config|
    config.vm.box = "ubuntu/jammy64"
    config.vm.provider "virtualbox" do |vb|
      vb.memory = "4096"
      vb.cpus = 2
      vb.customize ["modifyvm", :id, "--nictype1", "82540EM"]
      vb.customize ["modifyvm", :id, "--nictype2", "82540EM"]
    end
  
    config.vm.provision "shell", inline: "apt update && apt upgrade -y", name: "update_upgrade"
    config.vm.provision "shell", inline: "sudo swapoff -a", name: "swap"
    config.vm.synced_folder "./src", "/home/vagrant/src"
  
    config.vm.define "manager01" do |manager|
      manager.vm.hostname = "manager01"
      manager.vm.network "private_network", ip: "192.168.56.11"
      
      manager.vm.network "forwarded_port", guest: 8087, host: 8087, host_ip: "127.0.0.1", id: "nginx_api_8087"
      manager.vm.network "forwarded_port", guest: 8081, host: 8081, host_ip: "127.0.0.1", id: "nginx_api_8081"

      manager.vm.provision "shell", inline: 'curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--disable=traefik --node-ip=192.168.56.11 --flannel-backend=host-gw" sh - && cp /var/lib/rancher/k3s/server/node-token /home/vagrant/src/node-token', name: "install_manager"
      manager.vm.provision "shell", inline: 'sudo apt install nginx && cp /home/vagrant/src/services/nginx/default.conf /etc/nginx/conf.d/default.conf', name: "install_nginx"
    end
  
    config.vm.define "worker01" do |worker|
      worker.vm.hostname = "worker01"
      worker.vm.network "private_network", ip: "192.168.56.12"
      worker.vm.provision "shell", inline: 'sleep 10 && sudo curl -sfL https://get.k3s.io | K3S_URL=https://192.168.56.11:6443 INSTALL_K3S_EXEC="--node-ip=192.168.56.12" K3S_TOKEN=$(cat /home/vagrant/src/node-token) sh -', name: "join_worker"
    end
  
    config.vm.define "worker02" do |worker|
      worker.vm.hostname = "worker02"
      worker.vm.network "private_network", ip: "192.168.56.13"
      worker.vm.provision "shell", inline: 'sleep 10 && sudo curl -sfL https://get.k3s.io | K3S_URL=https://192.168.56.11:6443 INSTALL_K3S_EXEC="--node-ip=192.168.56.13" K3S_TOKEN=$(cat /home/vagrant/src/node-token) sh -', name: "join_worker"
    end
  end