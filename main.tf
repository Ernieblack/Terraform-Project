

# CREATING VPC

resource "aws_vpc" "TF-Project" {
  cidr_block           = var.vpc-cidr
  instance_tenancy     = var.instance_tenancy
  enable_dns_hostnames = var.dns-hostnames
  enable_dns_support   = var.dns-support

  tags = {
    Name = "TF-Project"
  }
}




# CREATING PUBLIC SUBNETS

resource "aws_subnet" "TF-Pub-1" {
  vpc_id                  = aws_vpc.TF-Project.id
  cidr_block              = "10.0.0.0/24"
  availability_zone       = var.az
  map_public_ip_on_launch = var.map-public

  tags = {
    Name = "TF-Pub-1"
  }
}

resource "aws_subnet" "TF-Pub-2" {
  vpc_id                  = aws_vpc.TF-Project.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = var.az1
  map_public_ip_on_launch = var.map-public

  tags = {
    Name = "TF-Pub-2"
  }
}




# CREATING PRIVATE SUBNETS

resource "aws_subnet" "TF-Priv-1" {
  vpc_id            = aws_vpc.TF-Project.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = var.az

  tags = {
    Name = "TF-Priv-1"
  }
}

resource "aws_subnet" "TF-Priv-2" {
  vpc_id            = aws_vpc.TF-Project.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = var.az1

  tags = {
    Name = "TF-Priv-2"
  }
}




# CREATING INTERNET GATEWAY

resource "aws_internet_gateway" "TF-IGW" {
  vpc_id = aws_vpc.TF-Project.id

  tags = {
    Name = "TF-IGW"
  }

}



# CREATING NAT GATEWAY

resource "aws_eip" "nat-eip" {

}
resource "aws_nat_gateway" "TF-NGW" {
  allocation_id = aws_eip.nat-eip.id
  subnet_id     = aws_subnet.TF-Pub-1.id

  tags = {
    Name = "TF-NGW"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.TF-IGW]
}



# CREATING ROUTE TABLES

resource "aws_route_table" "RT-Pub" {
  vpc_id = aws_vpc.TF-Project.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.TF-IGW.id
  }

  tags = {
    Name = "RT-Pub"
  }
}


resource "aws_route_table" "RT-Priv" {
  vpc_id = aws_vpc.TF-Project.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.TF-NGW.id
  }

  tags = {
    Name = "RT-Priv"
  }
}



# CREATING ROUTE TABLE ASSOCIATIONS

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.TF-Pub-1.id
  route_table_id = aws_route_table.RT-Pub.id
}

resource "aws_route_table_association" "b" {
  subnet_id      = aws_subnet.TF-Pub-2.id
  route_table_id = aws_route_table.RT-Pub.id
}

resource "aws_route_table_association" "c" {
  subnet_id      = aws_subnet.TF-Priv-1.id
  route_table_id = aws_route_table.RT-Priv.id
}

resource "aws_route_table_association" "d" {
  subnet_id      = aws_subnet.TF-Priv-2.id
  route_table_id = aws_route_table.RT-Priv.id
}





# CREATING SECURITY GROUPS


resource "aws_security_group" "TF-SG" {
  name        = "TF-SG"
  description = "TG-SG inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.TF-Project.id


  ingress {
    description      = "HTTP"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description      = "ssh"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }


  tags = {
    Name = "TF-SG"
  }
}


# Creating keypair for EC2

resource "aws_key_pair" "March-Key-pair" {
  key_name   = "March-key-pair"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDe83wX7kkcuC9ZcUODBvhzUo0GTgn3BvbnfIftXqmfoml+kkJI/79FebtQOgNqnYo4t2x7dWZg/SmPWmx3SXYxNVKYkSUKhnnKKCTgraFLN5w8MI1DpuqyHo1Gj2nZadTcO4fjAx39u0JyDQJ8BZLjQhruFu1OxqfNDP8o3iy8+BW9vzA31xSIWExKLWkFeS/L49iaf3AuzWJZig0ECv0SeJpv4M41kH9XTIUtRV1lv++J1YTVBs5+DB10bPBpNJypoKuEgAaiOb4l7rzoj/kaprLC+FmNq8qouiDJPDyB2lLzuqFvhYZFREtr1cPdLjx49E+Gx39CyuIXz7AMZQB9 tilly@LAPTOP-9M5I33N7"
}


# CREATING TWO EC2

resource "aws_instance" "TF-Server-1" {
  ami               = "ami-0a2202cf4c36161a1"
  instance_type     = "t2.micro"
  availability_zone = "eu-west-1a"
  subnet_id         = aws_subnet.TF-Pub-1.id
  key_name          = "March-key-pair"
  security_groups   = [aws_security_group.TF-SG.id]
  user_data         = file("${path.module}/user_data.tpl")

  tags = {
    Name = "TF-Server-1"
  }
}

resource "aws_instance" "TF-Server-2" {
  ami               = "ami-0a2202cf4c36161a1"
  instance_type     = "t2.micro"
  availability_zone = "eu-west-1b"
  subnet_id         = aws_subnet.TF-Pub-2.id
  security_groups   = [aws_security_group.TF-SG.id]

  tags = {
    Name = "TF-Server-2"
  }
}

# CREATING S3

resource "aws_s3_bucket" "tf-s3" {
  bucket = "tfprojectbucket"
}

