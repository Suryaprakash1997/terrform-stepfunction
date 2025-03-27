# 🔹 Outputs
output "atlantis_external_alb_dns" {
  description = "DNS Name for External ALB"
  value       = module.alb.lb_dns_name
}

output "atlantis_internal_alb_dns" {
  description = "DNS Name for Internal ALB"
  value       = module.internal_alb.lb_dns_name
}