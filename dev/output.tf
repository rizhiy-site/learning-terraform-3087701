output "blog_url" {
  description = "URL of the blog application load balancer"
  value       = module.blog.alb_dns_name
}