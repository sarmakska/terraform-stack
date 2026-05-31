# Root outputs. These are stable contracts: changes are treated as breaking.
# Plug them into CI deploy hooks, secret stores, or downstream stacks.

output "vercel_project_id" {
  description = "Vercel project id, useful for CI deploy hooks"
  value       = module.vercel.project_id
}

output "supabase_project_id" {
  description = "Supabase project reference id"
  value       = module.supabase.project_id
}

output "supabase_api_url" {
  description = "Supabase REST/GraphQL API base URL"
  value       = module.supabase.api_url
}

output "supabase_anon_key" {
  description = "Supabase anonymous API key, already wired into the Vercel env"
  value       = module.supabase.anon_key
  sensitive   = true
}

output "supabase_service_role_key" {
  description = "Supabase service-role API key, already wired into the Vercel env"
  value       = module.supabase.service_role_key
  sensitive   = true
}

output "supabase_edge_functions" {
  description = "Slugs of the deployed Supabase edge functions"
  value       = module.supabase.edge_function_slugs
}

output "database_password" {
  description = "Generated Supabase database password (stored in state)"
  value       = module.supabase.database_password
  sensitive   = true
}

output "r2_bucket" {
  description = "Cloudflare R2 bucket name for object storage"
  value       = module.cloudflare.r2_bucket
}

output "kv_namespace" {
  description = "Cloudflare Workers KV namespace id"
  value       = module.cloudflare.kv_namespace
}

output "worker_name" {
  description = "Deployed Cloudflare Worker script name (empty when disabled)"
  value       = module.cloudflare.worker_name
}

output "worker_route" {
  description = "Route pattern bound to the Cloudflare Worker (empty when disabled)"
  value       = module.cloudflare.worker_route
}

output "droplet_ip" {
  description = "IPv4 address of the optional DigitalOcean droplet (null when disabled)"
  value       = var.enable_droplet ? module.digitalocean[0].ipv4 : null
}
