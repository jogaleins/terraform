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

resource "proxmox_vm_qemu" "tf-agents" {
    count = length(var.hostnames)
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
        storage = "local-zfs"
        iothread = 1
        ssd = 1
        discard = "on"
    }
    network {
        model = "virtio"
        bridge = "vmbr0"
    }
    
    ipconfig0 = "ip=${var.ips[count.index]}/24,gw=${cidrhost(format("%s/24", var.ips[count.index]), 1)}"
    lifecycle {
      ignore_changes = [
      network
      ]
    }   
    connection {
        host = var.ips[count.index]
        user = var.user
        private_key = file(var.ssh_keys["priv"])
        agent = false
        timeout = "3m"
    }

    timeouts {
      create = "20m"
      delete = "20m"
    }
    provisioner "remote-exec" {
        inline = [ "echo 'Cool, we are ready for provisioning'"]
    }

    provisioner "local-exec" {
        working_dir = "./ansible"
        command = "ansible-playbook -u ${var.user} --key-file ${var.ssh_keys["priv"]} -i inventory.ini main.yaml"
    }

    depends_on = [
      local_file.create-inventory-file
    ]
}

resource "local_file" "create-hostname-file" {
  count = 1
  filename = "${path.cwd}/hostname.${count.index + 1}"
  content = <<-EOT
  ${var.vm-name}-${count.index + 1}
  EOT
  depends_on = [
    proxmox_vm_qemu.tf-agents
  ]
}

resource "local_file" "create-inventory-file" {
  count = 1
  filename = "${path.cwd}/ansible/inventory.ini"
  content = <<-EOT
  [kube_agents]
  ${var.ips[count.index]} ansible_user=centos
  EOT

}