# this file is shared between all vagrant nodes and once the
# master is up # it should overwrite this with the join command from
# `kubeadm --print-join-command`

echo ERROR: join.sh script ran without join command being added from master node 1>&2
exit 1
