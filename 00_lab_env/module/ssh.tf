resource "hcloud_ssh_key" "default_ssh_keys" {
  count      = length(var.default_ssh_keys)
  name       = "Default SSH Key ${count.index}"
  public_key = var.default_ssh_keys[count.index]
}
