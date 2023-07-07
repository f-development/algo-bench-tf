resource "aws_route53_zone" "this" {
  name = local.domain
}

resource "aws_route53_record" "cloudfront" {
  zone_id = aws_route53_zone.this.zone_id
  name    = local.domain
  type    = "A"
  alias {
    name                   = aws_cloudfront_distribution.this.domain_name
    zone_id                = aws_cloudfront_distribution.this.hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "cert_prd" {
  count   = var.env == "prd" ? 1 : 0
  zone_id = aws_route53_zone.this.zone_id
  name    = "_14656cd2d2c09cba9f71239d651c540c.activity.ms.flicspy.com."
  type    = "CNAME"
  records = ["_7d41ee1a46bfce834adc999914fc90fd.hnyzmxtzsz.acm-validations.aws."]
  ttl     = 300
}

resource "aws_route53_record" "cert_stg_1" {
  count   = var.env == "stg-1" ? 1 : 0
  zone_id = aws_route53_zone.this.zone_id
  name    = "_2df9ca7922453c7b5867d357dc5375d2.activity.ms.flicspy-stg-1.com."
  type    = "CNAME"
  records = ["_e2ff1dc1c4c4a8f0e73ebe190e16c78a.dbspspvlns.acm-validations.aws."]
  ttl     = 300
}

