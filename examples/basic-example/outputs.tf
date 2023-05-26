output "json" {
  description = "Rendered container definition as JSON output."
  value       = module.basic-example.json
}

output "hcl" {
  description = "Rendered container definition as HCL object."
  value       = module.basic-example.hcl
}
