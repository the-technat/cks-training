module "kubernetes" {
  source = "git::https://github.com/alleaffengaffen/terraform-hcloud-kubernetes.git?ref=master"

  cluster_name = "cks_gugus"
  region       = "eu-central"

  default_ssh_keys      = ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJov21J2pGxwKIhTNPHjEkDy90U8VJBMiAodc2svmnFC cardno:18 187 880", "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFsg76nv5vl7zZpOVNJq8zPZa56KRMFNMsXoP6OZvi/c ephemeral workspace key"]
  default_ssh_port      = 59245
  default_ssh_user      = "technat"
  enable_server_backups = false
  ip_mode               = "ipv4"
  bootstrap_nodes       = true

  additional_fw_rules_master = [
    {
      direction         = "in"
      protocol          = "tcp"
      port              = "179"
      inject_master_ips = true
      inject_worker_ips = true
      source_ips        = []
      description       = "calico networking (bgp)"
    },
    {
      direction         = "in"
      protocol          = "udp"
      port              = "4789"
      inject_master_ips = true
      inject_worker_ips = true
      source_ips        = []
      description       = "calico networking (vxlan)"
    },
    {
      direction         = "in"
      protocol          = "tcp"
      port              = "5473"
      inject_master_ips = true
      inject_worker_ips = true
      source_ips        = []
      description       = "calico networking (typha)"
    },
    {
      direction         = "in"
      protocol          = "udp"
      port              = "51820"
      inject_master_ips = true
      inject_worker_ips = true
      source_ips        = []
      description       = "calico networking (wireguard)"
    },
  ]

  additional_fw_rules_worker = [
    {
      direction         = "in"
      protocol          = "tcp"
      port              = "179"
      inject_master_ips = true
      inject_worker_ips = true
      source_ips        = []
      description       = "calico networking (bgp)"
    },
    {
      direction         = "in"
      protocol          = "udp"
      port              = "4789"
      inject_master_ips = true
      inject_worker_ips = true
      source_ips        = []
      description       = "calico networking (vxlan)"
    },
    {
      direction         = "in"
      protocol          = "tcp"
      port              = "5473"
      inject_master_ips = true
      inject_worker_ips = true
      source_ips        = []
      description       = "calico networking (typha)"
    },
    {
      direction         = "in"
      protocol          = "udp"
      port              = "51820"
      inject_master_ips = true
      inject_worker_ips = true
      source_ips        = []
      description       = "calico networking (wireguard)"
    },
  ]

  master_nodes = [
    {
      name        = "hawk"
      server_type = "cpx11"
      image       = "ubuntu-22.04"
      location    = "fsn1"
      labels      = {}
      volumes     = []
    }
  ]

  worker_nodes = [
    {
      name        = "minion-0"
      server_type = "cpx11"
      image       = "ubuntu-22.04"
      location    = "fsn1"
      labels      = {}
      volumes     = []
    },
  ]

}
