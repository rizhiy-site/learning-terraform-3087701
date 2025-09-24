output "blog_url" {
  description = "URL of the blog application load balancer"
  value       = module.qa.alb_dns_name
}
