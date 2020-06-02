#!/usr/bin/env bash
# Installs kubernetes from scratch and starts it.
# Assumed to be run as superuser by vagrant (and is thus
# obviously only intended for quick private test clusters).

set -uxe

MASTER_HOSTNAME='ducky1'
MASTER_IP="172.17.17.10"
POD_NETWORK_CIDR="10.222.0.0/16"  # this needs to match what kube-flannel.yaml has

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

# k8s don't like swap
swapoff -a

if [[ $(hostname) == "${MASTER_HOSTNAME}" ]]; then
	# start the master
	kubeadm init \
		--pod-network-cidr=${POD_NETWORK_CIDR} \
		--apiserver-advertise-address=${MASTER_IP} \
		--ignore-preflight-errors=NumCPU # ignore the k8s default of min 2 cpus
	# files for kubectl (copy these locally if required).
	mkdir -p /home/vagrant/.kube
	cp -i /etc/kubernetes/admin.conf /home/vagrant/.kube/config
	chown -R vagrant:vagrant /home/vagrant/.kube
	# networking
	NETWORK_ADDON="/vagrant/kube-flannel.yml"
	sudo -Hu vagrant kubectl apply -f ${NETWORK_ADDON}
	# add custom token to master
	kubeadm token create --print-join-command > /vagrant/join.sh
else
	/vagrant/join.sh
fi
