#----------------
# Networking
#----------------
resource "hcloud_firewall" "data_plane" {
  count = length(var.worker_nodes)

  name = var.worker_nodes[count.index].name
  labels = merge({
    "managed-by"   = "terraform"
    "cluster-name" = var.cluster_name
  }, var.common_labels, var.worker_nodes[count.index].labels)

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
    port        = "30000-32767"
    source_ips  = var.nodeport_source_ips
    description = "nodeport services"
  }
  rule {
    direction   = "in"
    protocol    = "tcp"
    port        = "10250"
    source_ips  = concat(local.master_ips, local.worker_ips)
    description = "kubelet"
  }
  dynamic "rule" {
    for_each = var.additional_fw_rules_worker
    content {
      direction   = rule.value["direction"]
      protocol    = rule.value["protocol"]
      port        = rule.value["port"]
      source_ips  = concat(rule.value["source_ips"], rule.value["inject_worker_ips"] == true ? local.worker_ips : null, rule.value["inject_master_ips"] == true ? local.master_ips : null)
      description = rule.value["description"]
    }
  }

  apply_to {
    server = hcloud_server.worker[count.index].id
  }
}

#----------------
# Compute
#----------------
resource "hcloud_placement_group" "data_plane" {
  name = "data_plane-${var.cluster_name}"
  type = "spread"
  labels = merge({
    "managed-by"   = "terraform"
    "cluster-name" = var.cluster_name
  }, var.common_labels)
}

resource "hcloud_volume" "worker" {
  count = length(local.worker_volumes)

  name      = local.worker_volumes[count.index].name
  size      = local.worker_volumes[count.index].size
  server_id = local.worker_volumes[count.index].server_id

  labels = merge({
    "managed-by"   = "terraform"
    "cluster-name" = var.cluster_name
  }, var.common_labels)

}

resource "hcloud_server" "worker" {
  count = length(var.worker_nodes)

  name               = var.worker_nodes[count.index].name
  server_type        = var.worker_nodes[count.index].server_type
  image              = var.worker_nodes[count.index].image
  location           = var.worker_nodes[count.index].location
  placement_group_id = hcloud_placement_group.data_plane.id
  backups            = var.enable_server_backups
  ssh_keys           = hcloud_ssh_key.default_ssh_keys[*].id

  user_data = templatefile(
    local.worker_templatefile,
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
    "managed-by"   = "terraform"
    "cluster-name" = var.cluster_name
    "data_plane"   = "true"
  }, var.common_labels, var.worker_nodes[count.index].labels)

  lifecycle {
    ignore_changes = [
      user_data,
      ssh_keys,
    ]
  }
}
