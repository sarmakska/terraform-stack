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

variable "supabase_region" {
  type        = string
  description = "Supabase project region"
  default     = "eu-west-2"
}

variable "supabase_enable_signup" {
  type        = bool
  description = "Allow new users to sign up through the Supabase auth API"
  default     = true
}

variable "supabase_jwt_expiry" {
  type        = number
  description = "Supabase access token (JWT) lifetime in seconds"
  default     = 3600
}

variable "supabase_enable_edge_functions" {
  type        = bool
  description = "Deploy the bundled Supabase edge functions"
  default     = true
}

variable "cloudflare_api_token" {
  type      = string
  sensitive = true
}

variable "cloudflare_enable_worker" {
  type        = bool
  description = "Deploy the Cloudflare edge Worker bound to R2 and KV"
  default     = true
}

variable "digitalocean_token" {
  type      = string
  sensitive = true
}

variable "digitalocean_region" {
  type        = string
  description = "DigitalOcean region for the optional droplet"
  default     = "lon1"
}

variable "digitalocean_size" {
  type        = string
  description = "DigitalOcean droplet size slug"
  default     = "s-1vcpu-1gb"
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
