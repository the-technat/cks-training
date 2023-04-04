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
#networking:
#  podSubnet: 10.32.0.0/12  # only set if using weave net as cilium uses it's own management of IPs
---
apiVersion: kubelet.config.k8s.io/v1beta1
kind: KubeletConfiguration
cgroupDriver: systemd # must match the value you set for containerd
serverTLSBootstrap: true
EOF
sudo kubeadm init --upload-certs --config config.yaml
```

**Important: approve the node CSRs before you continue**

### Option 1 - Cilium

My all-time favourite CNI:

```bash
helm repo add cilium https://helm.cilium.io/
helm upgrade -i cilium cilium/cilium -n kube-system -f cilium-values.yaml
```

Note: cilium runs with all network traffic blocked by default, what did you expect from a CKS course?

First challenge: allow global DNS and kube-system egress access ;)

In the [networking section](../03_networking/README.md) there is a closer look at different CNI plugins.

<details>

<summary>Option 2 - Weave Net</summary>

### Weave Net

Other CNI option commonly see in CKS courses.

Prerequisite: weave net requires tcp 6783 & udp 6783/6784 node-to-node connectivity -> must be changed (currently Terraform configures rules for cilium)

```bash
kubectl apply -f https://github.com/weaveworks/weave/releases/latest/download/weave-daemonset-k8s.yaml
```

See [their docs](https://www.weave.works/docs/net/latest/kubernetes/kube-addon/) for more informations and config options.

</details>

### Kubectl completion & alias

No one wants to live without them but cloud-init couldn't configure this (since running as root):

```bash
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
echo 'source <(kubectl completion bash)' >>~/.bashrc
echo 'alias k=kubectl' >>~/.bashrc
echo 'complete -o default -F __start_kubectl k' >>~/.bashrc
```

## Additional Infra Apps

Some apps you just want to have configured.

### hcloud-ccm

```bash
kubectl -n kube-system create secret generic hcloud --from-literal=token=<hcloud API token>
kubectl apply -f  https://github.com/hetznercloud/hcloud-cloud-controller-manager/releases/latest/download/ccm.yaml -n kube-system
```

Requires <https://kubernetes.io/docs/tasks/administer-cluster/kubeadm/kubeadm-certs/#kubelet-serving-certs>, but you only have to approve the CSR, the rest is done

### hetzner-csi

Uses the same token in the kube-system namespace as the hcloud-ccm

```bash
kubectl apply -f https://raw.githubusercontent.com/hetznercloud/csi-driver/main/deploy/kubernetes/hcloud-csi.yml -n kube-system
```

### Metrics server

```bash
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
```

Requires <https://kubernetes.io/docs/tasks/administer-cluster/kubeadm/kubeadm-certs/#kubelet-serving-certs>, but should already be done during installation.
