resource "aws_ami_from_instance" "terraform_ami_nodejs" {
    name = "terraform_ami_nodejs"
    source_instance_id = "${aws_instance.terraform_instance.id}"
}

resource "aws_launch_configuration" "terraform_launch_config" {
    name = "terraform_launch_config"
    image_id = "${aws_ami_from_instance.terraform_ami_nodejs.id}"
    instance_type = "t2.micro"
    security_groups = ["${aws_security_group.terraform_sg_webserver.id}"]
    associate_public_ip_address = true
    lifecycle {
        create_before_destroy = true
    }
}

resource "aws_autoscaling_group" "terraform_autoscale_group" {
    name = "terraform_autoscale_group"
    max_size = "${var.aws["asg_max"]}"
    min_size = "${var.aws["asg_min"]}"
    health_check_grace_period = 300
    health_check_type = "EC2"
    desired_capacity = "${var.aws["asg_desired"]}"
    vpc_zone_identifier = ["${aws_subnet.terraform_subnet_public_1.id}", "${aws_subnet.terraform_subnet_public_2.id}"]
    launch_configuration = "${aws_launch_configuration.terraform_launch_config.name}"
    termination_policies = ["NewestInstance"]
}

resource "aws_elb" "terraform_loadbalancer" {
    name  = "terraform-loadbalancer"
    subnets = ["${aws_subnet.terraform_subnet_public_1.id}", "${aws_subnet.terraform_subnet_public_2.id}"]
    security_groups = ["${aws_security_group.terraform_sg_elb.id}"]
    listener{
        instance_port = 80
        instance_protocol = "HTTP"
        lb_port = 80
        lb_protocol = "HTTP"
    }

    health_check {
        healthy_threshold = 2
        unhealthy_threshold = 2
        timeout = 3
        target = "TCP:80"
        interval = 30
    }
    tags {
        Name = "terraform_loadbalancer"
    }
}

resource "aws_autoscaling_attachment" "terraform_autoscaling_attachment" {
    autoscaling_group_name = "${aws_autoscaling_group.terraform_autoscale_group.id}"
    elb = "${aws_elb.terraform_loadbalancer.id}"
}
resource "tls_private_key" "instance_key" {
    algorithm = "RSA"
    rsa_bits = 4096
}

resource "aws_key_pair" "terraform_generated_key" {
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
    ami = "${var.aws["ami_id"]}"
    instance_type = "t2.micro"
    subnet_id = "${aws_subnet.terraform_subnet_public_1.id}"
    associate_public_ip_address = true
    vpc_security_group_ids = ["${aws_security_group.terraform_sg_webserver.id}"]
    tags {
        Name = "terraform_instance"
    }
    key_name = "${aws_key_pair.terraform_generated_key.key_name}"
    provisioner "remote-exec" {
      inline = ["sudo yum update -y",
      "curl -sL https://rpm.nodesource.com/setup_10.x | sudo bash - ",
      "sudo yum install nodejs git -y",
      "git clone https://github.com/kentrn/vue-express-template.git",
      "cd vue-express-template/",
      "npm install && sudo npm install forever -g",
      "touch .env && echo \"PORT=80\" >> .env",
      "sudo forever start app.js"
      ]

      connection {
          type = "ssh"
          user = "ec2-user"
          private_key = "${tls_private_key.instance_key.private_key_pem}"
          agent = false

      }
    }
}
