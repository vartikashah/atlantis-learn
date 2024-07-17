#
# DO NOT MODIFY THIS FILE, MODIFY 'variables.tfvars'
#

variable "vm_image" {
    type = string
}

variable "vm_flavor" {
    type = string
}

variable "cidr_ssh" {
    type = string
}

variable "cidr_http" {
    type = string
}

variable "vm_prefix" {
    type = string
}

variable "vm_count" {
    type = string
}

variable "keypair" {
    type = string  
}

variable "network" {
    type = string
}

variable "ssh_user" {
    type = string
    description = "SSH user name to connect to your instance."
}
