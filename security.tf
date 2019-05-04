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

resource "aws_security_group" "terraform_sg_elb" {
    name = "terraform_sg_elb"
    vpc_id = "${aws_vpc.terraform_vpc.id}"

    ingress = {
        protocol = "tcp"
        from_port = 80
        to_port = 80
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress = {
        protocol = "tcp"
        from_port = 443
        to_port = 443
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress = {
        protocol = "-1"
        from_port = 0
        to_port = 0
        cidr_blocks = ["0.0.0.0/0"]
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
      cidr_block = "${var.aws["vpc_cidr"]}${var.aws["vpc_cidr_mask"]}"
      from_port = 22
      to_port = 22
  }
  ingress {
      protocol = "tcp"
      rule_no = 110
      action = "allow"
      cidr_block = "${var.aws["vpc_cidr"]}${var.aws["vpc_cidr_mask"]}"
      from_port = 443
      to_port = 443
  }
  ingress {
      protocol = "tcp"
      rule_no = 120
      action = "allow"
      cidr_block = "${var.aws["vpc_cidr"]}${var.aws["vpc_cidr_mask"]}"
      from_port = 80
      to_port = 80
  }
  tags{
    Name = "terraform_nacl_private"      
  }
}

resource "aws_iam_instance_profile" "terraform_webserver_svc_profile" {
    name = "terraform_webserver_service_profile"
    role = "${var.aws["ws_service_role"]}"
}
