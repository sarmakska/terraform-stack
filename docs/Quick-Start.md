# Quick start

Provision a Vercel + Supabase + Cloudflare stack in under ten minutes.

## 0. Prerequisites

- Terraform 1.6+
- A Vercel account + personal access token
- A Supabase organisation + access token
- A Cloudflare account + API token (Zone:Edit, Account:Edit)
- A domain you own, added to Cloudflare as a zone
- A GitHub repo for the Next.js app

## 1. Clone and configure

```bash
git clone https://github.com/sarmakska/terraform-stack.git
cd terraform-stack
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars`:

```hcl
project_name      = "my-saas"
domain            = "mysaas.com"
vercel_team_id    = "team_xxx"
github_repo       = "you/my-saas"
supabase_org_id   = "abcd1234"
supabase_region   = "eu-west-2"
```

## 2. Set credentials

```bash
export VERCEL_API_TOKEN=...
export SUPABASE_ACCESS_TOKEN=...
export CLOUDFLARE_API_TOKEN=...
# optional
export DIGITALOCEAN_TOKEN=...
```

## 3. Apply

```bash
terraform init
terraform plan
terraform apply
```

## 4. What you get

Outputs after a successful apply:

- `vercel_project_id` — for CI deploy hooks
- `supabase_api_url`, `supabase_anon_key`, `supabase_service_role_key` — already wired into the Vercel project's env vars
- `r2_bucket` — bucket name for object storage
- `kv_namespace` — Workers KV namespace id
- `database_password` — generated, mark sensitive in your CI

The Vercel project will start a deploy as soon as you push to the
configured GitHub branch.

## 5. Tear down

```bash
terraform destroy
```

This deletes the Supabase project (irreversibly), removes the Vercel
project, and clears the Cloudflare records. The Cloudflare zone itself
is not deleted; you keep your domain.

## Common gotchas

- **Supabase region not available.** The free tier is regional. Match
  the region argument to one your organisation has access to.
- **Cloudflare token scope.** Needs Zone:Edit on the specific zone and
  Account:Edit for R2/KV. A "global" API key works but is overkill.
- **Vercel team vs personal.** If you are deploying to a team, set
  `vercel_team_id`. Without it, the project lands on your personal
  account and the team-scoped env vars do not apply.

## Next: read [Modules](Modules.md) for what each module configures.
