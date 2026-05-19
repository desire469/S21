Vagrant.configure("2") do |config|
    config.vm.box = "ubuntu/jammy64"
    config.vm.provider "virtualbox" do |vb|
      vb.memory = "4096"
      vb.cpus = 2

      vb.customize ["modifyvm", :id, "--nictype1", "virtio"]
      vb.customize ["modifyvm", :id, "--nictype2", "virtio"]
    end

    config.vm.synced_folder "./src/services", "/home/vagrant/services"
  
    config.vm.define "manager" do |manager|
      manager.vm.hostname = "manager"
      manager.vm.network "private_network", ip: "192.168.56.11"

      manager.vm.synced_folder "./src", "/home/vagrant/src"

      manager.vm.provision "shell", name:"ansible_install", inline: <<-SHELL
      sudo apt update
      sudo apt install -y software-properties-common
      sudo add-apt-repository --yes --update ppa:ansible/ansible
      sudo apt install -y ansible sshpass      
      SHELL
    end
    config.vm.provision "shell", name: "allow_ssh_password", inline:"sudo sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config.d/60-cloudimg-settings.conf; sudo systemctl restart sshd; echo \"vagrant:vagrant\" | sudo chpasswd"
  
    config.vm.define "node01" do |node|
      node.vm.hostname = "node01"
      node.vm.network "private_network", ip: "192.168.56.12"
      node.vm.network "forwarded_port", guest: 8081, host: 8081, host_ip: "127.0.0.1", id: "nginx_api_8081"
      node.vm.network "forwarded_port", guest: 8087, host: 8087, host_ip: "127.0.0.1", id: "nginx_api_8087"
    end
  
    config.vm.define "node02" do |node|
      node.vm.hostname = "node02"
      node.vm.network "private_network", ip: "192.168.56.13"
    end
end