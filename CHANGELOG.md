# Changelog

All notable changes to this project are documented in this file. The format
is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this
project follows semantic versioning for its tagged releases.

## [Unreleased]

### Security

- **SSH is closed by default on the DigitalOcean droplet.** The firewall no
  longer opens port 22 to `0.0.0.0/0`. The SSH inbound rule is now driven by a
  new `ssh_allowed_cidrs` variable (root: `digitalocean_ssh_allowed_cidrs`),
  which defaults to an empty list, so no port-22 rule is emitted at all unless
  you name the CIDR blocks allowed to reach it. HTTPS stays public. This
  removes a world-open SSH surface from the optional compute path.

### Added

- **Plan-time input validation.** `domain` must be a bare apex domain,
  `github_repo` must be `owner/repo`, `supabase_jwt_expiry` must be between 300
  and 604800 seconds, and every `digitalocean_ssh_allowed_cidrs` entry must be a
  valid CIDR. Misconfiguration now fails fast at plan with a clear message.
- **DigitalOcean module test.** New `tests/digitalocean_module.tftest.hcl`
  proves SSH is closed by default, is scoped to exactly the configured CIDRs
  when set, and that an invalid CIDR is rejected. The smoke test gained three
  runs asserting the new root validations reject bad input. Suite is now 14
  passing runs across three test files.
- **Cloudflare edge Worker.** `modules/cloudflare` now deploys a real,
  module-bundled Worker (`worker.js`) bound to the R2 bucket as `ASSETS` and
  the Workers KV namespace as `CACHE`, with a route mapping `assets.<domain>/*`
  to it. New module variables `enable_worker`, `worker_name` and
  `worker_route_pattern`, and new outputs `worker_name`, `worker_route` and
  `account_id`.
- **Supabase auth configuration.** `modules/supabase` now manages the project
  auth server through `supabase_settings`: site URL, redirect allow-list,
  signup policy and JWT lifetime. New variables `site_url`,
  `additional_redirect_urls`, `enable_signup`, `jwt_expiry`.
- **Supabase edge functions.** A real, deployable `health` Deno edge function
  (`functions/health/index.ts`) is deployed via `supabase_edge_function`,
  gated by `enable_edge_functions`. New output `edge_function_slugs`.
- **Real Supabase API keys.** The `anon_key` and `service_role_key` outputs are
  now read from the management API via the `supabase_apikeys` data source,
  replacing the previous placeholder that returned the project id.
- **Root outputs.** Added `outputs.tf` exposing project ids, the Supabase API
  URL and keys, the R2 bucket, KV namespace, Worker name and route, edge
  function slugs, the database password and the droplet IP.
- **Deploy workflow.** Added `.github/workflows/deploy.yml`: a manually
  triggered `plan` followed by an `apply` gated behind a protected GitHub
  environment for manual approval.
- **Tests.** Expanded `tests/smoke.tftest.hcl` and added
  `tests/cloudflare_module.tftest.hcl` to cover the Worker, edge function,
  feature flags, the droplet-enabled path, and module-level overrides.
- **Repository docs.** Added `ARCHITECTURE.md`, `ROADMAP.md` and this
  `CHANGELOG.md` at the repository root.

### Changed

- **Root configuration is more parameterised.** `supabase_region`,
  `supabase_enable_signup`, `supabase_jwt_expiry`,
  `supabase_enable_edge_functions`, `cloudflare_enable_worker`,
  `digitalocean_region` and `digitalocean_size` are now root variables with
  sensible defaults rather than hard-coded values.
- **Vercel env vars** now include `R2_BUCKET` and `KV_NAMESPACE_ID` from the
  Cloudflare module.
- **Security contact** moved to `security@sarmalinux.com` and the supported
  versions section now includes an explicit table.
- Rewrote the README, `docs/*` and every wiki page to describe the current
  feature set.

### Security

- Anonymous and service-role keys are now genuine secrets sourced from the
  management API and marked sensitive, so they are redacted from CLI output.

### Notes

- The Cloudflare provider major `5.x` and the Vercel provider major `5.x` are
  available but introduce breaking resource renames; they are tracked as
  separate upgrade issues rather than applied here. The repo stays on
  `cloudflare ~> 4.0` and `vercel ~> 2.0`.
