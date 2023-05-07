data "aws_ami" "amz_linux" {
  most_recent = true

  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
}

resource "aws_autoscaling_group" "server_asg" {
  name = "server"

  desired_capacity = 1
  max_size         = 1
  min_size         = 0

  vpc_zone_identifier = local.private_subnets

  launch_template {
    id      = aws_launch_template.server_template.id
    version = "$Latest"
  }

  target_group_arns = [module.nlb.target_group_arns[0]]

  tag {
    key                 = "service"
    value               = "server"
    propagate_at_launch = true
  }
}

resource "aws_launch_template" "server_template" {
  name = "server"

  image_id      = data.aws_ami.amz_linux.id
  instance_type = "t3.xlarge"

  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [aws_security_group.server_sg.id]
  }

  iam_instance_profile {
    arn = aws_iam_instance_profile.server_profile.arn
  }

  user_data = filebase64("${path.module}/scripts/init.sh")

  tags = merge(
    { "name" = "server" },
    { "service" = "server" }
  )
}

resource "aws_iam_instance_profile" "server_profile" {
  name = "server-role"
  role = aws_iam_role.server_role.name
}

resource "aws_iam_role" "server_role" {
  name               = "server-role"
  assume_role_policy = data.aws_iam_policy_document.instance_assume_role_policy.json
  tags = merge(
    { "service" = "server" }
  )
}

data "aws_iam_policy_document" "instance_assume_role_policy" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "ssm_attachment_server" {
  role       = aws_iam_role.server_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "s3_attachment_server" {
  role       = aws_iam_role.server_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_security_group" "server_sg" {
  name        = "server-sg"
  description = "Server Security Group"
  vpc_id      = data.aws_vpc.main.id
  depends_on = [
    data.aws_vpc.main
  ]
  revoke_rules_on_delete = false

  egress = [
    {
      cidr_blocks = [
        "0.0.0.0/0",
      ]
      description      = ""
      from_port        = 0
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "-1"
      security_groups  = []
      self             = false
      to_port          = 0
    },
  ]

  ingress = [
    {
      cidr_blocks = [
        "0.0.0.0/0",
      ]
      description      = "Server ingress"
      from_port        = 25565
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "TCP"
      security_groups  = []
      self             = false
      to_port          = 25565
    },
  ]

  tags = merge(
    {
      "Name" = "server-sg"
    }
  )
}
