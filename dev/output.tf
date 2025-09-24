output "blog_url" {
  description = "URL of the blog application load balancer"
  value       = module.dev.alb_dns_name
}