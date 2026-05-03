terraform {
  required_version = ">= 1.9"

  required_providers {
    vercel = {
      source  = "vercel/vercel"
      version = "~> 2.0"
    }
    supabase = {
      source  = "supabase/supabase"
      version = "~> 1.5"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.0"
    }
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}

provider "vercel" {
  api_token = var.vercel_api_token
}

provider "supabase" {
  access_token = var.supabase_access_token
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

provider "digitalocean" {
  token = var.digitalocean_token
}

module "supabase" {
  source       = "./modules/supabase"
  project_name = var.project_name
  region       = "eu-west-2"
  org_id       = var.supabase_org_id
}

module "cloudflare" {
  source = "./modules/cloudflare"
  domain = var.domain
}

module "vercel" {
  source       = "./modules/vercel"
  project_name = var.project_name
  domain       = var.domain
  github_repo  = var.github_repo

  env_vars = {
    NEXT_PUBLIC_SUPABASE_URL      = module.supabase.api_url
    NEXT_PUBLIC_SUPABASE_ANON_KEY = module.supabase.anon_key
    SUPABASE_SERVICE_ROLE_KEY     = module.supabase.service_role_key
  }
}

module "digitalocean" {
  count        = var.enable_droplet ? 1 : 0
  source       = "./modules/digitalocean"
  project_name = var.project_name
  region       = "lon1"
  size         = "s-1vcpu-1gb"
  ssh_key_id   = var.digitalocean_ssh_key_id
}
