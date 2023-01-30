# cks_training

Resources related to my CKS training

## Lab Env

See [lab_env](./lab_env) for how to setup.

## Awesome CKS Software

Probably already known but here again, a [Vulnerability Database](https://nvd.nist.gov/vuln/search).

### Runtime

- [Kata](https://katacontainers.io/): Drop-In container engine that uses lightweigth VMs instead of traditional containers for more isolation
- [gVisor](https://gvisor.dev/): Same as kata but from Google

### Container Isolation

Basically any CNI that implements `NetworkPolicy`, e.g:

- [Cilium](https://cilium.io)
- [Weave Net](https://github.com/weaveworks/weave)

### Scanning

- [Trivy Operator](https://github.com/aquasecurity/trivy-operator): Magic operator that can do all sorts of scanning about images, resources, integrates into OPA
