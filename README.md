# cks_training

Resources related to my CKS training

## Lab Env

See [lab_env](./lab_env) for how to setup.

## Awesome CKS Software

Probably already known but here again, a [Vulnerability Database](https://nvd.nist.gov/vuln/search).

See the [Awesome CKS Tools list](https://github.com/stars/the-technat/lists/awesome-cks-tools) for some cool security tools.

## Open Topics for learning

- [Falco](https://falco.org/docs/)
  - correct deployment (mind the different methods, understand how it could be installed)
  - understand and write rules
    - location
    - custom rules
- [x] [Create a custom AppArmor profile for a pod](https://kubernetes.io/docs/tutorials/security/apparmor/) -> [Docs](https://gitlab.com/apparmor/apparmor/-/wikis/Documentation)
- [x] [Creat a custom seccomp profile for a pod](https://kubernetes.io/docs/tutorials/security/seccomp/)
- [x] [Deep-dive into AdmissionControllers](https://kubernetes.io/docs/reference/access-authn-authz/admission-controllers)
- [x] [Use RuntimeClass and another container runtime](https://kubernetes.io/docs/concepts/containers/runtime-class/)
- [x] [Trivy Operator to scan images](https://github.com/aquasecurity/trivy-operator)
- [x] [Configure Audit Logging](https://kubernetes.io/docs/tasks/debug/debug-cluster/audit/)
- [x] [Upgrade your cluster](https://kubernetes.io/docs/tasks/administer-cluster/cluster-upgrade/)
- [x] [Write a TLS section of an ingress (by hard)](https://kubernetes.io/docs/concepts/services-networking/ingress/#tls)
- [x] [Linux basics: locally running services / open ports / connections (e.g netstat and tcpdump master)](https://www.redhat.com/sysadmin/beginners-guide-network-troubleshooting-linux)
- [x] [Verify binaries using their SHA256 checksum (by hard)](https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/)
- [x] [Run the kube-bench job](https://github.com/aquasecurity/kube-bench)
- [x] [How to write netpols that deny things?](https://kubernetes.io/docs/tasks/administer-cluster/securing-a-cluster/#restricting-cloud-metadata-api-access)
- [x] [Write and understand the least-privilege securityContext for a pod](https://kubernetes.io/docs/tasks/configure-pod-container/security-context/)
- [x] [Pod Security Standards](https://kubernetes.io/docs/concepts/security/pod-security-standards)

## Fazit of the CKS

> Docker and Kubernetes massively transformed the way how software is packaged, shipped and run. But with one major drawback: They ignored security completely in order to gain speed and become adopted faster. So the biggest challenge in containeraized environments today, is to make them secure. By secure I don't mean any rocket sience that no one understands, just follow [some basic best-practices](https://sysdig.com/blog/dockerfile-best-practices/) when packaging container images and most of the work is done.
