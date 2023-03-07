# maintenance

## Upgrade

Here's a quick runbook for upgrading clusters according to [the docs](https://kubernetes.io/docs/tasks/administer-cluster/kubeadm/kubeadm-upgrade/).

1. Select a target version according to the [skew policy](https://kubernetes.io/releases/version-skew-policy/)
2. Update kubeadm to the target version on all master & worker nodes
3. Upgrade the control-plane to the target version using on the first master node:

- `kubeadm upgrade plan`
- `kubeadm upgrade apply <target_version>`
- `kubectl drain master1 --ignore-emptydir-data --ignore-daemonsets`
- `apt-mark unhold kubelet kubectl`
- `apt-get update && apt-get upgrade` (upgrade can also be limited to only kubectl+kubelet)
- `apt-mark hold kubelet kubectl`
- `sudo systemctl daemon-reload`
- `sudo systemctl restart kubelet`
- `kubectl uncordon master1`

4. Upgrade the control-plane on the other master nodes too using:

- `kubeadm upgrade node`
- `kubectl drain master2 --ignore-emptydir-data --ignore-daemonsets`
- `apt-mark unhold kubelet kubectl`
- `apt-get update && apt-get upgrade` (upgrade can also be limited to only kubectl+kubelet)
- `apt-mark hold kubelet kubectl`
- `sudo systemctl daemon-reload`
- `sudo systemctl restart kubelet`
- `kubectl uncordon master2`

5. Now that all master-nodes are running the new control-plane components and use the new kubelet, do the same for the nodes in rolling upgrade fashion:

- `kubeadm upgrade node`
- `kubectl drain worker1 --ignore-emptydir-data --ignore-daemonsets`
- `apt-mark unhold kubelet kubectl`
- `apt-get update && apt-get upgrade` (upgrade can also be limited to only kubectl+kubelet)
- `apt-mark hold kubelet kubectl`
- `sudo systemctl daemon-reload`
- `sudo systemctl restart kubelet`
- `kubectl uncordon worker1`
