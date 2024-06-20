locals {
  datacenters = { eu-central = ["hel1", "fsn1", "nbg1"], us-east = ["ash", "hil"] }

  master_volumes = flatten([
    for server in var.master_nodes : [
      for volume_key, volume in server.volumes : {
        name      = volume.size
        size      = volume.size
        server_id = hcloud_server.master[server.index].id
      }
    ]
  ])
  worker_volumes = flatten([
    for server in var.worker_nodes : [
      for volume_key, volume in server.volumes : {
        name      = volume.size
        size      = volume.size
        server_id = hcloud_server.worker[server.index].id
      }
    ]
  ])
}

data "hcloud_locations" "datacenters" {}

data "hcloud_server_types" "instance_types" {}
