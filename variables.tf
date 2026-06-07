variable "project_name" {
  type        = string
  description = "Used as the base name for all resources"
}

variable "domain" {
  type        = string
  description = "Apex domain (no www, no protocol)"

  validation {
    condition     = can(regex("^[a-z0-9]([a-z0-9-]*[a-z0-9])?(\\.[a-z0-9]([a-z0-9-]*[a-z0-9])?)+$", var.domain))
    error_message = "domain must be a bare apex domain such as example.com, with no protocol, no www and no trailing slash."
  }
}

variable "github_repo" {
  type        = string
  description = "owner/repo format"

  validation {
    condition     = can(regex("^[A-Za-z0-9._-]+/[A-Za-z0-9._-]+$", var.github_repo))
    error_message = "github_repo must be in owner/repo format, for example sarmakska/terraform-stack."
  }
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

  validation {
    condition     = var.supabase_jwt_expiry >= 300 && var.supabase_jwt_expiry <= 604800
    error_message = "supabase_jwt_expiry must be between 300 seconds (5 minutes) and 604800 seconds (7 days)."
  }
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

variable "digitalocean_ssh_allowed_cidrs" {
  type        = list(string)
  description = "CIDR blocks allowed to reach SSH on the droplet. Empty (default) closes SSH entirely; set to your office or VPN range, e.g. [\"203.0.113.4/32\"]."
  default     = []
}

variable "enable_droplet" {
  type        = bool
  default     = false
  description = "Whether to provision a DigitalOcean droplet alongside Vercel/Supabase"
}
