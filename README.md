# cks_training

Resources related to my CKS training

## Lab Env

See [lab_env](./lab_env) for how to setup.

## Awesome CKS Software

Probably already known but here again, a [Vulnerability Database](https://nvd.nist.gov/vuln/search).

See the [Awesome CKS Tools list](https://github.com/stars/the-technat/lists/awesome-cks-tools) for some cool security tools.

## Open Topics for learning

- Difference of containerd & CRI-O
- falco
  - propery deployment
  - rules
    - location
    - custom rules
- [Verify binaries using their SHA256 checksum (by hard)](https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/)
- Run the kube-bench job
- [How to write netpols that deny things?](https://kubernetes.io/docs/tasks/administer-cluster/securing-a-cluster/#restricting-cloud-metadata-api-access)
- Write a TLS section of an ingress (by hard)
- [Upgrade your cluster](https://kubernetes.io/docs/tasks/administer-cluster/cluster-upgrade/)
- Linux basics: locally running services / open ports / connections (e.g netstat and tcpdump master)
- [Create a custom AppArmor profile for a pod](https://kubernetes.io/docs/tutorials/security/apparmor/) -> [Docs](https://gitlab.com/apparmor/apparmor/-/wikis/Documentation)
- [Creat a custom seccomp profile for a pod](https://kubernetes.io/docs/tutorials/security/seccomp/)
- [Write and understand the least-privilege securityContext for a pod](https://kubernetes.io/docs/tasks/configure-pod-container/security-context/)
- [Use RuntimeClass and another container runtime](https://kubernetes.io/docs/concepts/containers/runtime-class/)
- [Pod Security Standards](https://kubernetes.io/docs/concepts/security/pod-security-standards)
- [Deep-dive into AdmissionControllers](https://kubernetes.io/docs/reference/access-authn-authz/admission-controllers)
- [Trivy Operator to scan images](https://github.com/aquasecurity/trivy-operator)
- [Configure Audit Logging](https://kubernetes.io/docs/tasks/debug/debug-cluster/audit/)

One last thing: if more than half of the container images out there would follow [this best-practice guide](https://sysdig.com/blog/dockerfile-best-practices/) the world would be much easier.
