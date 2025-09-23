data "aws_ami" "app_ami" {
  most_recent = true

  filter {
    name   = "name"
    values = ["bitnami-tomcat-*-x86_64-hvm-ebs-nami"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["979382823631"] # Bitnami
}

data "aws_vpc" "default" {
  default = true
}

module "blog_vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "dev"
  cidr = "10.0.0.0/16"

  azs             = ["us-west-2a", "us-west-2b", "us-west-2c"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  tags = {
    Terraform = "true"
    Environment = "dev"
  }
}

module "autoscaling" {
  source  = "terraform-aws-modules/autoscaling/aws"
  version = "9.0.1"
  
  name     = "blog"
  min_size = 1
  max_size = 2

  vpc_zone_identifier = module.blog_vpc.public_subnets
  security_groups     = [module.blog_sg.security_group_id]
  
  image_id      = data.aws_ami.app_ami.id
  instance_type = var.instance_type
}

# Attach the Auto Scaling Group to the target group
resource "aws_autoscaling_attachment" "asg_attachment" {
  autoscaling_group_name = module.autoscaling.autoscaling_group_name
  lb_target_group_arn   = module.blog_alb.target_groups["blog"].arn
}

module "blog_alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "10.0.0"

  name = "blog-alb"

  vpc_id             = module.blog_vpc.vpc_id
  subnets            = module.blog_vpc.public_subnets
  security_groups    = [module.blog_sg.security_group_id]

  target_groups = {
    blog = {
      name_prefix          = "blog-"
      backend_protocol     = "HTTP"
      backend_port         = 80
      target_type         = "instance"
      preserve_client_ip  = true
      deregistration_delay = 30

      health_check = {
        enabled             = true
        interval           = 30
        path               = "/"
        port               = "traffic-port"
        healthy_threshold   = 3
        unhealthy_threshold = 3
        timeout            = 6
        matcher            = "200-399"
      }

      # Disable automatic target attachment since we're using ASG
      create_attachment = false
    }
  }

  listeners = {
    http = {
      port            = 80
      protocol        = "HTTP"
      default_action = {
        type = "forward"
      }
      forward = {
        target_groups = [
          {
            target_group_key = "blog"
          }
        ]
      }
    }
  }

  tags = {
    Environment = "Development"
    Project     = "Example"
  }
}

module "blog_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.3.0"

  vpc_id = module.blog_vpc.vpc_id
  name   = "blog"
  
  ingress_rules      = ["http-80-tcp", "https-443-tcp"]
  ingress_cidr_blocks = ["0.0.0.0/0"]

  egress_rules      = ["all-all"]
  egress_cidr_blocks = ["0.0.0.0/0"]

}
