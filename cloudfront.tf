locals {
  static_bucket_origin_id = "static-bucket"
}

resource "aws_cloudfront_origin_access_control" "static" {
  name                              = "static-bucket"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}


resource "aws_cloudfront_distribution" "this" {
  enabled             = true
  comment             = local.prefix
  default_root_object = "index.html"

  origin {
    domain_name              = module.s3__static.bucket_regional_domain_name
    origin_id                = local.static_bucket_origin_id
    origin_access_control_id = aws_cloudfront_origin_access_control.static.id
  }

  logging_config {
    include_cookies = false
    bucket          = module.s3__logging.bucket_domain_name
    prefix          = "cloudfront/"
  }

  default_cache_behavior {
    allowed_methods        = ["HEAD", "GET"]
    cached_methods         = ["HEAD", "GET"]
    target_origin_id       = local.static_bucket_origin_id
    cache_policy_id        = aws_cloudfront_cache_policy.cache_forever.id
    viewer_protocol_policy = "redirect-to-https"
    compress               = true
  }

  viewer_certificate {
    cloudfront_default_certificate = true
    ssl_support_method             = "sni-only"
    minimum_protocol_version       = "TLSv1.2_2021"
  }

  price_class = "PriceClass_All"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  depends_on = [aws_cloudfront_cache_policy.cache_forever]
}

resource "aws_cloudfront_cache_policy" "cache_forever" {
  name        = "${local.prefix}-default"
  default_ttl = 2147483647
  max_ttl     = 2147483647
  min_ttl     = 2147483647
  parameters_in_cache_key_and_forwarded_to_origin {
    cookies_config {
      cookie_behavior = "none"
    }
    headers_config {
      # Must not allow 'host' header
      # https://www.guri2o1667.work/entry/2023/01/16/%E3%80%90AWS%E3%80%91CloudFront%E7%B5%8C%E7%94%B1%E3%81%A7%E3%81%AE%E3%82%A2%E3%82%AF%E3%82%BB%E3%82%B9%E6%99%82%E3%81%AB%E3%80%8CSignatureDoesNotMatch%E3%80%8D%E3%81%AB%E3%82%88%E3%82%8A%E3%82%A2
      # https://www.codejam.info/2021/02/cloudfront-s3-signature-does-not-match.html
      header_behavior = "none"
    }
    query_strings_config {
      query_string_behavior = "all"
    }
  }
}

# resource "aws_cloudfront_origin_request_policy" "example" {
#   name    = "example-policy"
#   comment = "example comment"
#   cookies_config {
#     cookie_behavior = "whitelist"
#     cookies {
#       items = ["example"]
#     }
#   }
#   headers_config {
#     header_behavior = "whitelist"
#     headers {
#       items = ["example"]
#     }
#   }
#   query_strings_config {
#     query_string_behavior = "whitelist"
#     query_strings {
#       items = ["example"]
#     }
#   }
# }

resource "aws_cloudfront_monitoring_subscription" "this" {
  distribution_id = aws_cloudfront_distribution.this.id

  monitoring_subscription {
    realtime_metrics_subscription_config {
      realtime_metrics_subscription_status = "Enabled"
    }
  }
}

resource "aws_s3_bucket_policy" "origin_access_control" {
  bucket = module.s3__static.id
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : {
      "Effect" : "Allow",
      "Principal" : {
        "Service" : "cloudfront.amazonaws.com"
      },
      "Action" : "s3:GetObject",
      "Resource" : "${module.s3__static.arn}/*",
      "Condition" : {
        "StringEquals" : {
          "AWS:SourceArn" : aws_cloudfront_distribution.this.arn
        }
      }
    }
  })
}
