# Module-level test for modules/digitalocean. It proves the SSH ingress
# hardening: by default the firewall emits no port-22 rule at all, and when
# ssh_allowed_cidrs is set the rule is scoped to exactly those addresses.
# Providers are mocked; plan-only, no real API calls.

mock_provider "digitalocean" {}

variables {
  project_name = "edge-app"
  ssh_key_id   = "11111111"
}

run "ssh_closed_by_default" {
  command = plan
  module {
    source = "./modules/digitalocean"
  }

  # No ssh_allowed_cidrs given, so the dynamic block produces zero port-22
  # inbound rules. Only the public HTTPS rule remains.
  assert {
    condition     = length([for r in digitalocean_firewall.this.inbound_rule : r if r.port_range == "22"]) == 0
    error_message = "SSH (port 22) must not be open when ssh_allowed_cidrs is empty"
  }

  assert {
    condition     = length([for r in digitalocean_firewall.this.inbound_rule : r if r.port_range == "443"]) == 1
    error_message = "HTTPS (port 443) should always be reachable"
  }
}

run "ssh_scoped_to_allowed_cidrs" {
  command = plan
  module {
    source = "./modules/digitalocean"
  }

  variables {
    ssh_allowed_cidrs = ["203.0.113.4/32", "198.51.100.0/24"]
  }

  assert {
    condition     = length([for r in digitalocean_firewall.this.inbound_rule : r if r.port_range == "22"]) == 1
    error_message = "A single SSH rule should be emitted when ssh_allowed_cidrs is set"
  }

  assert {
    condition     = one([for r in digitalocean_firewall.this.inbound_rule : r.source_addresses if r.port_range == "22"]) == toset(["203.0.113.4/32", "198.51.100.0/24"])
    error_message = "SSH source addresses must be exactly the configured CIDRs, never the whole internet"
  }
}

run "invalid_cidr_is_rejected" {
  command         = plan
  expect_failures = [var.ssh_allowed_cidrs]

  module {
    source = "./modules/digitalocean"
  }

  variables {
    ssh_allowed_cidrs = ["not-a-cidr"]
  }
}
