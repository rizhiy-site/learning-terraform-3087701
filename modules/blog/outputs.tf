output "environment_url" {
  value = module.blog.resource.blog_lb.dns_name
}