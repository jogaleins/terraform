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
    pm_api_url = "https://192.168.2.99:8006/api2/json"
    pm_password = "soeid1"
    pm_user = "root@pam"
    pm_otp = ""
}

resource "proxmox_vm_qemu" "cloudinit-test" {
    count = 2
    name = "tf-vm-${count.index + 1}"
    target_node = "homelab"
    vmid = "40${count.index + 1}"
    clone = "centos"

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
      network,
      ]
    }
    ipconfig0 = "ip=192.168.2.15${count.index + 1}/24,gw=192.168.2.1"
}