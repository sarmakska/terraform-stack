terraform {
  required_providers {
    vercel = { source = "vercel/vercel", version = "~> 2.0" }
  }
}

variable "project_name" {
  type = string
}

variable "domain" {
  type = string
}

variable "github_repo" {
  type = string
}

variable "env_vars" {
  type    = map(string)
  default = {}
}

resource "vercel_project" "this" {
  name      = var.project_name
  framework = "nextjs"
  git_repository = {
    type = "github"
    repo = var.github_repo
  }
}

resource "vercel_project_environment_variable" "this" {
  for_each   = var.env_vars
  project_id = vercel_project.this.id
  key        = each.key
  value      = each.value
  target     = ["production", "preview", "development"]
}

resource "vercel_project_domain" "this" {
  project_id = vercel_project.this.id
  domain     = var.domain
}

output "project_id" {
  value = vercel_project.this.id
}

output "project_name" {
  value = vercel_project.this.name
}
