terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.00"
    }
  }
  backend "s3" {
    region = "us-east-1"
    key    = "terraform"
  }
  required_version = ">= 1.5.0"
}
