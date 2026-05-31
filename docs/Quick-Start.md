# Quick start

Provision a Vercel + Supabase + Cloudflare stack in under ten minutes.

## 0. Prerequisites

- Terraform 1.9+
- A Vercel account and an API token
- A Supabase organisation and an access token, plus the organisation id
- A Cloudflare account and an API token (`Zone:Edit`, `Account:Edit`)
- A domain you own, already added to Cloudflare as a zone
- A GitHub repo for the Next.js app

## 1. Clone and configure

```bash
git clone https://github.com/sarmakska/terraform-stack.git
cd terraform-stack
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars`:

```hcl
project_name = "my-saas"
domain       = "mysaas.com"
github_repo  = "you/my-saas"

vercel_api_token      = "..."
supabase_access_token = "..."
supabase_org_id       = "abcd1234"
cloudflare_api_token  = "..."
digitalocean_token    = ""   # only needed when enable_droplet = true

enable_droplet          = false
digitalocean_ssh_key_id = ""
```

Tokens can also be supplied as environment variables instead of in the file:

```bash
export TF_VAR_vercel_api_token=...
export TF_VAR_supabase_access_token=...
export TF_VAR_cloudflare_api_token=...
export TF_VAR_digitalocean_token=...   # optional
```

## 2. Apply

```bash
terraform init
terraform plan
terraform apply
```

## 3. What you get

Outputs after a successful apply (run `terraform output`):

- `vercel_project_id` : for CI deploy hooks
- `supabase_project_id`, `supabase_api_url`
- `supabase_anon_key`, `supabase_service_role_key` : already wired into the
  Vercel project's env vars (sensitive)
- `supabase_edge_functions` : the deployed edge function slugs (e.g. `["health"]`)
- `r2_bucket` : bucket name for object storage
- `kv_namespace` : Workers KV namespace id
- `worker_name`, `worker_route` : the deployed edge Worker and its route
- `database_password` : generated (sensitive)
- `droplet_ip` : the optional DigitalOcean droplet IP, or `null`

The Vercel project starts a deploy as soon as you push to the configured GitHub
branch.

## 4. Tune the defaults

Everything optional has a default. Common overrides in `terraform.tfvars`:

```hcl
supabase_region                = "us-east-1"
supabase_enable_signup         = false   # invite-only auth
supabase_jwt_expiry            = 7200
supabase_enable_edge_functions = true
cloudflare_enable_worker       = true
digitalocean_region            = "fra1"
digitalocean_size              = "s-2vcpu-4gb"
```

## 5. Tear down

```bash
terraform destroy
```

This deletes the Supabase project (irreversibly), removes the Vercel project,
and clears the Cloudflare records and Worker. The Cloudflare zone itself is not
deleted, so you keep your domain.

## Common gotchas

- **Supabase region not available.** The region argument must be one your
  organisation can use. Free-tier organisations are restricted to a subset;
  match `supabase_region` to one listed against your org.
- **Cloudflare token scope.** Needs `Zone:Edit` on the specific zone for DNS,
  and `Account:Edit` for R2, KV and Workers. A global API key works but is
  overkill.
- **Cloudflare zone not found.** The domain you pass must already exist as a
  zone in your account. This stack manages records inside an existing zone; it
  does not create the zone.
- **Vercel project lands on the wrong account.** A personal token creates the
  project on your personal account. Use a team-scoped token to deploy to a team.

## Next: read [Modules](Modules.md) for what each module configures.
