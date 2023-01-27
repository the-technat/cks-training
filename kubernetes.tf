module "kubernetes" {
  source = "git::https://github.com/alleaffengaffen/terraform-hcloud-kubernetes.git?ref=master"

  cluster_name = "cks_gugus"
  region       = "eu-central"

  cluster_vpc_cidr      = "10.0.0.0/12"
  cluster_subnet_cidr   = "10.1.0.0/16"
  default_ssh_keys      = ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICMtnizXrvJRuzTWdMB7yqeH+6g35TZwCgkj6ThaUKMb ansible@example.com", "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIK2VGZkovATxoMI4f2g24/Ca0/9fuZETHNCNbGbKxwsS technat@technat.ch"]
  default_ssh_port      = 59245
  default_ssh_user      = "technat"
  enable_server_backups = false
  ip_mode               = "ipv4"
  bootstrap_nodes       = true

  ### Control Plane ###
  master_nodes = [
    {
      name        = "hawk"
      server_type = "cpx11"
      image       = "ubuntu-22.04"
      labels      = {}
      location    = "hel1"
      volumes     = []
      ssh_user    = ""
      ssh_keys    = []
      ssh_port    = 0
    }
  ]

  ### Compute Plane ###
  worker_nodes = [
    {
      name        = "minion-0"
      server_type = "cx11"
      image       = "ubuntu-22.04"
      labels      = {}
      location    = "hel1"
      volumes     = []
      ssh_user    = ""
      ssh_keys    = []
      ssh_port    = 0
    }
  ]

}
