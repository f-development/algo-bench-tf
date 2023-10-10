locals {
  prefix = "f-development-algo-bench"

  vpc_cidr             = "10.0.0.0/16"
  vpc_public_cidr      = "10.0.0.0/20"
  vpc_private_cidr     = "10.0.16.0/20"
  subnet_cidrs_public  = cidrsubnets(local.vpc_public_cidr, 4, 4, 4, 4, 4)
  subnet_cidrs_private = cidrsubnets(local.vpc_private_cidr, 4, 4, 4, 4, 4)

  # vpc link support zones
  # https://docs.aws.amazon.com/apigateway/latest/developerguide/http-api-vpc-links.html
  az_ids = ["usw2-az1", "usw2-az2", "usw2-az3", "usw2-az4"]

  tags = {
    "f:department"  = "f-development"
    "f:product"     = "algo-bench"
    "f:environment" = "n/a"
    "f:owner"       = "n/a"
  }
}
