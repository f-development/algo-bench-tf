resource "aws_vpc" "main" {
  cidr_block           = local.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = local.prefix
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = local.prefix
  }
}

resource "aws_subnet" "public" {
  count                   = length(local.az_ids)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = local.subnet_cidrs_public[count.index]
  availability_zone_id    = local.az_ids[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "${local.prefix}-public-${substr(local.az_ids[count.index], -1, 1)}"
  }
}

resource "aws_subnet" "private" {
  count                = length(local.az_ids)
  vpc_id               = aws_vpc.main.id
  cidr_block           = local.subnet_cidrs_private[count.index]
  availability_zone_id = local.az_ids[count.index]

  tags = {
    Name = "${local.prefix}-private-${substr(local.az_ids[count.index], -1, 1)}"
  }
}

resource "aws_db_subnet_group" "public" {
  name       = "${local.prefix}-public"
  subnet_ids = aws_subnet.public.*.id
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
  tags = {
    Name = "${local.prefix}-public"
  }
}

resource "aws_route_table_association" "public" {
  count = length(local.az_ids)

  subnet_id      = element(aws_subnet.public.*.id, count.index)
  route_table_id = aws_route_table.public.id
}
