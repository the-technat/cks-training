# Lab Env for CKS Course

## Requirements

Most CKS courses have the following requirements to your lab setup:

- 1 master, 1 worker
- Ubuntu 22.04 (others will work too, but this the most used)
- 2vCPU / 8GB per node (less will work too)
- full network connectivity between nodes

## My Setup

I automated most of the work as one can see in [kubernetes.tf](./kubernetes.tf). My two nodes come pre-booted with all the requirements met to bootstrap the cluster. Note though that I'm doing everything on the public network and have a firewall for each node.

### Bootstrap

Spying on the requirements of the course I use the following init-config:

```bash
cat > config.yaml <<EOF
---
apiVersion: kubeadm.k8s.io/v1beta3
kind: ClusterConfiguration
networking:
  podSubnet: 10.32.0.0/12  # only set if using weave net as cilium uses it's own management of IPs
---
apiVersion: kubelet.config.k8s.io/v1beta1
kind: KubeletConfiguration
cgroupDriver: systemd # must match the value you set for containerd
EOF
sudo kubeadm init --upload-certs --config config.yaml
```

Note: I'm using containerd using systemd cgroups. I don't see any reason for using docker

### Weave Net

Prerequisite: weave net requires tcp 6783 & udp 6783/6784 node-to-node connectivity

Then it is installed like so:

```bash
kubectl apply -f https://github.com/weaveworks/weave/releases/latest/download/weave-daemonset-k8s.yaml
```

See [their docs](https://www.weave.works/docs/net/latest/kubernetes/kube-addon/) for more informations and config options.

### Cilium

Another option is to use cilium for network traffic:

```bash
helm repo add cilium https://helm.cilium.io/
helm upgrade -i cilium cilium/cilium -n kube-system -f cilium-values.yaml
```

Note: cilium runs with all network traffic blocked by default, what did you expect from a CKS course?

First challenge: allow global DNS and kube-system egress access ;)

### Kubectl completion & alias

No one wants to live without them but cloud-init couldn't configure this (since running as root):

```bash
echo 'source <(kubectl completion bash)' >>~/.bashrc
echo 'alias k=kubectl' >>~/.bashrc
echo 'complete -o default -F __start_kubectl k' >>~/.bashrc
```

## Additional Infra Apps

Some apps you just want to have configured.

### Metrics server

Requires <https://kubernetes.io/docs/tasks/administer-cluster/kubeadm/kubeadm-certs/#kubelet-serving-certs> and can then be applied as usual.

### hcloud-cm

```bash
kubectl -n kube-system create secret generic hcloud --from-literal=token=<hcloud API token>
kubectl apply -f  https://github.com/hetznercloud/hcloud-cloud-controller-manager/releases/latest/download/ccm.yaml
```

Note: requires that the nodes were initialized with `--cloud-provider=external` (should be the default with my terraform module).

### cert-manager

Apply like so:

```bash
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/latest/download/cert-manager.yaml
```

Issuers are applied where necessary.
