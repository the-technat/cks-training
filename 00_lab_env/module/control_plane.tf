#----------------
# Networking
#----------------
resource "hcloud_floating_ip" "kubeapi" {
  count         = var.enable_floating_kubeapi == true ? 1 : 0
  type          = var.ip_mode
  home_location = var.master_nodes[0].location
  name          = "kubeapi-${var.cluster_name}"
  description   = "kubeapi IP for ${var.cluster_name} cluster"
  labels = merge({
    "managed-by"   = "terraform"
    "cluster-name" = var.cluster_name
  }, var.common_labels)
}

resource "hcloud_floating_ip_assignment" "main" {
  count          = var.enable_floating_kubeapi == true ? 1 : 0
  floating_ip_id = hcloud_floating_ip.kubeapi[0].id
  server_id      = hcloud_server.master[0].id
}

resource "hcloud_firewall" "control_plane" {
  count = length(var.master_nodes)

  name = var.master_nodes[count.index].name
  labels = merge({
    "managed-by"   = "terraform"
    "cluster-name" = var.cluster_name
  }, var.common_labels, var.master_nodes[count.index].labels)

  rule {
    direction   = "in"
    protocol    = "tcp"
    port        = var.default_ssh_port
    source_ips  = var.ssh_source_ips
    description = "ssh"
  }
  rule {
    direction   = "in"
    protocol    = "icmp"
    source_ips  = ["0.0.0.0/0", "::/0"]
    description = "ping is a fundamental feature every server should support"
  }
  rule {
    direction   = "in"
    protocol    = "tcp"
    port        = "6443"
    source_ips  = var.kubeapi_source_ips
    description = "kube-apiserver"
  }
  rule {
    direction   = "in"
    protocol    = "tcp"
    port        = "2379-2380"
    source_ips  = local.master_ips
    description = "etcd"
  }
  rule {
    direction   = "in"
    protocol    = "tcp"
    port        = "10250"
    source_ips  = concat(local.master_ips, local.worker_ips)
    description = "kubelet"
  }
  rule {
    direction   = "in"
    protocol    = "tcp"
    port        = "10257"
    source_ips  = local.master_ips
    description = "kube-controller-manager"
  }
  rule {
    direction   = "in"
    protocol    = "tcp"
    port        = "10259"
    source_ips  = local.master_ips
    description = "kube-scheduler"
  }

  dynamic "rule" {
    for_each = var.additional_fw_rules_master
    content {
      direction   = rule.value["direction"]
      protocol    = rule.value["protocol"]
      port        = rule.value["port"]
      source_ips  = concat(rule.value["source_ips"], rule.value["inject_worker_ips"] == true ? local.worker_ips : null, rule.value["inject_master_ips"] == true ? local.master_ips : null)
      description = rule.value["description"]
    }
  }

  apply_to {
    server = hcloud_server.master[count.index].id
  }
}

#----------------
# Compute
#----------------
resource "hcloud_placement_group" "control_plane" {
  name = "control_plane-${var.cluster_name}"
  type = "spread"
  labels = merge({
    "managed-by"   = "terraform"
    "cluster-name" = var.cluster_name
  }, var.common_labels)
}

resource "hcloud_volume" "master" {
  count = length(local.master_volumes)

  name      = local.master_volumes[count.index].name
  size      = local.master_volumes[count.index].size
  server_id = local.master_volumes[count.index].server_id

  labels = merge({
    "managed-by"   = "terraform"
    "cluster-name" = var.cluster_name
  }, var.common_labels)

}

resource "hcloud_server" "master" {
  count = length(var.master_nodes)

  name               = var.master_nodes[count.index].name
  server_type        = var.master_nodes[count.index].server_type
  image              = var.master_nodes[count.index].image
  location           = var.master_nodes[count.index].location
  placement_group_id = hcloud_placement_group.control_plane.id
  backups            = var.enable_server_backups
  ssh_keys           = hcloud_ssh_key.default_ssh_keys[*].id

  user_data = templatefile(
    local.master_templatefile,
    {
      ssh_user      = var.default_ssh_user
      ssh_keys      = var.default_ssh_keys
      ssh_port      = var.default_ssh_port
      install_falco = var.install_falco
    }
  )

  public_net {
    ipv4_enabled = var.ip_mode == "ipv4" ? true : false
    ipv6_enabled = var.ip_mode == "ipv6" ? true : false
  }

  labels = merge({
    "managed-by"    = "terraform"
    "cluster-name"  = var.cluster_name
    "role"          = "master"
    "control_plane" = "true"
  }, var.common_labels, var.master_nodes[count.index].labels)

  lifecycle {
    ignore_changes = [
      user_data,
      ssh_keys,
    ]
  }

}
