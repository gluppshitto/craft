module "nlb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 6.0"

  name = "nlb"

  load_balancer_type = "network"

  vpc_id  = data.aws_vpc.main.id
  subnets = local.public_subnets

  target_groups = [
    {
      name_prefix      = "pref-"
      backend_protocol = "TCP"
      backend_port     = 25565
      target_type      = "instance"
      targets          = {}
      health_check = {
        enabled             = true
        protocol            = "TCP"
        interval            = 30
        port                = "traffic-port"
        healthy_threshold   = 3
        unhealthy_threshold = 3
        timeout             = 5
      }
    }
  ]

  http_tcp_listeners = [
    {
      port               = 443
      protocol           = "TCP"
      target_group_index = 0
    }
  ]
}

resource "aws_autoscaling_attachment" "attachments" {
  autoscaling_group_name = aws_autoscaling_group.server_asg.name
  lb_target_group_arn    = module.nlb.target_group_arns[0]
}

resource "aws_vpc_endpoint" "ec2" {
  vpc_id            = data.aws_vpc.main.id
  service_name      = "com.amazonaws.eu-west-2.ec2"
  vpc_endpoint_type = "Interface"

  security_group_ids = [
    aws_security_group.server_sg.id,
  ]

  private_dns_enabled = true
}
