output "json" {
  description = "Rendered container definition as JSON output."
  value       = module.full.json
}

output "hcl" {
  description = "Rendered container definition as HCL object."
  value       = module.full.hcl
}
