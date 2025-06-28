resource "aws_vpc" "main" {
  cidr_block       = var.cidr_block
  instance_tenancy = "default"
  enable_dns_hostnames = true

  tags = merge(var.vpc_tags,local.common_tags,
    {
    Name = "${var.project}-${var.environment}"
    }
  ) 
}

resource "aws_internet_gateway" "roboshop" {
  vpc_id = aws_vpc.main.id

  tags = merge(var.ig_tags,local.common_tags,
  {
    Name = "${var.project}-${var.environment}"
    }
)
}

resource "aws_subnet" "public" {
  count = length(var.public_subnet_cidr_block)
  vpc_id     = aws_vpc.main.id
  cidr_block = var.public_subnet_cidr_block[count.index]
  availability_zone = local.azs_id[count.index]
  map_public_ip_on_launch = true

  tags = merge(local.common_tags,var.public_subnet_tags,{
    Name = "${var.project}-${var.environment}-public-${local.azs_id[count.index]}"
    })
}


resource "aws_subnet" "private" {
  count = length(var.private_cidr_blocks)
  vpc_id     = aws_vpc.main.id
  cidr_block = var.private_cidr_blocks[count.index]
  availability_zone = local.azs_id[count.index]

  tags = merge(var.private_subnet_tags,local.common_tags, 
  {
      name = "${var.project}-${var.environment}-priavte-${local.azs_id[count.index]}"
  })
}

resource "aws_subnet" "database" {
  count = length(var.database_cidrs)
vpc_id = aws_vpc.main.id
cidr_block = var.database_cidrs[count.index]
availability_zone = "${local.azs_id[count.index]}"
tags =  merge(local.common_tags,
{
Name = "${var.project}-${var.environment}-database-${local.azs_id[count.index]}"
})
}

resource "aws_eip" "nat" {
  domain = "vpc"

  tags = merge(local.common_tags,var.elastic_ip_tags, {
  Name = "${var.environment}-${var.project} "})
}

resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id

  tags = merge(local.common_tags,{
    Name = "nat-gateway"
  })

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.roboshop]
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

 
  tags = merge(local.common_tags,{
    Name = "publi-route-table"
  })
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

 
  tags = merge(local.common_tags,{
    Name = "private-route-table"
  })
}

resource "aws_route_table" "database" {
  vpc_id = aws_vpc.main.id

 
  tags = merge(local.common_tags,{
    Name = "database-route-table"
  })
}

resource "aws_route" "public" {
  route_table_id            = aws_route_table.public.id
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.roboshop.id
}

resource "aws_route" "private" {
  route_table_id            = aws_route_table.private.id
  destination_cidr_block    = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.main.id
}

resource "aws_route" "database" {
  route_table_id            = aws_route_table.database.id
  destination_cidr_block    = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.main.id
}

resource "aws_route_table_association" "public_associations" {
count = length(var.public_subnet_cidr_block)
subnet_id = aws_subnet.public[count.index].id
route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private_associations" {
count = length(var.private_cidr_blocks)
subnet_id = aws_subnet.private[count.index].id
route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "database_associations" {
count = length(var.database_cidrs)
subnet_id = aws_subnet.database[count.index].id
route_table_id = aws_route_table.database.id
}