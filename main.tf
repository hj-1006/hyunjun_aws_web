# ===========================
# hyunjun AWS Provider region
# ===========================

# soule region
provider "aws" {
    region = "ap-northeast-2"
}


# ==========================================
# create VPC network
# ========================================== 
resource "aws_vpc" "jun_vpc" {
  cidr_block           = "192.168.0.0/16"  
  enable_dns_hostnames = true

  tags = {
    Name = "Hyunjun-VPC"
  }
}

resource "aws_internet_gateway" "jun_igw" {
    vpc_id = aws_vpc.jun_vpc.id

  tags = {
    Name = "Hyunjun-Gateway"
  }
}

# ==========================================
# Subnet Settings
# ==========================================

# Public Subnet
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.jun_vpc.id
  cidr_block              = "192.168.200.0/24"
  availability_zone       = "ap-northeast-2a"
  map_public_ip_on_launch = true # IP Auto

  tags = {
    Name = "AION-Public-Zone"
  }
}

# Connect Public Routing table & IGW
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.jun_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.jun_igw.id
  }

  tags = {
    Name = "Hyunjun-Public-RouteTable"
  }
}

resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

# ==========================================
# Security Group
# ==========================================
resource "aws_security_group" "web_sg" {
  name        = "jun-web-server-sg"
  description = "Allow selective traffic for Node.js REST API"
  vpc_id      = aws_vpc.jun_vpc.id

  # inside Roule : permit HTTP/HTTPS
  ingress {
    description = "Allow HTTP for Node.js Server"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow HTTPS for Secure Session"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # outside Roule 
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Hyunjun-Min-Privilege-SG"
  }
}

# ==========================================
# Create EC2
# ==========================================
resource "aws_instance" "node_server" {
  ami           = "ami-000f737cfeba0c202"  
  instance_type = "t3.micro"         
  subnet_id     = aws_subnet.public_subnet.id
   
  vpc_security_group_ids = [aws_security_group.web_sg.id] 

  user_data = <<-EOF
              #!/bin/bash
              sudo apt-get update -y
              sudo apt-get install -y nodejs npm
              EOF

  tags = {
    Name = "Hyunjun-NodeJS-AppServer"
  }
}