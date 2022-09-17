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
    name = "terraform-test-vm"
    desc = "A test for using terraform and cloudinit"

    # Node name has to be the same name as within the cluster
    # this might not include the FQDN
    target_node = "homelab"

    # The destination resource pool for the new VM

    # The template name to clone this vm from
    clone = "centos"

    # Activate QEMU agent for this VM
    agent = 1

    os_type = "cloud-init"
    cores = 2
    sockets = 1
    vcpus = 0
    cpu = "host"
    memory = 2048
    scsihw = "lsi"

    # Setup the disk
    disk {
        size = "10G"
        type = "virtio"
        storage = "pve-ssd"
        iothread = 1
        ssd = 1
        discard = "on"
    }
    # Setup the network interface and assign a vlan tag: 256
    network {
        model = "virtio"
        bridge = "vmbr0"
        tag = 256
    }

    # Setup the ip address using cloud-init.
    # Keep in mind to use the CIDR notation for the ip.
    ipconfig0 = "ip=192.168.10.20/24,gw=192.168.10.1"

    sshkeys = <<EOF
    ssh-rsa 9182739187293817293817293871== user@pc
    EOF
}