variable "project" {
  description = "Project name"
  type = object({
    name = string
  })
  default = {
    name = "Learning project"
  }
}

variable "instance_type" {
  description = "Type of EC2 instance to provision"
  default     = "t3.nano"
}
variable "ami_filter" {
  description = "Name filter and owner for AMI"
  type  = object({
    name   = string
    owner  = string
  })
  default = {
    name   = "bitnami-tomcat-*-x86_64-hvm-ebs-nami"
    owner  = "979382823631" # Bitnami
  }
}

variable "environment" {
  description = "The environment for the deployment"
  type        = object({
    name           = string
    network_prefix = string
  })
  default     = {
    name           = "dev"
    network_prefix = "10.0"
  }
}

variable "asg_min_size" {
  description = "Minimum size of the Auto Scaling group"
  default     = 1
  type        = number
}
variable "asg_max_size" {
  description = "Maximum size of the Auto Scaling group"
  default     = 2
  type        = number  
}
