variable "project_name" {
  type        = string
  description = "Used as the base name for all resources"
}

variable "domain" {
  type        = string
  description = "Apex domain (no www, no protocol)"
}

variable "github_repo" {
  type        = string
  description = "owner/repo format"
}

variable "vercel_api_token" {
  type      = string
  sensitive = true
}

variable "supabase_access_token" {
  type      = string
  sensitive = true
}

variable "supabase_org_id" {
  type        = string
  description = "Supabase organisation ID (find at app.supabase.com)"
}

variable "cloudflare_api_token" {
  type      = string
  sensitive = true
}

variable "digitalocean_token" {
  type      = string
  sensitive = true
}

variable "digitalocean_ssh_key_id" {
  type        = string
  description = "DigitalOcean SSH key ID for droplet access"
  default     = ""
}

variable "enable_droplet" {
  type        = bool
  default     = false
  description = "Whether to provision a DigitalOcean droplet alongside Vercel/Supabase"
}
