# Roadmap

## Now

- Vercel module (project + domain + env vars)
- Supabase module (project + database password)
- Cloudflare module (DNS + R2 + KV)
- DigitalOcean module (optional droplet/cluster)
- Reference example: single-region SaaS

## Next

- **Resend module** for transactional email + DKIM setup against the Cloudflare zone.
- **Stripe products + prices** as IaC. Subscription tiers should be reproducible across environments.
- **GitHub Actions module.** Provisions deploy keys, repo secrets, and an OIDC role for CI to assume cloud creds without static secrets.
- **State backend bootstrap**. A small companion stack that creates the Cloudflare R2 bucket and IAM keys for the main stack's remote state.

## Maybe

- AWS module covering Route 53 + S3 + IAM for teams whose primary cloud is AWS but want the same shape.
- A "platform-in-a-box" wrapper that combines this repo with [k8s-ops-toolkit](https://github.com/sarmakska/k8s-ops-toolkit).
- Pulumi parity. The same modules expressed as Pulumi resources for teams that prefer it.

## Not planned

- A generic AWS-everything stack. There are good ones already.
- SaaS-specific modules (multi-tenant DB schema, etc.). Out of scope; this repo is infrastructure.

## How to contribute

PRs welcome for new modules following the existing shape: small, no
abstractions, explicit inputs and outputs. For changes to existing
modules, please open an issue first — keeping these stable is the point.
