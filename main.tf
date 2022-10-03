terraform {
  required_version = ">= 1.1.0"
  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = ">= 2.9.5"
    }
  }
}

provider "proxmox" {
    pm_tls_insecure = true
    pm_api_url = var.proxmox["pm_api_url"]
    pm_password = var.proxmox["pm_password"]
    pm_user = var.proxmox["pm_user"]
    pm_otp = ""
}

resource "proxmox_vm_qemu" "cloudinit-centos" {
    count = var.agent-count
    name = "${var.vm-name}-${count.index + 1}"
    target_node = var.target_node
    vmid = "${var.node-id-prefix}${count.index + 1}"
    clone = var.clone-image

    agent = 1

    os_type = "cloud-init"
    cores = 4
    sockets = 1
    vcpus = 0
    cpu = "host"
    memory = 2048
    scsihw = "virtio-scsi-pci"

    disk {
        size = "10G"
        type = "scsi"
        storage = "pve-ssd"
        iothread = 1
        ssd = 1
        discard = "on"
    }
    network {
        model = "virtio"
        bridge = "vmbr0"
    }
  
    lifecycle {
      ignore_changes = [
      network
      ]
    }
    ipconfig0 = "ip=192.168.2.15${count.index + 1}/24,gw=192.168.2.1"
}

resource "local_file" "create-static-ip-file" {
  count = 1
  filename = "${path.cwd}/interfaces.${count.index + 1}"
  content = <<-EOT
  auto lo
  iface lo inet loopback

  auto eth0
  iface eth0 inet dhcp
  EOT
  
}