# Roadmap

## Shipped

- Vercel module: project, custom domain, environment variables.
- Supabase module: project, generated database password, auth configuration
  (`supabase_settings`), a deployed `health` edge function, and real anon and
  service-role keys read from the management API.
- Cloudflare module: zone DNS records, R2 bucket, Workers KV namespace, and an
  edge Worker bound to R2 and KV with a route.
- DigitalOcean module: optional droplet with Docker and monitoring, behind a
  firewall.
- Root outputs as stable contracts.
- CI: `fmt -check`, validate every module, `terraform test`.
- Deploy workflow: manual `plan` then `apply` gated behind a protected GitHub
  environment for human approval.
- Reference example: single-region SaaS.

## Next

- **Resend module** for transactional email plus DKIM setup against the
  Cloudflare zone.
- **Stripe products and prices** as IaC, so subscription tiers are reproducible
  across environments.
- **State backend bootstrap.** A small companion stack that creates the
  Cloudflare R2 bucket and credentials for the main stack's remote state.

## Maybe

- AWS module covering Route 53, S3 and IAM for teams whose primary cloud is AWS
  but who want the same shape.
- A "platform-in-a-box" wrapper that combines this repo with
  [k8s-ops-toolkit](https://github.com/sarmakska/k8s-ops-toolkit).
- Pulumi parity: the same modules expressed as Pulumi resources.

## Not planned

- A generic AWS-everything stack. There are good ones already.
- SaaS-specific modules (multi-tenant DB schema, and so on). Out of scope; this
  repo is infrastructure.

## Provider major upgrades

The Cloudflare provider `5.x` and the Vercel provider `5.x` are available but
introduce breaking resource renames. They are tracked as upgrade issues and
will land behind their own focused changes rather than silent bumps.

## How to contribute

Pull requests are welcome for new modules that follow the existing shape:
small, no abstractions, explicit inputs and outputs. For changes to existing
modules, please open an issue first; keeping these stable is the point.
