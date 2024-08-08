

# CREATING VPC

resource "aws_vpc" "TF-Project" {
  cidr_block           = "10.0.0.0/16"
  instance_tenancy     = "default"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "TF-Project"
  }
}




# CREATING PUBLIC SUBNETS

resource "aws_subnet" "TF-Pub-1" {
  vpc_id                  = aws_vpc.TF-Project.id
  cidr_block              = "10.0.0.0/24"
  availability_zone       = "eu-west-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "TF-Pub-1"
  }
}

resource "aws_subnet" "TF-Pub-2" {
  vpc_id                  = aws_vpc.TF-Project.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "eu-west-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "TF-Pub-2"
  }
}




# CREATING PRIVATE SUBNETS

resource "aws_subnet" "TF-Priv-1" {
  vpc_id            = aws_vpc.TF-Project.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "eu-west-1a"

  tags = {
    Name = "TF-Priv-1"
  }
}

resource "aws_subnet" "TF-Priv-2" {
  vpc_id            = aws_vpc.TF-Project.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "eu-west-1b"

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



# CREATING TWO EC2

resource "aws_instance" "TF-Server-1" {
  ami           = "ami-0a2202cf4c36161a1"
  instance_type = "t2.micro"
  availability_zone = "eu-west-1a"
  subnet_id = aws_subnet.TF-Pub-1.id
  security_groups = [aws_security_group.TF-SG.id]

  tags = {
    Name = "TF-Server-1"
  }
}

resource "aws_instance" "TF-Server-2" {
  ami           = "ami-0a2202cf4c36161a1"
  instance_type = "t2.micro"
  availability_zone = "eu-west-1b"
  subnet_id = aws_subnet.TF-Pub-2.id
  security_groups = [aws_security_group.TF-SG.id]

  tags = {
    Name = "TF-Server-2"
  }
}

# CREATING S3

resource "aws_s3_bucket" "tf-s3" {
  bucket = "tfprojectbucket"
}

