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
kubectl apply -k kyverno_policies
```

The ruleset will do the following:

- All pods no matter what source they are get a securityContext that is as restrictive as it can be
- If an app needs to override one of the securityContext values (e.g because it needs more privileges than nothing to work), an exception for this specific line of the securityContext can be made

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

Then apply the `runtimeclasses.yaml`

And of course install the other container runtime. This depends from project to project.

## AppArmor

Used to create profils that restrict access to files/privileges and more for a process.

## Seccomp

Profile to define what syscalls are allowed and which ones not.

## Falco

Runtime security tool, your big brother watching over you and seeing everything you do.

### Installation

Not that easy, but since we practice for the CKS, we use the most obvious installation method which is done directly on the host.

Use these commands:

```bash
curl -s https://falco.org/repo/falcosecurity-packages.asc | sudo apt-key add -
echo "deb https://download.falco.org/packages/deb stable main" | sudo tee -a /etc/apt/sources.list.d/falcosecurity.list
sudo apt-get update -y
FALCO_FRONTEND=noninteractive sudo apt-get install -y falco
sudo systemctl enable --now falco-modern-bpf.service
```

Upstream docs: <https://falco.org/docs/getting-started/installation/>
