# Module-level test for modules/cloudflare. It plans the module in isolation
# against mocked providers and checks the Worker name, route, and storage
# wiring, including the override path. Plan-only; no real API calls.

mock_provider "cloudflare" {}

variables {
  domain = "myapp.io"
}

run "defaults_derive_from_domain" {
  command = plan
  module {
    source = "./modules/cloudflare"
  }

  assert {
    condition     = output.worker_name == "myapp-io-edge"
    error_message = "Worker name should default to <domain>-edge"
  }

  assert {
    condition     = output.worker_route == "assets.myapp.io/*"
    error_message = "Worker route should default to assets.<domain>/*"
  }

  assert {
    condition     = output.r2_bucket == "myapp-io"
    error_message = "R2 bucket should be named after the domain"
  }
}

run "overrides_apply" {
  command = plan
  module {
    source = "./modules/cloudflare"
  }

  variables {
    domain               = "myapp.io"
    worker_name          = "custom-worker"
    worker_route_pattern = "cdn.myapp.io/static/*"
  }

  assert {
    condition     = output.worker_name == "custom-worker"
    error_message = "Custom worker name should override the default"
  }

  assert {
    condition     = output.worker_route == "cdn.myapp.io/static/*"
    error_message = "Custom worker route should override the default"
  }
}

run "worker_disabled" {
  command = plan
  module {
    source = "./modules/cloudflare"
  }

  variables {
    domain        = "myapp.io"
    enable_worker = false
  }

  assert {
    condition     = output.worker_name == ""
    error_message = "Worker outputs should be empty when the worker is disabled"
  }
}
