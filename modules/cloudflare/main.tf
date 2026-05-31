terraform {
  required_providers {
    cloudflare = { source = "cloudflare/cloudflare", version = "~> 4.0" }
  }
}

variable "domain" {
  type        = string
  description = "Existing Cloudflare zone for the domain"
}

variable "worker_name" {
  type        = string
  description = "Name of the deployed Worker script. Defaults to <domain>-edge"
  default     = ""
}

variable "worker_route_pattern" {
  type        = string
  description = "Route pattern that maps requests to the Worker. Defaults to assets.<domain>/*"
  default     = ""
}

variable "enable_worker" {
  type        = bool
  description = "Whether to deploy the edge Worker bound to R2 and KV"
  default     = true
}

locals {
  bucket_name   = replace(var.domain, ".", "-")
  worker_name   = var.worker_name != "" ? var.worker_name : "${local.bucket_name}-edge"
  route_pattern = var.worker_route_pattern != "" ? var.worker_route_pattern : "assets.${var.domain}/*"
}

data "cloudflare_zone" "this" {
  name = var.domain
}

resource "cloudflare_record" "vercel" {
  zone_id = data.cloudflare_zone.this.id
  name    = "@"
  content = "76.76.21.21" # Vercel anycast
  type    = "A"
  proxied = false
}

resource "cloudflare_record" "vercel_www" {
  zone_id = data.cloudflare_zone.this.id
  name    = "www"
  content = "cname.vercel-dns.com"
  type    = "CNAME"
  proxied = false
}

resource "cloudflare_r2_bucket" "main" {
  account_id = data.cloudflare_zone.this.account_id
  name       = local.bucket_name
}

resource "cloudflare_workers_kv_namespace" "main" {
  account_id = data.cloudflare_zone.this.account_id
  title      = "${local.bucket_name}-kv"
}

resource "cloudflare_workers_script" "edge" {
  count      = var.enable_worker ? 1 : 0
  account_id = data.cloudflare_zone.this.account_id
  name       = local.worker_name
  content    = file("${path.module}/worker.js")
  module     = true

  r2_bucket_binding {
    name        = "ASSETS"
    bucket_name = cloudflare_r2_bucket.main.name
  }

  kv_namespace_binding {
    name         = "CACHE"
    namespace_id = cloudflare_workers_kv_namespace.main.id
  }
}

resource "cloudflare_workers_route" "edge" {
  count       = var.enable_worker ? 1 : 0
  zone_id     = data.cloudflare_zone.this.id
  pattern     = local.route_pattern
  script_name = cloudflare_workers_script.edge[0].name
}

output "zone_id" {
  value = data.cloudflare_zone.this.id
}

output "account_id" {
  value = data.cloudflare_zone.this.account_id
}

output "r2_bucket" {
  value = cloudflare_r2_bucket.main.name
}

output "kv_namespace" {
  value = cloudflare_workers_kv_namespace.main.id
}

output "worker_name" {
  value = var.enable_worker ? cloudflare_workers_script.edge[0].name : ""
}

output "worker_route" {
  value = var.enable_worker ? cloudflare_workers_route.edge[0].pattern : ""
}
