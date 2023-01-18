output "json" {
  description = "Rendered container definition as JSON output."
  value       = jsonencode(local.final_container_definition)
}

output "hcl" {
  description = "Rendered container definition as HCL object."
  value       = local.final_container_definition
}
