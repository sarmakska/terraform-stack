terraform {
  required_providers {
    cloudflare = { source = "cloudflare/cloudflare", version = "~> 4.0" }
  }
}

variable "domain" { type = string }

data "cloudflare_zone" "this" {
  name = var.domain
}

resource "cloudflare_record" "vercel" {
  zone_id = data.cloudflare_zone.this.id
  name    = "@"
  value   = "76.76.21.21"  # Vercel anycast
  type    = "A"
  proxied = false
}

resource "cloudflare_record" "vercel_www" {
  zone_id = data.cloudflare_zone.this.id
  name    = "www"
  value   = "cname.vercel-dns.com"
  type    = "CNAME"
  proxied = false
}

resource "cloudflare_r2_bucket" "main" {
  account_id = data.cloudflare_zone.this.account_id
  name       = replace(var.domain, ".", "-")
}

resource "cloudflare_workers_kv_namespace" "main" {
  account_id = data.cloudflare_zone.this.account_id
  title      = "${replace(var.domain, ".", "-")}-kv"
}

output "zone_id"      { value = data.cloudflare_zone.this.id }
output "r2_bucket"    { value = cloudflare_r2_bucket.main.name }
output "kv_namespace" { value = cloudflare_workers_kv_namespace.main.id }
