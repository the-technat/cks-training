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
      port              = "6783"
      inject_master_ips = true
      inject_worker_ips = true
      source_ips        = []
      description       = "weave net"
    },
    {
      direction         = "in"
      protocol          = "udp"
      port              = "6783-6784"
      inject_master_ips = true
      inject_worker_ips = true
      source_ips        = []
      description       = "weave net"
    },
  ]

  additional_fw_rules_worker = [
    {
      direction         = "in"
      protocol          = "tcp"
      port              = "6783"
      inject_master_ips = true
      inject_worker_ips = true
      source_ips        = []
      description       = "weave net"
    },
    {
      direction         = "in"
      protocol          = "udp"
      port              = "6783-6784"
      inject_master_ips = true
      inject_worker_ips = true
      source_ips        = []
      description       = "weave net"
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
    }
  ]

}
