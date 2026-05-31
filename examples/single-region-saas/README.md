# Single-region SaaS example

The smallest realistic deployment of `terraform-stack`: a Next.js app on
Vercel, a Supabase project with auth configured and a `health` edge function,
and Cloudflare DNS plus R2, KV and an edge Worker. No long-running compute, so
the monthly cost stays low.

## Use it

```bash
cp terraform.tfvars.example terraform.tfvars
# edit terraform.tfvars with your tokens and project details
terraform init
terraform plan
terraform apply
```

This invocation sources the repository root as a module, so it always
tracks the modules in this repo. Copy the directory out if you want to
pin it to a tagged release instead.
