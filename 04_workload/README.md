# Workload Considerations

## Image Scanning

The best tool I've found is `trivy`. When installed as an operator you can scan images in the background and create reports in CRDs.

So get the operator:

```bash
helm repo add aqua https://aquasecurity.github.io/helm-charts/
helm install trivy-operator aqua/trivy-operator \
  --namespace trivy-system \
  --create-namespace \
  --set="trivy.ignoreUnfixed=true" 
```

## Kyverno

To enforce what the trivy operator shows in it's `ConfigAuditReports` a policy-engine like kyverno comes in handy:

```bash
helm repo add kyverno https://kyverno.github.io/kyverno/
helm upgrade -i \
 kyverno kyverno/kyverno \
 -n kyverno  \
 --create-namespace \
 --set replicaCount=1 \
 --set extraArgs='{"--backgroundScan=true", "--loggingFormat=text"}'
```

And then get a good ruleset from here:

```bash
helm upgrade -i \
  kyverno-policies kyverno/kyverno-policies \
  -n kyverno \
  --set podSecurityStandard=restricted \
  --set validationFailureAction=audit 
```

## Tracee

Really simple dynamic code analysis tool:

```bash
k apply -f <https://raw.githubusercontent.com/aquasecurity/tracee/main/deploy/kubernetes/tracee/tracee.yaml>
```

## SecurityContext

Those are the best-practices I learned for writing Dockerfiles and YAML:

- all binaries should be owned by root:root with 755 (so that any user can execute them)
- all app data that comes packaged with the container should also be owned by root:root with 755, it's a bad habit to chown them to a specific app user that has acess as this user could change
- write data to a specific or better configurable tmp dir, k8s or the csi driver will ensure the pod is allowed to write there
- if you really need to specify the user, use a UID and not a name

In K8s:

- prevent privilegeEscalation
- set the runAsUser, runAsGroup and fsGroup to random numbers (best would be above 10000 to not clash with the host) -> OSE sets them randomly using a controller
- drop all caps
- runAsNonRoot
- enforce the read-only mount of the filesystem
- use Seccomop profile RuntimeDefault to avoid any ambicous system calls
- use AppArmor profile runtime/default to avoid any other ambitous actions on the host or create your own AppArmor profiles for more security

One last thing: if more than half of the container images out there would follow [this best-practice guide](https://sysdig.com/blog/dockerfile-best-practices/) the container world would be much more secure.

## RuntimeClass

First configure containerd to support multiple container runtimes: <https://github.com/containerd/containerd/blob/main/docs/cri/config.md>

Then apply the `runtimeclasses.yaml`:

```yaml
apiVersion: node.k9s.io/v1
kind: RuntimeClass
metadata:
  name: crun
handler: crun
---
apiVersion: node.k8s.io/v1
kind: RuntimeClass
metadata:
  name: gvisor
handler: gvisor
---
apiVersion: node.k8s.io/v1
kind: RuntimeClass
metadata:
  name: kata
handler: kata
```

And of course install the other container runtime. This depends from project to project.

## AppArmor

Used to create profils that restrict access to files/privileges and more for a process.

## Seccomp

Profile to define what syscalls are allowed and which ones not.

## Falco

Runtime security tool, your big brother watching over you and seeing everything you do.

### Installation

Following [this guide](https://falco.org/docs/getting-started/try-falco/try-falcosidekick-on-kubernetes/), I just install the helm chart:

```bash
helm repo add falcosecurity https://falcosecurity.github.io/charts
helm upgrade -i falco falcosecurity/falco --create-namespace -n falco -f falco-values.yaml
```

### K8s Audit Logs

To get audit-logs from the kube-apiserver, see the [kube-apiserver-hardening](../01_kube-apiserver-hardening/README.md) section. Here just some hints:

- use at least Metadata for all resources
- set `--audit-log-path=-`
- set `--audit-webhook-config-file=/myfile.yaml` with content:

  ```yaml
  apiVersion: v1
  kind: Config
  clusters:
  - name: falco
    cluster:
      # certificate-authority: /path/to/ca.crt # for https
      server: <http://localhost:30007/k8s-audit>
  contexts:
  - context:
      cluster: falco
      user: ""
    name: default-context
  current-context: default-context
  preferences: {}
  users: []
  ```

- the rest is configured throuth the helm chart (e.g enabling the plugin, listening on the hostport...)

### Custom Rules

Here's a custom rule in helm values format:

```yaml
customRules:
  banana_rules.yaml: |-
    - rule: alleaffengaffen app
      desc: very dangerous app
      condition: >
        container.id != host and
        container.image contains "alleaffengaffen"
      output: A new alleaffengaffen app has spawned! (container=%container.name)
      priority: NOTICE
```
