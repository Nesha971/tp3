# Configure the AWS Provider
provider "aws" {
  access_key = "AKIA6N4RZV6SM3CMCOHP"
  secret_key = "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"
  version = "~> 2.0"
  region  = "us-east-1"
}

resource "aws_instance" "EC2_OBERTAN" {
  ami = "${data.aws_ami.ubuntu.id}"
  instance_type = "t2.micro"
  tags ={
    Name = "EC2_OBERTAN"
  }
  provisioner "remote-exec" {
  	inline = [
            "sudo apt-get install openjdk-8-jdk",
            "sudo apt-get install maven",
            "sudo apt-get install git-all",
            "git clone https://github.com/spring-projects/spring-petclinic.git",
            "sudo ufw allow 8080/tcp"
        ]
  }
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-trusty-14.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_vpc" "ok_vpc"{
	cidr_block= "172.16.0.0/16"
	enable_dns_hostnames= true
	enable_dns_support = true

	tags = {
		Name = "ok_vpc"
	}
}

resource"aws_subnet" "ok_sn" {
	cidr_block="${cidrsubnet(aws_vpc.ok_vpc.cidr_block,3,1)}"
	vpc_id = "{aws_vpc.ok_vpc.id}"
	availability_zone = "eu-west-la"
	map_public_ip_on_launch = true

	tags = {
		Name = "ok_sn"
	}
}

resource "aws_internet_gateway" "ok_igw" {
	vpc_id ="${aws_vpc.ok_vpc.id}"
}

resource "aws_route_table" "ok_rt" {
	vpc_id= "${aws_vpc.ok_vpc.id}"

	route {
		cidr_block = "0.0.0.0/0"
		gateway_id = "${aws_internet_gateway.ok_igw.id}"
	}

	tags = {
		Name= "ok_rt"
	}
}

resource "aws_route_table_association" "ok_rta" {
	subnet_id = "${aws_subnet.ok_sn.id}"
	route_table_id = "${aws_route_table.ok_rt.id}"
}