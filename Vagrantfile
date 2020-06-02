# -*- mode: ruby -*-
# vi: set ft=ruby :

DEPLOY_SCRIPT = 'install_k8s.sh'
NUM_NODES = 3 # includes master

# Deploy 3 virtual machines then run DEPLOY_SCRIPT on each.
Vagrant.configure("2") do |config|
  config.vm.box = "hashicorp/bionic64"  # lightweight ubuntu

  # Create NUM_NODES machines VMs a private network with assigned hostnames and IPs.
  (1..NUM_NODES).each do |n|
    config.vm.define "ducky#{n}" do |node|
      node.vm.hostname = "ducky#{n}"
      node.vm.network "private_network",
        ip: "172.17.17.#{9+n}",
        netmask: "255.255.255.0"
      is_master = n == 1
      node.vm.provider "virtualbox" do |mach|
        mach.memory = is_master ? 2048 : 1024
        mach.cpus = is_master ? 2 : 1
      end
    end
  end

  # Run this script on the all the VMs (scripts already knows which is master)
  config.vm.provision "shell", path: DEPLOY_SCRIPT
end
