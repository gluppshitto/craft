// TODO DNS
resource "aws_route53_zone" "deanfogarty_link" {
  name = "deanfogarty.link"
}

resource "aws_route53_record" "a_record" {
  zone_id = aws_route53_zone.deanfogarty_link.zone_id
  name    = "deanfogarty.link"
  type    = "A"
  alias {
    name                   = module.nlb.lb_dns_name
    zone_id                = module.nlb.lb_zone_id
    evaluate_target_health = true
  }
}
