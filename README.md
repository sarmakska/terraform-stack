# terraform-stack

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Terraform](https://img.shields.io/badge/Terraform-1.9+-7B42BC?logo=terraform&logoColor=white)](https://www.terraform.io)
[![Vercel](https://img.shields.io/badge/Vercel-provider-black?logo=vercel)](https://registry.terraform.io/providers/vercel/vercel/latest)
[![Supabase](https://img.shields.io/badge/Supabase-provider-3ECF8E?logo=supabase&logoColor=white)](https://registry.terraform.io/providers/supabase/supabase/latest)
[![Cloudflare](https://img.shields.io/badge/Cloudflare-provider-F38020?logo=cloudflare&logoColor=white)](https://registry.terraform.io/providers/cloudflare/cloudflare/latest)
[![DigitalOcean](https://img.shields.io/badge/DigitalOcean-provider-0080FF?logo=digitalocean&logoColor=white)](https://registry.terraform.io/providers/digitalocean/digitalocean/latest)
[![Open Source](https://img.shields.io/badge/Open_Source-%E2%9D%A4-red)](https://github.com/sarmakska/terraform-stack)

**Solo-engineer-stack as code: Vercel + Supabase + Cloudflare + DigitalOcean in one Terraform repo.**

Built by [Sarma Linux](https://sarmalinux.com).

---

## What this is

The four services I use most as a solo engineer in 2026, fully described in Terraform. Run `terraform apply` and you have:

- A Next.js Vercel project linked to a GitHub repo
- A Supabase project with environment variables wired into Vercel
- A Cloudflare zone with DNS records, R2 bucket, and Workers KV namespace
- A DigitalOcean droplet running a worker, with monitoring on

All in one apply. Tear down with one destroy. Reproducible across personal projects, client work, demo environments.

## Architecture

```mermaid
graph LR
  GH[GitHub repo] --> V[Vercel project]
  V --> S[Supabase project]
  V --> CF[Cloudflare zone]
  V --> DO[DigitalOcean droplet]
  CF --> R2[R2 bucket]
  CF --> KV[Workers KV]
  DO --> Mon[DO Monitoring]

  classDef cloud fill:#a78bfa,stroke:#a78bfa,color:#fff
  class V,S,CF,DO cloud
```

## Quick start

```bash
git clone https://github.com/sarmakska/terraform-stack.git
cd terraform-stack
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your credentials
terraform init
terraform plan
terraform apply
```

## What you need

```hcl
# terraform.tfvars
project_name = "my-app"
domain       = "example.com"
github_repo  = "you/my-app"

vercel_api_token       = "..."
supabase_access_token  = "..."
cloudflare_api_token   = "..."
digitalocean_token     = "..."
```

API tokens are scoped: each provider gets only the permissions it needs.

## Modules

- `modules/vercel` — project, env vars, custom domain, deployment hooks
- `modules/supabase` — project, database password, JWT secret rotation
- `modules/cloudflare` — zone, DNS, R2 bucket, Workers KV namespace
- `modules/digitalocean` — droplet (Hetzner-equivalent if you swap providers), DO monitoring

Each module is independent. Use only the ones you need:

```hcl
module "vercel" {
  source = "./modules/vercel"
  ...
}
# Skip the others if you only want Vercel
```

## What this is NOT

- Multi-environment management (use Terraform workspaces or Terragrunt for that)
- A replacement for Pulumi/CDK if you prefer those
- Production-ready out of the box for high-compliance environments (you will need to harden it)
- Free of opinions: it picks specific regions, SKUs, and config patterns

## Roadmap

- [x] Vercel module (project, env, domain)
- [x] Supabase module (project, secrets)
- [x] Cloudflare module (zone, R2, KV)
- [x] DigitalOcean module (droplet, monitoring)
- [ ] AWS module (EC2, RDS, S3) for those who insist
- [ ] GCP module (Cloud Run, Cloud SQL, GCS)
- [ ] Hetzner Cloud module
- [ ] Tailscale module for secure private networking
- [ ] Outputs for CI/CD: GitHub Actions secrets

## License

MIT.

Built by [Sarma Linux](https://sarmalinux.com).
