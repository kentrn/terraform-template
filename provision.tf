
provider "aws" {
  access_key = "${var.aws["access_key"]}"
  secret_key = "${var.aws["secret_key"]}"
  region = "${var.aws["region"]}"
}

resource "aws_vpc" "terraform_vpc" {
    cidr_block = "${var.aws["vpc_cidr"]}"
    tags {
        Name = "terraform_vpc"
    }
}

resource "aws_subnet" "terraform_subnet_public_1" {
  vpc_id = "${aws_vpc.terraform_vpc.id}"
  cidr_block = "172.16.0.0/24"
  availability_zone = "${var.aws["region"]}a"
  tags{
      Name = "terraform_subnet_public_2"
  }
}

resource "aws_subnet" "terraform_subnet_public_2" {
  vpc_id = "${aws_vpc.terraform_vpc.id}"
  cidr_block = "172.16.2.0/24"
  availability_zone = "${var.aws["region"]}b"
  tags{
      Name = "terraform_subnet_public_2"
  }
}

resource "aws_subnet" "terraform_subnet_private_1" {
    vpc_id = "${aws_vpc.terraform_vpc.id}"
    cidr_block = "172.16.1.0/24"
  availability_zone = "${var.aws["region"]}a"
    tags {
        Name = "terraform_subnet_private_1"
    }
}

resource "aws_subnet" "terraform_subnet_private_2" {
    vpc_id = "${aws_vpc.terraform_vpc.id}"
    cidr_block = "172.16.3.0/24"
  availability_zone = "${var.aws["region"]}b"
    tags {
        Name = "terraform_subnet_private_2"
    }
}


resource "aws_default_route_table" "terraform_default_route_table" {
    default_route_table_id = "${aws_vpc.terraform_vpc.main_route_table_id}"
    tags {
        Name = "default_route_table"
    }
}

resource "aws_route_table" "terraform_route_table_public" {
    vpc_id = "${aws_vpc.terraform_vpc.id}"
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_internet_gateway.terraform_internet_gateway.id}"
    }
    tags {
        Name = "terraform_public_route_table"
    }
}

resource "aws_route_table" "terraform_route_table_private" {
    vpc_id = "${aws_vpc.terraform_vpc.id}"
    tags {
        Name = "terraform_private_route_table"
    }
}

resource "aws_route_table_association" "terraform_public_assoc_1" {
        subnet_id = "${aws_subnet.terraform_subnet_public_1.id}"
        route_table_id = "${aws_route_table.terraform_route_table_public.id}"  
}

resource "aws_route_table_association" "terraform_public_assoc_2" {
        subnet_id = "${aws_subnet.terraform_subnet_public_2.id}"
        route_table_id = "${aws_route_table.terraform_route_table_public.id}"  
}

resource "aws_route_table_association" "terraform_private_assoc_1" {
    subnet_id = "${aws_subnet.terraform_subnet_private_1.id}"
    route_table_id = "${aws_route_table.terraform_route_table_private.id}"
}

resource "aws_route_table_association" "terraform_private_assoc_2" {
    subnet_id = "${aws_subnet.terraform_subnet_private_2.id}"
    route_table_id = "${aws_route_table.terraform_route_table_private.id}"
}

resource "aws_internet_gateway" "terraform_internet_gateway" {
    vpc_id = "${aws_vpc.terraform_vpc.id}"
    tags {
        Name = "terraform_internet_gateway"
    }
}

resource "aws_security_group" "terraform_sg_webserver" {
    name = "terraform_sg_webserver"
    description = "security group for terraform instance"
    vpc_id = "${aws_vpc.terraform_vpc.id}"

    ingress {
        protocol = "tcp"
        from_port = 22
        to_port = 22
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        protocol = "tcp"
        from_port = 0
        to_port = 65535
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        from_port = 443
        to_port = 443
    }
    ingress {
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        from_port = 80
        to_port = 80
    }
}

resource "aws_default_network_acl" "terraform_default_nacl" {
    default_network_acl_id = "${aws_vpc.terraform_vpc.default_network_acl_id}"
    tags{
        Name = "default_nacl"
    }
}

resource "aws_network_acl" "terraform_nacl_public" {
  vpc_id = "${aws_vpc.terraform_vpc.id}"
  subnet_ids = ["${aws_subnet.terraform_subnet_public_1.id}", "${aws_subnet.terraform_subnet_public_2.id}"]
  egress {
      protocol = "tcp"
      rule_no = 100
      action = "allow"
      cidr_block = "0.0.0.0/0"
      from_port = 0
      to_port = 65535
  }
  ingress {
      protocol = "tcp"
      rule_no = 100
      action = "allow"
      cidr_block = "0.0.0.0/0"
      from_port = 22
      to_port = 22
  }
  ingress {
      protocol = "tcp"
      rule_no = 110
      action = "allow"
      cidr_block = "0.0.0.0/0"
      from_port = 443
      to_port = 443
  }
  ingress {
      protocol = "tcp"
      rule_no = 120
      action = "allow"
      cidr_block = "0.0.0.0/0"
      from_port = 80
      to_port = 80
  }
  ingress {
      protocol = "tcp"
      rule_no = 130
      action = "allow"
      cidr_block = "0.0.0.0/0"
      from_port = 1024
      to_port = 65535
  }
  tags{
    Name = "terraform_nacl_public"      
  }
}

resource "aws_network_acl" "terraform_nacl_private" {
  vpc_id = "${aws_vpc.terraform_vpc.id}"
  subnet_ids = ["${aws_subnet.terraform_subnet_private_1.id}", "${aws_subnet.terraform_subnet_private_2.id}"]
  egress {
      protocol = "tcp"
      rule_no = 100
      action = "allow"
      cidr_block = "0.0.0.0/0"
      from_port = 1024
      to_port = 65535
  }
  ingress {
      protocol = "tcp"
      rule_no = 100
      action = "allow"
      cidr_block = "172.16.0.0/16"
      from_port = 22
      to_port = 22
  }
  ingress {
      protocol = "tcp"
      rule_no = 110
      action = "allow"
      cidr_block = "172.16.0.0/16"
      from_port = 443
      to_port = 443
  }
  ingress {
      protocol = "tcp"
      rule_no = 120
      action = "allow"
      cidr_block = "172.16.0.0/16"
      from_port = 80
      to_port = 80
  }
  tags{
    Name = "terraform_nacl_private"      
  }
}


resource "tls_private_key" "instance_key" {
    algorithm = "RSA"
    rsa_bits = 4096
}

resource "aws_key_pair" "aws_generated_key" {
    key_name = "terraform_generated_key"
    public_key = "${tls_private_key.instance_key.public_key_openssh}"
}

resource "local_file" "terraform_generated_key" {
    content = "${tls_private_key.instance_key.private_key_pem}"
    filename = "terraform_generated_key.pem"
    provisioner "local-exec" {
        command = "chmod 400 terraform_generated_key.pem"
    }
}

resource "aws_instance" "terraform_instance" {
    ami = "ami-04481c741a0311bbb"
    instance_type = "t2.micro"
    subnet_id = "${aws_subnet.terraform_subnet_public_1.id}"
    associate_public_ip_address = true
    vpc_security_group_ids = ["${aws_security_group.terraform_sg_webserver.id}"]
    tags {
        Name = "terraform_instance"
    }
    key_name = "${aws_key_pair.aws_generated_key.key_name}"
    provisioner "remote-exec" {
      inline = ["sudo yum update -y",
      "curl -sL https://rpm.nodesource.com/setup_10.x | sudo bash - ",
      "sudo yum install nodejs -y"
      ]

      connection {
          type = "ssh"
          user = "ec2-user"
          private_key = "${tls_private_key.instance_key.private_key_pem}"
          agent = false

      }
    }
}
