terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region = "us-west-2"
}

resource "aws_security_group" "minecraft" {
  ingress {
    description = "Receive SSH from home."
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["76.32.192.131/32"]
  }
  ingress {
    description = "Receive Minecraft from everywhere."
    from_port   = 25565
    to_port     = 25565
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    description = "Send everywhere."
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "Minecraft"
  }
}

resource "aws_key_pair" "home" {
  key_name   = "Home"
  public_key = file("./id_rsa.pub")
}

resource "aws_instance" "app_server" {
  ami                         = "ami-064803387adcb64b3"
  instance_type               = "t2.small"
  vpc_security_group_ids      = [aws_security_group.minecraft.id]
  associate_public_ip_address = true
  key_name                    = aws_key_pair.home.key_name
  user_data                   = <<-EOF
    #!/bin/bash
    sudo yum -y update
    sudo rpm --import https://yum.corretto.aws/corretto.key
    sudo curl -L -o /etc/yum.repos.d/corretto.repo https://yum.corretto.aws/corretto.repo
    sudo yum install -y java-17-amazon-corretto-devel.x86_64
    curl -o server.jar https://piston-data.mojang.com/v1/objects/84194a2f286ef7c14ed7ce0090dba59902951553/server.jar
    java -Xmx1024M -Xms1024M -jar server.jar nogui
    sed -i 's/eula=false/eula=true/' eula.txt
    java -Xmx1024M -Xms1024M -jar server.jar nogui
    EOF
  tags = {
    Name = "Minecraft"
  }
}

output "instance_ip_addr" {
  value = aws_instance.app_server.public_ip
}
