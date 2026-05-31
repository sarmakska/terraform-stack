terraform {
  required_providers {
    supabase = {
      source  = "supabase/supabase"
      version = "~> 1.5"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }
}

variable "project_name" {
  type        = string
  description = "Supabase project name"
}

variable "region" {
  type        = string
  description = "One of Supabase's supported regions (e.g. eu-west-2)"
}

variable "org_id" {
  type        = string
  description = "Supabase organisation id"
}

variable "site_url" {
  type        = string
  description = "Allowed site URL for the auth redirect flow"
  default     = "http://localhost:3000"
}

variable "additional_redirect_urls" {
  type        = list(string)
  description = "Extra redirect URLs accepted by the auth server"
  default     = []
}

variable "enable_signup" {
  type        = bool
  description = "Whether new users may sign up through the auth API"
  default     = true
}

variable "jwt_expiry" {
  type        = number
  description = "Access token (JWT) lifetime in seconds"
  default     = 3600
}

variable "enable_edge_functions" {
  type        = bool
  description = "Whether to deploy the bundled edge functions"
  default     = true
}

resource "random_password" "db" {
  length  = 32
  special = true
}

resource "supabase_project" "this" {
  organization_id   = var.org_id
  name              = var.project_name
  database_password = random_password.db.result
  region            = var.region
}

# Auth configuration. The settings resource updates the project's auth server
# in place: site URL, redirect allow-list, signup policy, and JWT lifetime.
resource "supabase_settings" "this" {
  project_ref = supabase_project.this.id

  auth = jsonencode({
    site_url                   = var.site_url
    uri_allow_list             = join(",", var.additional_redirect_urls)
    disable_signup             = !var.enable_signup
    jwt_exp                    = var.jwt_expiry
    mailer_autoconfirm         = false
    external_email_enabled     = true
    external_anonymous_enabled = false
  })
}

# Real, deployable edge function bundled with this module.
resource "supabase_edge_function" "health" {
  count       = var.enable_edge_functions ? 1 : 0
  project_ref = supabase_project.this.id
  slug        = "health"
  name        = "health"
  entrypoint  = "${path.module}/functions/health/index.ts"
}

# Real project API keys read back from the management API, rather than the
# previous placeholder that returned the project id.
data "supabase_apikeys" "this" {
  project_ref = supabase_project.this.id
}

output "project_id" {
  value = supabase_project.this.id
}

output "api_url" {
  value = "https://${supabase_project.this.id}.supabase.co"
}

output "anon_key" {
  value     = data.supabase_apikeys.this.anon_key
  sensitive = true
}

output "service_role_key" {
  value     = data.supabase_apikeys.this.service_role_key
  sensitive = true
}

output "database_password" {
  value     = random_password.db.result
  sensitive = true
}

output "edge_function_slugs" {
  value = var.enable_edge_functions ? [for f in supabase_edge_function.health : f.slug] : []
}
