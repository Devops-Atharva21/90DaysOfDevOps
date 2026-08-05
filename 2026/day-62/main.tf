# -------------------------
# VPC
# -------------------------
resource "aws_vpc" "test" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "TerraWeek-VPC"
  }
}

# -------------------------
# Public Subnet
# -------------------------
resource "aws_subnet" "main" {
  vpc_id                  = aws_vpc.test.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "TerraWeek-Public-Subnet"
  }
}

# -------------------------
# Internet Gateway
# -------------------------
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.test.id

  tags = {
    Name = "TerraWeek-IGW"
  }
}

# -------------------------
# Route Table
# -------------------------
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.test.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "TerraWeek-RouteTable"
  }
}

# -------------------------
# Route Table Association
# -------------------------
resource "aws_route_table_association" "rt_sub" {
  subnet_id      = aws_subnet.main.id
  route_table_id = aws_route_table.public_rt.id
}

# -------------------------
# Security Group
# -------------------------
resource "aws_security_group" "sg" {
  name        = "TerraWeek-SG"
  description = "Allow SSH and HTTP"
  vpc_id      = aws_vpc.test.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
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

  tags = {
    Name = "TerraWeek-SG"
  }
}

# -------------------------
# EC2 Instance
# -------------------------
resource "aws_instance" "aws_linux" {
  ami                         = "ami-091124c3965bce679"
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.main.id
  vpc_security_group_ids      = [aws_security_group.sg.id]
  associate_public_ip_address = true

  # Uncomment if you have a key pair
  # key_name = "your-keypair-name"

  lifecycle {
    create_before_destroy = true
 }

  tags = {
    Name = "TerraWeek-Server"
  }
}

### S3 bucket 

resource "aws_s3_bucket" "app_logs" {
  bucket = "terraweek-app-logs-terraweeek-logs"

  depends_on = [
    aws_instance.aws_linux
  ]
  tags = {
    Name = "TerraWeek-App-Logs"
 }
}
