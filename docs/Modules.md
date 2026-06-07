# Modules

Each module is small, opinionated, and independently usable.

## modules/vercel

Provisions:
- A Vercel project linked to a GitHub repo (Next.js framework)
- A Vercel project domain
- Environment variables set from a `map(string)` input

Inputs:

| Variable | Type | Description |
| --- | --- | --- |
| `project_name` | string | Vercel project slug |
| `domain` | string | Custom domain (added to project) |
| `github_repo` | string | `owner/repo` |
| `env_vars` | map(string) | Project env vars (applied to production, preview, development) |

Outputs: `project_id`, `project_name`.

## modules/supabase

Provisions:
- A Supabase project in the requested region under your organisation
- A 32-character random database password (treat as sensitive)
- Auth configuration through `supabase_settings`: site URL, redirect
  allow-list, signup policy, JWT lifetime
- A deployed `health` edge function (Deno), gated by `enable_edge_functions`
- Reads the project's real anon and service-role keys via the
  `supabase_apikeys` data source

Inputs:

| Variable | Type | Default | Description |
| --- | --- | --- | --- |
| `project_name` | string | - | Project name |
| `org_id` | string | - | Supabase organisation id |
| `region` | string | - | One of Supabase's supported regions (e.g. `eu-west-2`) |
| `site_url` | string | `http://localhost:3000` | Allowed site URL for the auth redirect flow |
| `additional_redirect_urls` | list(string) | `[]` | Extra redirect URLs accepted by the auth server |
| `enable_signup` | bool | `true` | Whether new users may sign up |
| `jwt_expiry` | number | `3600` | Access token (JWT) lifetime in seconds |
| `enable_edge_functions` | bool | `true` | Deploy the bundled edge functions |

Outputs: `project_id`, `api_url`, `anon_key` (sensitive), `service_role_key`
(sensitive), `database_password` (sensitive), `edge_function_slugs`. Make sure
your remote state is encrypted because the sensitive outputs land in state.

## modules/cloudflare

Provisions:
- DNS `A` and `CNAME` records pointing at Vercel's anycast IP and CNAME
- An R2 bucket named after the domain (dots replaced by hyphens)
- A Workers KV namespace named `<domain>-kv`
- An edge Worker (`worker.js`) bound to R2 as `ASSETS` and KV as `CACHE`, with
  a route mapping `assets.<domain>/*` to it, gated by `enable_worker`

Inputs:

| Variable | Type | Default | Description |
| --- | --- | --- | --- |
| `domain` | string | - | Existing Cloudflare zone for the domain |
| `enable_worker` | bool | `true` | Deploy the edge Worker bound to R2 and KV |
| `worker_name` | string | `<domain>-edge` | Worker script name |
| `worker_route_pattern` | string | `assets.<domain>/*` | Route pattern mapped to the Worker |

Outputs: `zone_id`, `account_id`, `r2_bucket`, `kv_namespace`, `worker_name`,
`worker_route`.

## modules/digitalocean (optional)

Provisions a single droplet for workloads that do not fit on Vercel
(long-running jobs, non-HTTP services, anything that needs persistent disk
state). The droplet runs Ubuntu 24.04 with Docker pre-installed and monitoring
on. The firewall serves HTTPS publicly but keeps SSH closed by default: port 22
is opened only to the CIDR blocks you list in `ssh_allowed_cidrs`, and when that
list is empty no port-22 rule is emitted at all. The droplet is therefore never
world-reachable on SSH unless you explicitly ask for it.

Inputs:

| Variable | Type | Default | Description |
| --- | --- | --- | --- |
| `project_name` | string | - | Base name for the droplet and firewall |
| `region` | string | `lon1` | DigitalOcean region |
| `size` | string | `s-1vcpu-1gb` | Droplet size slug |
| `ssh_key_id` | string | - | DO SSH key id for access |
| `ssh_allowed_cidrs` | list(string) | `[]` | CIDR blocks allowed to reach SSH. Empty closes SSH entirely. Validated as CIDRs at plan time. |

Outputs: `droplet_id`, `ipv4`.

## How modules are wired in main.tf

```hcl
module "supabase" {
  source       = "./modules/supabase"
  project_name = var.project_name
  region       = var.supabase_region
  org_id       = var.supabase_org_id

  site_url                 = "https://${var.domain}"
  additional_redirect_urls = ["https://www.${var.domain}", "http://localhost:3000"]
  enable_signup            = var.supabase_enable_signup
  jwt_expiry               = var.supabase_jwt_expiry
  enable_edge_functions    = var.supabase_enable_edge_functions
}

module "cloudflare" {
  source        = "./modules/cloudflare"
  domain        = var.domain
  enable_worker = var.cloudflare_enable_worker
}

module "vercel" {
  source       = "./modules/vercel"
  project_name = var.project_name
  domain       = var.domain
  github_repo  = var.github_repo
  env_vars = {
    NEXT_PUBLIC_SUPABASE_URL      = module.supabase.api_url
    NEXT_PUBLIC_SUPABASE_ANON_KEY = module.supabase.anon_key
    SUPABASE_SERVICE_ROLE_KEY     = module.supabase.service_role_key
    R2_BUCKET                     = module.cloudflare.r2_bucket
    KV_NAMESPACE_ID               = module.cloudflare.kv_namespace
  }
}
```

The Vercel project is created last so its env vars resolve from the Supabase and
Cloudflare outputs. Terraform's dependency graph handles the ordering
automatically.

## Input validation

The root variables are validated at plan time so a typo fails fast with a clear
message instead of surfacing as a provider error halfway through an apply:

| Variable | Rule |
| --- | --- |
| `domain` | Must be a bare apex domain such as `example.com`. No protocol, no `www`, no trailing slash. |
| `github_repo` | Must be `owner/repo`, for example `sarmakska/terraform-stack`. |
| `supabase_jwt_expiry` | Must be between 300 seconds (5 minutes) and 604800 seconds (7 days). |
| `digitalocean_ssh_allowed_cidrs` | Every entry must be a valid CIDR block, for example `203.0.113.4/32`. |

These rules are exercised by the test suite: `tests/smoke.tftest.hcl` asserts
each one rejects bad input, and `tests/digitalocean_module.tftest.hcl` proves
SSH is closed by default and scoped to exactly the configured CIDRs when set.

## Extending

To add a provider (for example Resend or Stripe), copy one of the existing
modules. Keep the inputs minimal and the outputs explicit. Wire it into
`main.tf` like any other module. The pattern stays the same.
