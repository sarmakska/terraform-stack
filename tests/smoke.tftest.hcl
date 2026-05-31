# Smoke test: prove the root configuration parses and the module graph
# composes. Providers are mocked, so no real credentials or API calls are
# made and provider-side token format checks do not apply. Plan-only.
# Run with `terraform test`.

mock_provider "vercel" {}
mock_provider "supabase" {}
mock_provider "cloudflare" {}
mock_provider "digitalocean" {}
mock_provider "random" {}

variables {
  project_name          = "smoke-app"
  domain                = "example.com"
  github_repo           = "you/smoke-app"
  vercel_api_token      = "test-token"
  supabase_access_token = "test-token"
  supabase_org_id       = "test-org"
  cloudflare_api_token  = "test-token"
  digitalocean_token    = "test-token"
  enable_droplet        = false
}

run "root_plan_composes" {
  command = plan

  assert {
    condition     = module.vercel.project_name == var.project_name
    error_message = "Vercel module did not receive the project name"
  }

  assert {
    condition     = length(module.digitalocean) == 0
    error_message = "DigitalOcean droplet should not be planned when enable_droplet is false"
  }
}

run "cloudflare_worker_planned_by_default" {
  command = plan

  assert {
    condition     = module.cloudflare.worker_name == "example-com-edge"
    error_message = "Worker name should derive from the domain when not overridden"
  }

  assert {
    condition     = module.cloudflare.worker_route == "assets.example.com/*"
    error_message = "Worker route should default to assets.<domain>/*"
  }

  assert {
    condition     = module.cloudflare.r2_bucket == "example-com"
    error_message = "R2 bucket should be named after the domain with dots replaced"
  }
}

run "supabase_edge_function_planned_by_default" {
  command = plan

  assert {
    condition     = length(module.supabase.edge_function_slugs) == 1
    error_message = "The health edge function should be deployed by default"
  }

  assert {
    condition     = contains(module.supabase.edge_function_slugs, "health")
    error_message = "The deployed edge function slug should be 'health'"
  }
}

run "droplet_enabled_path" {
  command = plan

  variables {
    enable_droplet          = true
    digitalocean_ssh_key_id = "12345678"
  }

  assert {
    condition     = length(module.digitalocean) == 1
    error_message = "DigitalOcean droplet should be planned when enable_droplet is true"
  }
}

run "feature_flags_disable_optional_resources" {
  command = plan

  variables {
    cloudflare_enable_worker       = false
    supabase_enable_edge_functions = false
  }

  assert {
    condition     = module.cloudflare.worker_name == ""
    error_message = "Worker should not be planned when cloudflare_enable_worker is false"
  }

  assert {
    condition     = length(module.supabase.edge_function_slugs) == 0
    error_message = "Edge functions should not be planned when disabled"
  }
}
