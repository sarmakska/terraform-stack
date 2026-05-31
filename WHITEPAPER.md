# terraform-stack whitepaper

## Why this exists

A solo engineer shipping a SaaS in 2026 typically uses six providers in the
first month: Vercel, Supabase, Cloudflare, GitHub, a domain registrar, and a
transactional email service. Each provider's web console is excellent. Wiring
them together by hand is correct, slow, and not reproducible.

`terraform-stack` is the wiring as code. Five commands and you have a fresh
stack standing up: a Vercel project linked to GitHub, a Supabase project
provisioned with auth configured and a `health` edge function deployed,
Cloudflare DNS pointed at Vercel with R2, KV and an edge Worker ready, and all
environment variables already set in the Vercel project.

## What this is not

This is not a generic IaC framework. It is a specific, opinionated collection
of modules for a specific stack:

- Frontend and serverless: **Vercel**
- Database, auth, realtime, storage, edge functions: **Supabase**
- DNS, object store, KV, edge Workers: **Cloudflare**
- Optional compute: **DigitalOcean**

If you are building on AWS-everything, Azure-everything, or GCP-everything,
this is not the right starter. There are excellent generic modules for each of
those.

## Why these four providers

The combination is what wins on cost and time-to-ship for a solo or small team
building a modern SaaS:

- Vercel removes operational overhead from the frontend.
- Supabase removes operational overhead from auth, database, realtime, storage,
  and edge functions.
- Cloudflare's R2 has zero egress fees, KV is cheap and fast, and Workers run
  code at the edge.
- DigitalOcean is the cheapest credible cloud for the long-running workloads
  that do not fit on Vercel.

You can swap pieces, such as a Neon module instead of Supabase or an AWS module
instead of DigitalOcean, without rewriting the rest. Each module is
independent.

## Design principles

### Each module is small enough to read

The largest module is still well under a hundred lines of Terraform. A reader
can hold the whole module in their head. Compare to a typical "enterprise"
Terraform module that wraps a provider in a thousand lines of abstraction; the
goal here is the opposite.

### No hidden state

The wiring between modules is explicit in `main.tf`. If the Vercel project
depends on the Supabase service-role key, the dependency is visible in the
`env_vars` block. There is no "platform" abstracting it away.

### Real resources, no placeholders

The Worker is a real deployable script bound to R2 and KV. The edge function is
a real Deno handler. The anon and service-role keys are read from the
management API rather than faked. If the repo says it provisions something, it
provisions it.

### Outputs are deliberate

Each module exports the values you actually need to plug into the next module or
your CI/CD. Sensitive outputs are marked sensitive. The outputs are stable
contracts; we treat changes to them as breaking.

### Sensible defaults, easy overrides

Every variable has a sensible default for the common case. Overrides are one
Terraform variable away. We do not parameterise everything upfront; we wait for
someone to hit the limit and then add the knob.

## What this saves

Time mostly. Setting this up by hand the first time is half a day for an
experienced engineer and two days for someone learning the providers. With this
repo it is twenty minutes.

Reproducibility is the real value. Production, staging, and a per-PR preview
environment can all run from the same Terraform with different variable files.
Without IaC, "make me a staging that mirrors prod" is itself a project; with
this repo it is a workspace.

Cost discipline as a side effect. The recommended config produces a stack that
costs roughly 30 to 80 pounds per month for a small SaaS. There is no hidden
capacity, no unused load balancers, and no forgotten resources in the bill.

## Safe applies

The repo ships two GitHub Actions workflows. CI validates and tests every push
and pull request with mocked providers, so no credentials are needed. The
deploy workflow plans and then applies, with the apply gated behind a protected
GitHub environment so a human approves before any real resource is touched.

## Where this falls short

- Multi-region. Each module assumes a single region. Multi-region SaaS is a
  different design, not a parameter to flip.
- Compliance frameworks. SOC2, ISO 27001 and HIPAA need workflow and
  documentation that IaC alone does not provide.
- Backups and DR. Supabase has its own backup story; the Cloudflare modules do
  not configure cross-region replication. Use the providers' native tools for
  this layer.

## Companion repos

- [k8s-ops-toolkit](https://github.com/sarmakska/k8s-ops-toolkit): observability
  and the Helm chart for the optional DigitalOcean Kubernetes path.
- [voice-agent-starter](https://github.com/sarmakska/voice-agent-starter),
  [agent-orchestrator](https://github.com/sarmakska/agent-orchestrator), and the
  rest of the Sarma open-source toolkit are example consumers of this stack.

## Licence

MIT. Use, fork, build on. Attribution appreciated.

## Built by Sarma Linux

Solo engineer in the UK. This is the IaC I run for my own projects, packaged so
others can run the same shape.
