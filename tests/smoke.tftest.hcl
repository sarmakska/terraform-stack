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
