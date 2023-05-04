data "aws_vpc" "main" {
  id = "vpc-0083e7e782d59eb9c"
}

data "aws_subnets" "subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.main.id]
  }
}

data "aws_subnet" "subnet" {
  for_each = toset(data.aws_subnets.subnets.ids)
  id       = each.value
}

locals {
  all_subnets     = [for i in toset(data.aws_subnets.subnets.ids) : data.aws_subnet.subnet[i]]
  public_subnets  = setsubtract(null, [for subnet in local.all_subnets : length(split("10.0.10", subnet.cidr_block)) > 1 ? null : subnet.id])
  private_subnets = setsubtract(null, [for subnet in local.all_subnets : length(split("10.0.10", subnet.cidr_block)) > 1 ? subnet.id : null])
}

output "public_subnets" {
  value = local.public_subnets
}

output "private_subnets" {
  value = local.private_subnets
}

