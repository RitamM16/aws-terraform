# Create a VPC
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

# Create subnets in different availability zones
resource "aws_subnet" "private-subnet-1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "ap-south-1a"
}

# Create subnets in different availability zones
resource "aws_subnet" "private-subnet-2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "ap-south-1c"
}

# Create subnets in different availability zones
resource "aws_subnet" "public-subnet-1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "ap-south-1a"
}

# Create subnets in different availability zones
resource "aws_subnet" "public-subnet-2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "ap-south-1c"
}

# Internet Gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
}

# Route Table
resource "aws_route_table" "internet-route" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
}

# Allocate an elastic IP for NAT Gateway
resource "aws_eip" "nat_public_ip_1" {
  domain   = "vpc"

  tags = {
    Name = "nat_public_ip_1"
  }

  depends_on = [ aws_internet_gateway.gw ]
}

# Allocate an elastic IP for NAT Gateway
resource "aws_eip" "nat_public_ip_2" {
  domain   = "vpc"

  tags = {
    Name = "nat_public_ip_2"
  }

  depends_on = [ aws_internet_gateway.gw ]
}

resource "aws_nat_gateway" "nat_gateway_1" {
  allocation_id = aws_eip.nat_public_ip_1.id
  subnet_id     = aws_subnet.public-subnet-1.id

  tags = {
    Name = "Nat gateway 1"
  }

  depends_on = [
    aws_internet_gateway.gw,
    aws_eip.nat_public_ip_1
  ]
}

resource "aws_nat_gateway" "nat_gateway_2" {
  allocation_id = aws_eip.nat_public_ip_2.id
  subnet_id     = aws_subnet.public-subnet-2.id

  tags = {
    Name = "Nat gateway 2"
  }

  depends_on = [
    aws_internet_gateway.gw,
    aws_eip.nat_public_ip_2
  ]
}

resource "aws_route_table" "nat-route-1" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat_gateway_1.id
  }
}

resource "aws_route_table" "nat-route-2" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat_gateway_2.id
  }
}

# Route Table Associations
resource "aws_route_table_association" "route_table_1" {
  subnet_id      = aws_subnet.public-subnet-1.id
  route_table_id = aws_route_table.internet-route.id
}

resource "aws_route_table_association" "route_table_2" {
  subnet_id      = aws_subnet.public-subnet-2.id
  route_table_id = aws_route_table.internet-route.id
}

# Route Table Associations
resource "aws_route_table_association" "route_table_3" {
  subnet_id      = aws_subnet.private-subnet-1.id
  route_table_id = aws_route_table.nat-route-1.id
}

resource "aws_route_table_association" "route_table_4" {
  subnet_id      = aws_subnet.private-subnet-2.id
  route_table_id = aws_route_table.nat-route-2.id
}

# Security Group
resource "aws_security_group" "alb_sg" {
  vpc_id = aws_vpc.main.id

  name = "alb-sq"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Security Group
resource "aws_security_group" "server_sg" {
  vpc_id = aws_vpc.main.id

  name = "server_a"

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  depends_on = [ aws_security_group.alb_sg ]
}
