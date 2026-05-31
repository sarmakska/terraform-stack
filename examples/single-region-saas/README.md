# Single-region SaaS example

The smallest realistic deployment of `terraform-stack`: a Next.js app on
Vercel, a Supabase database, and Cloudflare DNS plus R2 and KV. No
long-running compute, so the monthly cost stays low.

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
