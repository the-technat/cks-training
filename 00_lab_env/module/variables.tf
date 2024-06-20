#----------------
# General Vars
#----------------
variable "common_labels" {
  type        = map(string)
  default     = {}
  description = "Common map of labels to add on all resources"
}

variable "cluster_name" {
  type        = string
  description = "A cluster-name that is used to suffix every resource name"
}

variable "region" {
  type        = string
  description = "In which region should your cluster be?"
  validation {
    condition     = can(regex("(eu-central|us-east)", var.region))
    error_message = "The region must be one of the following values: [eu-central, us-east]."
  }
}

variable "ssh_source_ips" {
  type        = list(string)
  default     = ["0.0.0.0/0", "::/0"]
  description = "Limit the ips that are allowed to ssh into our cluster nodes."
}

#----------------
# Toggle Vars
# Switch things on and off
#----------------
variable "enable_server_backups" {
  type        = bool
  default     = false
  description = "Whether to enable server backups in hcloud."
}

variable "enable_floating_kubeapi" {
  type        = bool
  default     = false
  description = "Whether a floating public IP for the kubeapi should be provisioned or not"
}

variable "ip_mode" {
  type        = string
  default     = "ipv6"
  description = "All in on IPv4 or IPv6?"
  validation {
    condition     = can(regex("(ipv4|ipv6)", var.ip_mode))
    error_message = "The ip_mode must either by 'ipv4' or 'ipv6'."
  }
}

variable "enable_private_networking" {
  type        = bool
  default     = false
  description = "Whether to deploy a private network or not"
}

variable "bootstrap_nodes" {
  type        = bool
  default     = false
  description = "Whether cloud-init should install all required tools on the nodes or not"
}

variable "install_falco" {
  type        = bool
  default     = false
  description = "Whether falco should be installed on the hosts"
}

#----------------
# SSH vars (default)
#----------------
variable "default_ssh_port" {
  type        = number
  default     = 22
  description = "The default SSH Port configured and rechable on each machine"
}

variable "default_ssh_user" {
  type        = string
  default     = "ansible"
  description = "Username of a default admin user created on every machine"
}

variable "default_ssh_keys" {
  type        = list(string)
  description = "List of default (public) ssh keys to configure on the ssh_user"
}

#----------------
# Control Plane vars
#----------------
variable "master_nodes" {
  type = list(object({
    name        = string
    server_type = string
    image       = string
    labels      = map(string)
    location    = string
    volumes = list(object({
      name    = string
      size_gb = number
    }))
  }))
  description = "List of master nodes to provision in the cluster, each master node has a set of values you can configure"
  default = [
    {
      name        = "master-0"
      server_type = "cpx11"
      image       = "ubuntu-22.04"
      labels      = {}
      location    = "hel1"
      volumes     = []
    }
  ]
}

variable "kubeapi_source_ips" {
  type        = list(string)
  default     = ["0.0.0.0/0", "::/0"]
  description = "Limit the ips that are allowed to talk to our kubeapi. (Worker-nodes will always be allowed)"
}

variable "additional_fw_rules_master" {
  type = list(object({
    direction         = string
    protocol          = string
    port              = string
    inject_master_ips = bool
    inject_worker_ips = bool
    source_ips        = list(string)
    description       = string
  }))
  default     = []
  description = "Additional rules for master nodes"
}

#----------------
# Data Plane vars
#----------------
variable "worker_nodes" {
  type = list(object({
    name        = string
    server_type = string
    image       = string
    labels      = map(string)
    location    = string
    volumes = list(object({
      name    = string
      size_gb = number
    }))
  }))
  description = "List of worker nodes to provision in the cluster, each master node has a set of values you can configure"
  default = [
    {
      name        = "worker-0"
      server_type = "cpx31"
      image       = "ubuntu-22.04"
      labels      = {}
      location    = "nbg1"
      volumes     = []
    }
  ]
}

variable "nodeport_source_ips" {
  type        = list(string)
  default     = ["0.0.0.0/0", "::/0"]
  description = "Who is allowed to connect to your nodeport services (e.g only a LoadBalancer...)"
}

variable "additional_fw_rules_worker" {
  type = list(object({
    direction         = string
    protocol          = string
    port              = string
    inject_master_ips = bool
    inject_worker_ips = bool
    source_ips        = list(string)
    description       = string
  }))
  default     = []
  description = "Additional rules for worker nodes"
}
