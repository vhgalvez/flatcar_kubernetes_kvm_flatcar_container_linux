terraform {
  required_version = ">= 0.13.0"
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "~> 0.7.6"
    }
    ct = {
      source  = "poseidon/ct"
      version = "~> 0.14.0"
    }
    template = {
      source  = "hashicorp/template"
      version = "~> 3.0.0"
    }
  }
}
# Define libvirt URI
provider "libvirt" {
  uri = "qemu:///system"
}


resource "libvirt_volume" "base" {
  name   = "flatcar-base"
  source = var.base_image
  pool   = var.storage_pool
  format = "qcow2"
}

resource "libvirt_volume" "vm-disk" {
  for_each = toset(var.machines)

  # workaround: depend on libvirt_ignition.ignition[each.key], otherwise the VM will use the old disk when the user-data changes

  name           = "${var.cluster_name}-${each.key}-${md5(libvirt_ignition.ignition[each.key].id)}.qcow2"
  base_volume_id = libvirt_volume.base.id
  pool           = var.storage_pool
  format         = "qcow2"
}

resource "libvirt_ignition" "ignition" {
  for_each = toset(var.machines)
  name     = "${var.cluster_name}-${each.key}-ignition"
  pool     = var.storage_pool
  content  = data.ct_config.vm-ignitions[each.key].rendered
}

resource "libvirt_domain" "machine" {
  for_each = toset(var.machines)
  name     = "${var.cluster_name}-${each.key}"
  vcpu     = var.virtual_cpus
  memory   = var.virtual_memory

  fw_cfg_name     = "opt/org.flatcar-linux/config"
  coreos_ignition = libvirt_ignition.ignition[each.key].id

  disk {
    volume_id = libvirt_volume.vm-disk[each.key].id
  }

  graphics {
    listen_type = "address"
  }

  # dynamic IP assignment on the bridge, NAT for Internet access
  network_interface {
    network_name   = var.network_name
    wait_for_lease = true
  }
}

data "ct_config" "vm-ignitions" {
  for_each = toset(var.machines)
  content  = data.template_file.vm-configs[each.key].rendered
}

data "template_file" "vm-configs" {
  for_each = toset(var.machines)
  template = file("${path.module}/machine-${each.key}.yaml.tmpl")

  vars = {
    ssh_keys  = jsonencode(var.ssh_keys)
    name      = each.key
    host_name = "${each.key}.${var.cluster_name}.${var.cluster_domain}"
  }
}
