terraform {
  required_providers {
    digitalocean = { source = "digitalocean/digitalocean", version = "~> 2.0" }
  }
}

variable "project_name" {
  type = string
}

variable "region" {
  type    = string
  default = "lon1"
}

variable "size" {
  type    = string
  default = "s-1vcpu-1gb"
}

variable "ssh_key_id" {
  type = string
}

variable "ssh_allowed_cidrs" {
  type        = list(string)
  description = "CIDR blocks permitted to reach SSH (port 22) on the droplet. Defaults to none, so SSH is closed until you add your own address. Set to [\"0.0.0.0/0\", \"::/0\"] only if you accept world-open SSH."
  default     = []

  validation {
    condition     = alltrue([for c in var.ssh_allowed_cidrs : can(cidrhost(c, 0))])
    error_message = "Every entry in ssh_allowed_cidrs must be a valid CIDR block, for example 203.0.113.4/32."
  }
}

resource "digitalocean_droplet" "this" {
  name       = "${var.project_name}-worker"
  region     = var.region
  size       = var.size
  image      = "ubuntu-24-04-x64"
  ssh_keys   = [var.ssh_key_id]
  monitoring = true

  user_data = <<-EOT
    #!/bin/bash
    apt-get update
    apt-get install -y docker.io docker-compose
    systemctl enable docker
    systemctl start docker
  EOT
}

resource "digitalocean_firewall" "this" {
  name        = "${var.project_name}-firewall"
  droplet_ids = [digitalocean_droplet.this.id]

  # SSH is closed unless the operator names the addresses allowed to reach it.
  # An empty ssh_allowed_cidrs (the default) emits no port-22 rule at all, so
  # the droplet is not reachable on SSH from anywhere.
  dynamic "inbound_rule" {
    for_each = length(var.ssh_allowed_cidrs) > 0 ? [1] : []
    content {
      protocol         = "tcp"
      port_range       = "22"
      source_addresses = var.ssh_allowed_cidrs
    }
  }

  inbound_rule {
    protocol         = "tcp"
    port_range       = "443"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }
  outbound_rule {
    protocol              = "tcp"
    port_range            = "1-65535"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }
}

output "droplet_id" {
  value = digitalocean_droplet.this.id
}

output "ipv4" {
  value = digitalocean_droplet.this.ipv4_address
}
