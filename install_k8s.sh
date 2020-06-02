#!/usr/bin/env bash
# Installs kubernetes from scratch and starts it.
# To make installation easier and repeatable ips and certs are
# hardcoded below (and this script is thus obviously only
# intended for quick private test clusters).

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

# certs and tokens...
# (Ok in source control as this is only for local private test kubernetes setups).
TOKEN=ducky7.inotreallysecure
CRT="-----BEGIN CERTIFICATE-----
MIICyDCCAbCgAwIBAgIBADANBgkqhkiG9w0BAQsFADAVMRMwEQYDVQQDEwprdWJl
cm5ldGVzMB4XDTIwMDUyOTE3NTkwMVoXDTMwMDUyNzE3NTkwMVowFTETMBEGA1UE
AxMKa3ViZXJuZXRlczCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAMr+
GCY4qrFk2gIR/CfmkrU0rGZpA+tvJiCrCXHvlPJ3s9JJba/hqs83CmwNg8UbcUfG
zOwhk6SyUcbIDMdu+MdNlEqMHafCdke2Okz4oSPGIHpiagLyG9z/ECftahpVWXbl
4bvSHj1aAtBxxFUTlTioLqMjERa3aXw0iEsVeGbslI8Yy77OHzXDBCzV8bKOb3yA
yQO5KlpmQeW/7buCx3Q/IHWWVWnWh1HMJhWAc4KZtLUioAg92njw+8NeF9Y/ex4P
PcaCGg0g94aEYOdU97LGG94dTYvYZo3NIi4SwtOkOixS/QJKgFzZJY9oyIhBnoP4
8qJkK/j7Rx/12EV76R8CAwEAAaMjMCEwDgYDVR0PAQH/BAQDAgKkMA8GA1UdEwEB
/wQFMAMBAf8wDQYJKoZIhvcNAQELBQADggEBAKcyghAqLyx1UpLmEuTDCOzE003s
kT+/38OHXq5OuRiuSowhiuD98k712arLhIYNtXKseqYThcNYtJtJgWWPKY4AijHe
daDv2GPswNh0CTszO+92qTyHPynhSxvmXCGoagceCO/px42fterTauphTyb3Cftm
TvpgXND/kMAHrChz0lShUKNWsm5zEcyfBE6zyn1qXdKda9hDY8MAG8eL5Y21XDNe
leNTItrUK3m5JvURCPTNHDwPXmNsROmMtO2/vPDzoxKilDxEO7wBNXlIDzagI/ZF
g+W7uvv+jJX9fWQ+ki/z+lJWfVf8Oynb3xCVn6PqQ/VcYHz8ZoQTZZ1Ryvw=
-----END CERTIFICATE-----
"
KEY="-----BEGIN RSA PRIVATE KEY-----
MIIEowIBAAKCAQEAyv4YJjiqsWTaAhH8J+aStTSsZmkD628mIKsJce+U8nez0klt
r+GqzzcKbA2DxRtxR8bM7CGTpLJRxsgMx274x02USowdp8J2R7Y6TPihI8YgemJq
AvIb3P8QJ+1qGlVZduXhu9IePVoC0HHEVROVOKguoyMRFrdpfDSISxV4ZuyUjxjL
vs4fNcMELNXxso5vfIDJA7kqWmZB5b/tu4LHdD8gdZZVadaHUcwmFYBzgpm0tSKg
CD3aePD7w14X1j97Hg89xoIaDSD3hoRg51T3ssYb3h1Ni9hmjc0iLhLC06Q6LFL9
AkqAXNklj2jIiEGeg/jyomQr+PtHH/XYRXvpHwIDAQABAoIBAQDKUHF1Nqk5YJC/
23j7s5yoqbTh5OyZLBBOIumo+uXyu0cn4TNHRp1dJThn9RhNzUocBZGcDuL+FRPY
EO5bnsioqzOPERNFblVAp+h3ap3/76nTEF8kTHVkz3oksUU8tbATBo7zCTpGX33K
jnjlaj0hWM4SnhKcF3U0646jduSnfn88vA8RMNA2mOfLhAE5xiFkkWOT1iB4lFfo
sjxedzzQ3iba0UVBgtWOVqoRX9m2mrc/0cu7YsdUSuiW0LpYAEdYUSFXB+fE9RzG
ka9Gu6lU/3hgzal7bdUaF8kSBMpVUczuHu///pARz5pIRQQZNvEbLr8oF3AJle23
PABZRzphAoGBAPojfMABd+ewKw8xC5Y7vWcdyv/ngvw+RkDlactJq2alIAscE0dE
2D+gtrG5h/70bWfE78eHbE0xKQZNthvM0eCktuI2Yj7VEeT5100y3luCS7Myn68I
kGYK9VKBmRBXn166YLLpVK2o71VMIMu5Yjpp3F9PkTKNWCQDail2JN93AoGBAM+/
ym9w/VJrFkQmySu2X8zHRAoaVN/w2lcwsSrmVvovoEuoynDcRkPstAD3qx+dYtOE
Q+N2+KfdWRYpyA4wJ/XSidYKQp4FFMetPFfcFWlah2peqignZnHnep8nWnmLa9bk
Jau7K2RBfLNAtH7XX5bzSalgxEDBXCtga8QMJT2ZAoGAYgC3Zs7seKUIKdqQbJsZ
WSZOG7dMFaIcil6X9aL2ea/mfxPP5dNuWneQPM+xHc4Mc2SwgV9oqlHBfgvCdt/n
tvkyAi1GjtGSQkE0/rUYc4f4OsxxzfUwBhrzBRFrtABwm3+wVUif+a4/nw7FpqwK
dVJ2mg0lmUXRq8J+vKHiTn8CgYB92nwyYsqz4TfN9YktOAB1N8oaLLV6LJi49UB+
8qeCTNPYwdpR4L+Yao7pfyBluJyj8p6F8A7W8psDeDA/mCC9JNxnlDOjMwTRqjrC
Jwu5lSQv5kVCqgu/uTFptRd0Rmf/+JpxnKO+yoVWuj4eES9RbPUU7RA3AmxpwrHG
RG1TEQKBgG0PLq3v8G2d0OOmYdRQNlVx1zLHzcUK6qBvdKcSw+AFKJEuK6opUmve
EuqKiVmo0klpr16ztG4bHLVb08zTaAacAtqWBj/at2xatKAM0EeOVXORtHvxauZ5
1F99v23YgeIW7G1wKZEH2A/+e+PvYorDMd2j0AS096F4PTsvGBzm
-----END RSA PRIVATE KEY-----
"
CERT_HASH="sha256:e4f586a29f0f0d9eb92aec6165bb1b88c5108cba4dd7a8604e079646f42dfd6b"

if [[ $(hostname) == "${MASTER_HOSTNAME}" ]]; then
	# use custom certs (k8s will use certs that already exist, otherwise create new)
	mkdir -p /etc/kubernetes/pki/
	echo "${CRT}" > /etc/kubernetes/pki/ca.crt
	echo "${KEY}" > /etc/kubernetes/pki/ca.key
	chmod go-r /etc/kubernetes/pki/ca.key
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
	kubeadm token create ${TOKEN}
else
	# follower host
	kubeadm join ${MASTER_IP}:6443 \
		--token ${TOKEN} \
	   	--discovery-token-ca-cert-hash ${CERT_HASH}

fi
