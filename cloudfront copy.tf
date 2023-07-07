resource "aws_cloudfront_distribution" "this" {
  enabled = true
  comment = local.prefix
  aliases = [local.domain]

  # Disable to save cost
  # web_acl_id = aws_wafv2_web_acl.main.arn

  origin {
    domain_name = "latency-routing.${local.domain}"
    origin_id   = "latency-routing"
    # origin_access_control_id = "216adef6-5c7f-47e4-b989-5492eafa07d3"  # Pass all
    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  logging_config {
    include_cookies = false
    bucket          = module.s3__logging.bucket_domain_name
    prefix          = "cloudfront/"
  }

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT", "DELETE", ]
    cached_methods         = ["HEAD", "GET"]
    target_origin_id       = "latency-routing"
    cache_policy_id        = aws_cloudfront_cache_policy.read_public_data.id
    viewer_protocol_policy = "redirect-to-https"
  }

  price_class = "PriceClass_All"

  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate.virginia2.id
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
}

resource "aws_cloudfront_cache_policy" "read_public_data" {
  name        = "${local.prefix}-default"
  default_ttl = 15
  max_ttl     = 3600
  min_ttl     = 5
  parameters_in_cache_key_and_forwarded_to_origin {
    cookies_config {
      cookie_behavior = "none"
    }
    headers_config {
      header_behavior = "whitelist"
      headers {
        items = ["Host"]
      }
    }
    query_strings_config {
      query_string_behavior = "all"
    }
  }
}

resource "aws_cloudfront_monitoring_subscription" "this" {
  distribution_id = aws_cloudfront_distribution.this.id

  monitoring_subscription {
    realtime_metrics_subscription_config {
      realtime_metrics_subscription_status = "Enabled"
    }
  }
}