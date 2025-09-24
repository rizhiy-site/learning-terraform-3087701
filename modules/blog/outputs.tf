output "environment_url" {
  value = resource.aws_lb.blog.dns_name
}