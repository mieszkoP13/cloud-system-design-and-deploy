provider "aws" {
    region = "us-east-1"
    profile = "default"
}

resource "aws_instance" "tic-tac-toe" {
    ami = "ami-04e5276ebb8451442"
    instance_type = "t2.micro"
    tags = {
        Name = "tic-tac-toe"
    }
    key_name = "key_pair_1"
    availability_zone = "us-east-1a"
    associate_public_ip_address = true
    subnet_id = aws_subnet.subnet_a.id

    vpc_security_group_ids = [aws_security_group.tic-tac-toe_sg.id]

    user_data = "${file("install-app.sh")}"
}

resource "aws_vpc" "tic-tac-toe_vpc" {
    cidr_block = "10.0.0.0/16"
    tags = {
        Name = "tic-tac-toe_vpc"
    }
}

resource "aws_security_group" "tic-tac-toe_sg" {
    name        = "tic-tac-toe_sg"
    description = "tic-tac-toe_security_group"

    vpc_id = aws_vpc.tic-tac-toe_vpc.id

    ingress {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port   = 3000
        to_port     = 3000
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port   = 5173
        to_port     = 5173
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "tic-tac-toe_web_security_group"
    }
}

resource "aws_internet_gateway" "tic-tac-toe-igw" {
    vpc_id = aws_vpc.tic-tac-toe_vpc.id

    tags = {
        Name = "tic-tac-toe_internet_gateway"
    }
}

resource "aws_route_table" "tic-tac-toe_prt" {
    vpc_id = aws_vpc.tic-tac-toe_vpc.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.tic-tac-toe-igw.id
    }

    tags = {
        Name = "tic-tac-toe_pubic_route_table"
    }
}

resource "aws_subnet" "subnet_a" {
    vpc_id                  = aws_vpc.tic-tac-toe_vpc.id
    cidr_block              = "10.0.0.0/24"
    availability_zone       = "us-east-1a"
    map_public_ip_on_launch = true

    tags = {
        Name = "Subnet A"
    }
}

resource "aws_route_table_association" "a" {
    subnet_id      = aws_subnet.subnet_a.id
    route_table_id = aws_route_table.tic-tac-toe_prt.id
}
