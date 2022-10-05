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
variable "hostnames" {
  description = "VMs to be created"
  type        = list(string)
  default     = ["agent-1"]
}
variable "ips" {
    description = "IPs of the VMs, respective to the hostname order"
    type        = list(string)
	default     = ["192.168.2.151"]
}
variable "ssh_keys" {
	type = map
     default = {
       pub  = "~/.ssh/id_rsa.pub"
       priv = "~/.ssh/id_rsa"
     }
}
variable "user" {
	default     = "centos"
	description = "User used to SSH into the machine and provision it"
}

#variable "ssh_password" {}
