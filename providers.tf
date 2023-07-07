# us-west-2 (Oregon) is one of the biggest regions with lowest cost
provider "aws" {
  assume_role {
    role_arn = var.role_arn
  }
  region = "us-west-2"
  default_tags {
    tags = local.tags
  }
}
