provider "aws" {
  access_key = var.aws["access_key"]
  secret_key = var.aws["secret_key"]
  region     = var.aws["region"]
}

resource "aws_vpc" "terraform_vpc" {
  cidr_block = "${var.aws["vpc_cidr"]}${var.aws["vpc_cidr_mask"]}"
  tags = {
    Name = "terraform_vpc"
  }
}

resource "aws_subnet" "terraform_subnet_public_1" {
  vpc_id            = aws_vpc.terraform_vpc.id
  cidr_block        = "172.16.0.0${var.aws["subnet_cidr_mask"]}"
  availability_zone = "${var.aws["region"]}a"
  tags = {
    Name = "terraform_subnet_public_2"
  }
}

resource "aws_subnet" "terraform_subnet_public_2" {
  vpc_id            = aws_vpc.terraform_vpc.id
  cidr_block        = "172.16.2.0${var.aws["subnet_cidr_mask"]}"
  availability_zone = "${var.aws["region"]}b"
  tags = {
    Name = "terraform_subnet_public_2"
  }
}

resource "aws_subnet" "terraform_subnet_private_1" {
  vpc_id            = aws_vpc.terraform_vpc.id
  cidr_block        = "172.16.1.0${var.aws["subnet_cidr_mask"]}"
  availability_zone = "${var.aws["region"]}a"
  tags = {
    Name = "terraform_subnet_private_1"
  }
}

resource "aws_subnet" "terraform_subnet_private_2" {
  vpc_id            = aws_vpc.terraform_vpc.id
  cidr_block        = "172.16.3.0${var.aws["subnet_cidr_mask"]}"
  availability_zone = "${var.aws["region"]}b"
  tags = {
    Name = "terraform_subnet_private_2"
  }
}

resource "aws_default_route_table" "terraform_default_route_table" {
  default_route_table_id = aws_vpc.terraform_vpc.main_route_table_id
  tags = {
    Name = "default_route_table"
  }
}

resource "aws_route_table" "terraform_route_table_public" {
  vpc_id = aws_vpc.terraform_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.terraform_internet_gateway.id
  }
  tags = {
    Name = "terraform_public_route_table"
  }
}

resource "aws_route_table" "terraform_route_table_private" {
  vpc_id = aws_vpc.terraform_vpc.id
  tags = {
    Name = "terraform_private_route_table"
  }
}

resource "aws_route_table_association" "terraform_public_assoc_1" {
  subnet_id      = aws_subnet.terraform_subnet_public_1.id
  route_table_id = aws_route_table.terraform_route_table_public.id
}

resource "aws_route_table_association" "terraform_public_assoc_2" {
  subnet_id      = aws_subnet.terraform_subnet_public_2.id
  route_table_id = aws_route_table.terraform_route_table_public.id
}

resource "aws_route_table_association" "terraform_private_assoc_1" {
  subnet_id      = aws_subnet.terraform_subnet_private_1.id
  route_table_id = aws_route_table.terraform_route_table_private.id
}

resource "aws_route_table_association" "terraform_private_assoc_2" {
  subnet_id      = aws_subnet.terraform_subnet_private_2.id
  route_table_id = aws_route_table.terraform_route_table_private.id
}

resource "aws_internet_gateway" "terraform_internet_gateway" {
  vpc_id = aws_vpc.terraform_vpc.id
  tags = {
    Name = "terraform_internet_gateway"
  }
}

