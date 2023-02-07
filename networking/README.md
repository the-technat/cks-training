# Networking

## Calico

Prerequisite: requires tcp/179, udp/4789 and ipip node-to-node connectivity (see [here](https://projectcalico.docs.tigera.io/getting-started/kubernetes/requirements#network-requirements))

Then install it like so:

```bash
helm repo add projectcalico https://projectcalico.docs.tigera.io/charts
helm upgrade -i calico projectcalico/tigera-operator --create-namespace -n tigera-operator 
```

Note: it requires some configuration since public-net on hcloud doesn't support BGP.

Set the following fields in the `Installation`:

```yaml
spec:
  calicoNetwork:
    bgp: Disabled
    ipPools:
    - cidr: 10.32.0.0/12
      encapsulation: VXLAN
```

And in the `IPPool` you need the following:

```yaml
spec:
  vxlanMode: Always
```

### Wireguard Encryption

Can be enabled with this command:

```bash
kubectl patch felixconfiguration default --type='merge' -p '{"spec":{"wireguardEnabled":true}}'
```

Now all traffic between pods is encrypted using wireguard. In addition all traffic between control-plane components is encrypted too (PKI) so what's left? Maybe CNI coordination traffic?

[Reference Docs](https://projectcalico.docs.tigera.io/security/encrypt-cluster-pod-traffic)

## Ingress Controller

We are installing contour for this:

```bash
helm repo add bitnami https://charts.bitnami.com/bitnami
helm install my-release bitnami/contour --namespace projectcontour --create-namespace
kubectl patch -n ingress-nginx svc ingress-nginx-controller  --type='json' -p='[{"op": "add", "path": "/metadata/annotations", "value":{"load-balancer.hetzner.cloud/network-zone":"eu-central"}}]' 
```

A dummy app is always a good idea:

```bash
kubectl apply -f <https://projectcontour.io/examples/httpbin.yaml>
kubectl patch ingress httpbin -p '{"spec":{"ingressClassName": "contour"}}'
```

## Service Mesh
