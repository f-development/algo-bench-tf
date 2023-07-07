data "aws_vpc" "main" {
  tags = {
    Name = "f-development"
  }
}

data "aws_subnet" "public_1" {
  tags = {
    Name = "f-development-public-1"
  }
}

data "aws_security_group" "main_default" {
  tags = {
    Name = "f-development-default"
  }
}
