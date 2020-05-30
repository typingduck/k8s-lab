# -*- mode: ruby -*-
# vi: set ft=ruby :

DEPLOY_SCRIPT = 'install_k8s.sh'

# Deploy 3 virtual machines then run DEPLOY_SCRIPT on each.
Vagrant.configure("2") do |config|
  config.vm.box = "hashicorp/bionic64"

  # Create 3 machines VMs a private network with assigned hostnames and IPs.
  (1..3).each do |n|
    config.vm.define "ducky#{n}" do |node|
      node.vm.hostname = "ducky#{n}"
      node.vm.network "private_network",
        ip: "172.17.17.#{n}0",
        netmask: "255.255.255.0"
    end
  end

  # Run this script on the 3 VMs.
  config.vm.provision "shell", path: DEPLOY_SCRIPT
end
