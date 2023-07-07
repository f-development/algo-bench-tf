resource "aws_ecr_repository" "mysql" {
  name                 = "${local.prefix}-mysql"
  image_tag_mutability = "MUTABLE"
}

resource "aws_ecr_repository" "rails" {
  name                 = "${local.prefix}-rails"
  image_tag_mutability = "MUTABLE"
}