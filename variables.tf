variable "proxmox" {
    type = map
    default = {
        "pm_api_url" = "https://192.168.2.99:8006/api2/json"
        "pm_password" = "soeid1"
        "pm_user" = "root@pam"
    }
}

variable "clone-image" {
    type = string
    default = "centos"
  
}

variable "agent-count" {
   default = 1
}

variable "node-id-prefix" {
  default = 50
}

variable "target_node" {
  default = "homelab"
}

variable "vm-name" {
    default = "agent"
  
}