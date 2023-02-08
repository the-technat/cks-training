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
kubectl apply -k policies
```

The ruleset will do the following:

- All pods no matter what source they are get a securityContext that is as restrictive as it can be
- If an app needs to override one of the securityContext values (e.g because it needs more privileges than nothing to work), an exception for this specific line of the securityContext can be made

## Tracee

Really simple dynamic code analysis tool:

```bash
k apply -f <https://raw.githubusercontent.com/aquasecurity/tracee/main/deploy/kubernetes/tracee/tracee.yaml>
```

## Falco

Let's deploy falco on our hosts to do dynamic code analysis.

```bash
helm repo add falcosecurity https://falcosecurity.github.io/charts
helm upgrade -i falco falcosecurity/falco --namespace falco --create-namespace
```

## AppArmor

## Seccomp
