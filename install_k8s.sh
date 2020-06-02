#!/usr/bin/env bash
# Installs kubernetes from scratch and starts it.
# Assumed to be run as superuser by vagrant (and is thus
# obviously only intended for quick private test clusters).

set -uxe

MASTER_HOSTNAME='ducky1'
MASTER_IP="172.17.17.10"
POD_NETWORK_CIDR="10.222.0.0/16"  # this needs to match what kube-flannel.yaml has

# k8s don't like swap
swapoff -a

# Explicity tell kubelet its IP (otherwise cluster works but kubectl cannot access containers on a node)
NODE_IP=$(/sbin/ifconfig eth1 | grep -i mask | awk '{print $2}'| cut -f2 -d:)
echo "KUBELET_EXTRA_ARGS=\"--node-ip=${NODE_IP}\"" > /etc/default/kubelet

# Download kubernetes...
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu 
  $(lsb_release -cs) 
  stable"
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
cat << EOF | tee /etc/apt/sources.list.d/kubernetes.list
  deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF
apt-get update
apt-get install -y docker-ce kubelet kubeadm kubectl
apt-mark hold docker-ce kubelet kubeadm kubectl

NODE_JOIN_SCRIPT=/vagrant/.kube/node_join.sh

if [[ $(hostname) == "${MASTER_HOSTNAME}" ]]; then
	# start the master
	kubeadm init \
		--pod-network-cidr=${POD_NETWORK_CIDR} \
		--apiserver-advertise-address=${MASTER_IP} \
		--ignore-preflight-errors=NumCPU # ignore the k8s default of min 2 cpus
	# place kubectl config so both user vagrant on master and host user can run kubectl
	if [ ! -d "/vagrant" ]; then
		echo ERROR: expected hypervisor shared folder /vagrant not found 1>&2
		exit 1
	fi
	mkdir -p /vagrant/.kube
	ln -s /vagrant/.kube /home/vagrant/.kube 
	cp /etc/kubernetes/admin.conf /vagrant/.kube/config
	# networking
	NETWORK_ADDON="/vagrant/configs/kube-flannel.yaml"
	sudo -Hu vagrant kubectl apply -f ${NETWORK_ADDON}
	# add custom token to master
	kubeadm token create --print-join-command > "${NODE_JOIN_SCRIPT}"
else
	if [ ! -f "${NODE_JOIN_SCRIPT}" ]; then
		echo ERROR: expected hypervisor shared executable "${NODE_JOIN_SCRIPT}" not found 1>&2
		exit 1
	fi
	bash $NODE_JOIN_SCRIPT
fi
