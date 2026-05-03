# Modules

Each module is small, opinionated, and independently usable.

## modules/vercel

Provisions:
- A Vercel project linked to a GitHub repo
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

Inputs:

| Variable | Type | Description |
| --- | --- | --- |
| `project_name` | string | Project name |
| `org_id` | string | Supabase organisation id |
| `region` | string | One of Supabase's supported regions (e.g. `eu-west-2`) |

Outputs: `project_id`, `api_url`, `anon_key`, `service_role_key`,
`database_password`. Anon and service-role keys are marked sensitive in
the module — make sure your remote state is encrypted.

## modules/cloudflare

Provisions:
- DNS A and CNAME records pointing at Vercel's anycast IP and CNAME
- An R2 bucket named after the domain (with dots replaced by hyphens)
- A Workers KV namespace named `<domain>-kv`

Inputs:

| Variable | Type | Description |
| --- | --- | --- |
| `domain` | string | Existing Cloudflare zone for the domain |

Outputs: `zone_id`, `r2_bucket`, `kv_namespace`.

## modules/digitalocean (optional)

Provisions a single droplet or small DOKS cluster for workloads that do
not fit on Vercel (long-running jobs, non-HTTP services, anything that
needs persistent state on disk).

Inputs (when enabled):

| Variable | Type | Description |
| --- | --- | --- |
| `droplet_size` | string | e.g. `s-2vcpu-4gb` |
| `droplet_region` | string | e.g. `lon1` |
| `ssh_key_id` | string | DO SSH key id for root access |

Outputs: `droplet_ip`, `droplet_id`.

## How modules are wired in main.tf

```hcl
module "supabase" {
  source       = "./modules/supabase"
  project_name = var.project_name
  region       = var.supabase_region
  org_id       = var.supabase_org_id
}

module "cloudflare" {
  source = "./modules/cloudflare"
  domain = var.domain
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

The Vercel project is created last so its env vars resolve from the
Supabase and Cloudflare outputs. Terraform's dependency graph handles
the ordering automatically.

## Extending

To add a provider (e.g. Resend, Stripe), copy one of the existing
modules. Keep the inputs minimal and the outputs explicit. Wire it
into `main.tf` like any other module. The pattern stays the same.
