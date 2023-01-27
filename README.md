# cks_training

Resources related to my CKS training

## Lab Env

See the [kubernetes.tf](./kubernetes.tf)

## Useful link

- [Vulnerability Database](https://nvd.nist.gov/vuln/search)

## Weave Works

Note: requires tcp 6783 & udp 6783/6784 node-to-node connectivity

Init the cluster like so:

```bash
cat > config.yaml <<EOF
---
apiVersion: kubeadm.k8s.io/v1beta3
kind: ClusterConfiguration
networking:
  podSubnet: 10.32.0.0/12 # Default of weave works
---
apiVersion: kubelet.config.k8s.io/v1beta1
kind: KubeletConfiguration
cgroupDriver: systemd # must match the value you set for containerd
EOF
sudo kubeadm init --upload-certs --config config.yaml
```

And then install weave works directly from the latest YAML:

```bash
kubectl apply -f https://github.com/weaveworks/weave/releases/download/v2.8.1/weave-daemonset-k8s.yaml
```

See [their docs](https://www.weave.works/docs/net/latest/kubernetes/kube-addon/) for more informations and config options.

## Kubectl completion & alias

```bash
echo 'source <(kubectl completion bash)' >>~/.bashrc
echo 'alias k=kubectl' >>~/.bashrc
echo 'complete -o default -F __start_kubectl k' >>~/.bashrc
```
