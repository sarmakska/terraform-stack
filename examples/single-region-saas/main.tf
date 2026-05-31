# Single-region SaaS reference invocation.
#
# This is the smallest realistic use of terraform-stack: a Next.js app on
# Vercel, a Supabase database, Cloudflare DNS plus R2 and KV, and no
# long-running compute. It points at the repository root as a module so
# you can copy this directory, set your variables, and apply.
#
#   cp terraform.tfvars.example terraform.tfvars
#   # edit terraform.tfvars
#   terraform init
#   terraform plan

module "stack" {
  source = "../.."

  project_name = var.project_name
  domain       = var.domain
  github_repo  = var.github_repo

  vercel_api_token      = var.vercel_api_token
  supabase_access_token = var.supabase_access_token
  supabase_org_id       = var.supabase_org_id
  cloudflare_api_token  = var.cloudflare_api_token
  digitalocean_token    = var.digitalocean_token

  # Single region, no droplet: Vercel and Supabase carry the workload.
  enable_droplet = false
}

variable "project_name" { type = string }
variable "domain" { type = string }
variable "github_repo" { type = string }

variable "vercel_api_token" {
  type      = string
  sensitive = true
}

variable "supabase_access_token" {
  type      = string
  sensitive = true
}

variable "supabase_org_id" { type = string }

variable "cloudflare_api_token" {
  type      = string
  sensitive = true
}

variable "digitalocean_token" {
  type      = string
  sensitive = true
}
