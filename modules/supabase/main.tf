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
  type = string
}

variable "region" {
  type = string
}

variable "org_id" {
  type = string
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

output "project_id" {
  value = supabase_project.this.id
}

output "api_url" {
  value = "https://${supabase_project.this.id}.supabase.co"
}

output "anon_key" {
  value     = supabase_project.this.id
  sensitive = true
}

output "service_role_key" {
  value     = supabase_project.this.id
  sensitive = true
}

output "database_password" {
  value     = random_password.db.result
  sensitive = true
}
