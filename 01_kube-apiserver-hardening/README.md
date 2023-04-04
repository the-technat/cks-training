# Hardening the kube-apiserver

## Using an OIDC provider to authenticate users

Problem: client-certificates are secure but extremely dangerous since everyone that has acess to my local unprotected file could access the K8s cluster as admin.

Solution: leave the admin kubeconfig on the master node itself and don't copy it everywhere. Configure the kube-apiserver as OIDC client for an IDP and authenticate your users throuth the IDP generating tokens that can be used as valid Bearer tokens to authenticate against the kube-apiserver.

This behaviour is documented [here](https://kubernetes.io/docs/reference/access-authn-authz/authentication/#openid-connect-tokens).

I'm going to configure this here using a in-kubernetes running dex as IDP that uses Github as it's IDP in the back. This has the advantage that you can configure multiple K8s apps using CRDs to use Dex as it's IDP and only use one-time config on github's side.

My doc is based on this [this](https://dexidp.io/docs/kubernetes/).

### Step 1: Prerequisites

We are running dex on K8s. You need:

- a Cloud Controller Manager for HCLOUD
- cert-manager using a ClusterIssuer
- ingress-nginx to expose dex

See either the [lab_env](../00_lab_env/README.md) or the [networking](../03_networking/README.md) section for instructions on how to install those tools.

### Step 2: Install Dex

Since there is a lot of config required, we install dex using helm.

So first create a secret for Github oauth creds (register a new app [here](https://github.com/settings/applications/new)) and create some secrets:

```bash
kubectl create ns dex
kubectl -n dex create secret \
    generic github-client \
    --from-literal=client-id=$GITHUB_CLIENT_ID \
    --from-literal=client-secret=$GITHUB_CLIENT_SECRET
```

Then get dex:

```
helm repo add dex https://charts.dexidp.io
helm upgrade -i dex -n dex dex/dex -f dex-values.yaml
```

See the [dex-values.yaml](./dex-values.yaml) for my custom config.
Note: change the Issuer in the values file accordingly and also the secret for the static client.

### Step 3: Configure the kube-apiserver oidc connect token auth plugin

On the master node, edit the file `/etc/kubernetes/manifests/kube-apiserver.yaml` and add the following to the `command` field:

```yaml
command:
- kube-apiserver
- --oidc-issuer-url=https://dex.alleaffengaffen.ch
- --oidc-client-id=kubernetes
```

### Step 4: Configure your local kubeconfig

Now that the apiserver is configured and dex is configured, we need to configure our local kubectl. The problem to solve is that kubernetes doesn't have a web interface and we therefore need to authenticate to the IDP first.
But we can solve this using tools like [kubelogin](https://github.com/int128/kubelogin).

So start by getting kubelogin as a binary to your path. Name it `kubectl-oidc_login` so that it's recognized a a kubectl plugin.

Check with `kubectl oidc-login` and make sure that the help gets printed.

The rest of the setup can be generated for you if you run:

```bash
kubectl oidc-login setup \ 
  --oidc-issuer-url=https://dex.alleaffengaffen.ch \
  --oidc-client-id=kubernetes \
  --oidc-client-secret=KkEHL61EJtr8ssmnqfzh
```

Just follow the printed commands to add a clusterrolebinding and configure your kubeconfig.

## Audit Logging

First create an audit-policy:

```yaml
apiVersion: audit.k8s.io/v1
kind: Policy
rules:
- level: Metadata
```

Note: this will log a lot of lines and quickly generate megabytes of data.

The following command-line options are used to tell the api-server about this:

```yaml
commands:
- kube-apiserver
- --audit-log-maxage=7                                    #<-- Retain age in days
- --audit-log-maxbackup=2                                 #<-- Max number to retain
- --audit-log-maxsize=50                                  #<-- Meg size when to rotate
- --audit-log-path=/var/log/audit.log                     #<-- Where to log
- --audit-policy-file=/etc/kubernetes/audit-policy.yaml  #<-- Audit policy file
```

And then persist the log file to the host and mount the config in the pod:

```yaml
volumeMounts:
- mountPath: /etc/kubernetes/audit-policy.yaml  
  name: audit
  readOnly: true
- mountPath: /var/log/audit.log                  
  name: audit-log
  readOnly: false

volumes:
- hostPath:                                      
  path: /etc/kubernetes/audit-policy.yaml
  type: File
  name: audit
- hostPath:
  path: /var/log/audit.log
  type: FileOrCreate
  name: audit-log
```

## ETCD Encryption at rest

[Reference Docs](https://kubernetes.io/docs/tasks/administer-cluster/encrypt-data/)

### Option 1: static key saved on the master node

To encrypt your secrets (or other objects stored in etcd), write a config file like this one in `/etc/kubernetes/pki` (or somewhere else and mount it into the kube-apiserver):

```yaml
apiVersion: apiserver.config.k8s.io/v1
kind: EncryptionConfiguration
name: DefaultEncryption
resources:
  - resources:
    - secrets
    # - configmaps
    providers:
    - aescbc:
        keys:
        - name: firstkey
          secret: JJxfTo7NfUh+nLv+bHJuxcWdG2tHKwZlyqXT5JIytgs= # head -c 32 /dev/urandom | base64
    - identity: {}
```

And then tell the api-server where the encryption config can be found:

```yaml
commands:
- kube-apiserver
- --encryption-provider-config=/etc/kubernetes/pki/config.yaml
```

A restart later, new secrets will be encrypted. For existing secrets, you must recreate them. One way is bulk-recreate like so:

```bash
kubectl get secrets -A -o json | kubectl replace -f -
```

Why does this work? `providers` is a list. The latest entry is used to encrypt, but all can be used to decrypt. So as long as you have the provider `identity` (no encryption at all) or another key present in the list, reencryption works exactly like that.

### Option 2: using KMS

See <https://github.com/ondat/trousseau/wiki/Trousseau-Deployment> for an example using Hashicorp Vault.
