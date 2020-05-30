# k8s-lab: automated Kubernetes test cluster
Quickly set up a 3 node virtual machine based Kubernetes test cluster,
for example if you wanted a cluster on your laptop.

Useful for developing when minikube's single node cluster is not realistic
enough and cloud solutions are too heavy. Uses [vagrant](https://www.vagrantup.com/)
to automate the process and be agnostic to VM host.

## Deploy

With vagrant and a suitable hypervisor installed...

    > cd k8s-lab
    > vagrant up

This should set everything up with host `ducky1` as the master. Then to see the cluster

    > vagrant ssh ducky1
    > kubectl get nodes
        NAME     STATUS   ROLES    AGE    VERSION
        ducky1   Ready    master   1m     v1.18.3
        ducky2   Ready    <none>   1m     v1.18.3
        ducky3   Ready    <none>   1m     v1.18.3

## How it works

Based on the observation that security is not important on a laptop
private network test cluster, so the process can be accelerated
by hardcoding the IPs and certs.

## Running `kubectl` on host (laptop) machine

Copy over the config from the master VM as follows

    > vagrant ssh-config > .ssh-config
    > scp -F .ssh-config ducky1:.kube/config .kube-config

Then just set the `KUBECONFIG` environment variable before running the command
(by default kubectl will try use `~/.kube/config`).

    > export KUBECONFIG=`pwd`/.kube-config
    > kubectl get nodes
