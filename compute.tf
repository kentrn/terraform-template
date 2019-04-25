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
      "sudo forever start server/app.js"
      ]

      connection {
          type = "ssh"
          user = "ec2-user"
          private_key = "${tls_private_key.instance_key.private_key_pem}"
          agent = false

      }
    }
}
