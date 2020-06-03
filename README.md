# k8s-lab: automated Kubernetes test cluster
Quickly set up a 3 node virtual machine based Kubernetes test cluster,
for example if you wanted a cluster on your laptop.

Useful for developing when minikube's single node cluster is not realistic
enough and cloud solutions are too heavy. 

## Requirements

* [vagrant](https://www.vagrantup.com/)
* A suitable hypervisor for vagrant such as virtualbox

## Deploy

    > cd k8s-lab
    > vagrant up

This should set everything up with host `ducky1` as the master. Then to see the cluster

    > vagrant ssh ducky1
    > kubectl get nodes
        NAME     STATUS   ROLES    AGE    VERSION
        ducky1   Ready    master   1m     v1.18.3
        ducky2   Ready    <none>   1m     v1.18.3
        ducky3   Ready    <none>   1m     v1.18.3

## Running `kubectl` on host (laptop) machine

The installation script automatically creates a k8s config in `.kube/`.
Just set the `KUBECONFIG` environment variable before running the command
(by default kubectl will try use `~/.kube/config`).

    > export KUBECONFIG=`pwd`/.kube/config
    > kubectl get nodes

## Extras

See [EXAMPLES.md](EXAMPLES.md) for examples of performing actions on the cluster.
