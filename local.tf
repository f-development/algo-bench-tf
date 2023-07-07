locals {
  prefix = "f-development-algo-bench"

  # vpc link support zones
  # https://docs.aws.amazon.com/apigateway/latest/developerguide/http-api-vpc-links.html
  az_ids_map = {
    ohio   = ["use2-az1", "use2-az2", "use2-az3"]
    seoul  = ["apne2-az1", "apne2-az2", "apne2-az3"]
    oregon = ["usw2-az1", "usw2-az2", "usw2-az3", "usw2-az4"]
  }

  tags = {
    "f:department"  = "f-development"
    "f:product"     = "algo-bench"
    "f:environment" = "n/a"
    "f:owner"       = "n/a"
  }
}
