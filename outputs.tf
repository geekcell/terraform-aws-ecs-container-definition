output "json" {
  description = "Rendered container definition as JSON output."
  value       = data.jq_query.main.result
}

output "hcl" {
  description = "Rendered container definition as HCL object."
  value       = jsondecode(data.jq_query.main.result)
}
