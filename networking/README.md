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
helm upgrade -i contour bitnami/contour --namespace projectcontour --create-namespace -f contour-values.yaml
kubectl apply -f clusterissuer-le-contour.yaml clusterissuer-le-staging-contour.yaml
```

A dummy app is always a good idea:

```bash
kubectl apply -f httpproxy_example.yaml
```

The app uses a `HTTPProxy` by default and of course deployes THE only alleaffengaffen app ;)

For more details take a look at the [contour docs](https://projectcontour.io/docs/v1.24.0/architecture/).

## Service Mesh

We are going to install linkerd here.

First we get the local cli:

```bash
curl --proto '=https' --tlsv1.2 -sSfL https://run.linkerd.io/install | sh
echo 'export PATH=$PATH:/home/codespace/.linkerd2/bin' | tee -a ~/.bashrc
```

Then run a check to see if our cluster is ready for linkerd:

```bash
linkerd check --pre
```

Now generate a new CA and cert-manager issuer to manage mTLS certs properly: <https://linkerd.io/2.12/tasks/automatically-rotating-control-plane-tls-credentials/>

If this is done, we can preceed installing linkerd:

```bash
helm repo add linkerd https://helm.linkerd.io
helm upgrade -i  linkerd-crds linkerd/linkerd-crds \
  -n linkerd --create-namespace 
helm upgrade -i linkerd-control-plane \
  -n linkerd \
  --set-file identityTrustAnchorsPEM=ca.crt \
  --set identity.issuer.scheme=kubernetes.io/tls \
  linkerd/linkerd-control-plane 
helm upgrade -i linkerd-viz \
  -n linkerd \
  linkerd/linkerd-viz
```

And check if it has been installed correctly:

```bash
linkerd check
```

Then expose the dashboard of linkerd:

```bash
kubectl apply -f - <<EOF
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  annotations:
    cert-manager.io/cluster-issuer: letsencrypt-prod-contour
    ingress.kubernetes.io/force-ssl-redirect: "true"
    projectcontour.io/websocket-routes: /
  labels:
    app.kubernetes.io/name: linkerd-viz
  name: linkerd-dashboard
  namespace: linkerd
spec:
  ingressClassName: contour
  rules:
  - host: linkerd.alleaffengaffen.ch
    http:
      paths:
      - backend:
          service:
            name: web
            port:
              number: 8084
        path: /
        pathType: Prefix
  tls:
  - hosts:
    - linkerd.alleaffengaffen.ch
    secretName: linkerd-viz-tls
EOF
```

Don't forget to tweak the host requirement: <https://linkerd.io/2.12/tasks/exposing-dashboard/#tweaking-host-requirement>

### Demo app emojivoto

See <https://linkerd.io/2.12/getting-started/#step-4-install-the-demo-app>

Don't forget to expose the app ;)

```bash
kubectl apply -f - <<EOF
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  annotations:
    cert-manager.io/cluster-issuer: letsencrypt-prod-contour
    ingress.kubernetes.io/force-ssl-redirect: "true"
  name: emojivoto
  namespace: emojivoto
spec:
  ingressClassName: contour
  rules:
  - host: emoji.alleaffengaffen.ch
    http:
      paths:
      - backend:
          service:
            name: web-svc
            port:
              number: 80
        path: /
        pathType: Prefix
  tls:
  - hosts:
    - emoji.alleaffengaffen.ch
    secretName: emoji-tls
EOF
```
