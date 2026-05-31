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
  inbound_rule {
    protocol         = "tcp"
    port_range       = "22"
    source_addresses = ["0.0.0.0/0", "::/0"]
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
