module "kubernetes" {
  source = "./module"

  cluster_name = "cks_gugus"
  region       = "eu-central"

  default_ssh_keys      = ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJov21J2pGxwKIhTNPHjEkDy90U8VJBMiAodc2svmnFC cardno:18 187 880", "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPAHV3w+HTzKxEtyy0MboVa2rROkwwcQ6Q0lPcksI0xE ephemeral workspace key"]
  default_ssh_port      = 59245
  default_ssh_user      = "technat"
  enable_server_backups = false
  ip_mode               = "ipv4"
  bootstrap_nodes       = true

  additional_fw_rules_master = [
    {
      direction         = "in"
      protocol          = "tcp"
      port              = "4240"
      inject_master_ips = true
      inject_worker_ips = true
      source_ips        = []
      description       = "cilium health checks"
    },
    {
      direction         = "in"
      protocol          = "udp"
      port              = "8472"
      inject_master_ips = true
      inject_worker_ips = true
      source_ips        = []
      description       = "cilium vxlan overlay"
    },
    {
      direction         = "in"
      protocol          = "udp"
      port              = "6081"
      inject_master_ips = true
      inject_worker_ips = true
      source_ips        = []
      description       = "cilium geneve overlay"
    },
    {
      direction         = "in"
      protocol          = "tcp"
      port              = "4244"
      inject_master_ips = true
      inject_worker_ips = true
      source_ips        = []
      description       = "cilium hubble server"
    },
    {
      direction         = "in"
      protocol          = "tcp"
      port              = "4245"
      inject_master_ips = true
      inject_worker_ips = true
      source_ips        = []
      description       = "cilium hubble relay"
    },
    {
      direction         = "in"
      protocol          = "udp"
      port              = "51871"
      inject_master_ips = true
      inject_worker_ips = true
      source_ips        = []
      description       = "cilium wireguard traffic"
    },
  ]

  additional_fw_rules_worker = [
    {
      direction         = "in"
      protocol          = "tcp"
      port              = "4240"
      inject_master_ips = true
      inject_worker_ips = true
      source_ips        = []
      description       = "cilium health checks"
    },
    {
      direction         = "in"
      protocol          = "udp"
      port              = "8472"
      inject_master_ips = true
      inject_worker_ips = true
      source_ips        = []
      description       = "cilium vxlan overlay"
    },
    {
      direction         = "in"
      protocol          = "udp"
      port              = "6081"
      inject_master_ips = true
      inject_worker_ips = true
      source_ips        = []
      description       = "cilium geneve overlay"
    },
    {
      direction         = "in"
      protocol          = "tcp"
      port              = "4244"
      inject_master_ips = true
      inject_worker_ips = true
      source_ips        = []
      description       = "cilium hubble server"
    },
    {
      direction         = "in"
      protocol          = "tcp"
      port              = "4245"
      inject_master_ips = true
      inject_worker_ips = true
      source_ips        = []
      description       = "cilium hubble relay"
    },
    {
      direction         = "in"
      protocol          = "udp"
      port              = "51871"
      inject_master_ips = true
      inject_worker_ips = true
      source_ips        = []
      description       = "cilium wireguard traffic"
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
