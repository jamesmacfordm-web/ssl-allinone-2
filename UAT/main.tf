terraform {
  required_version = ">= 1.3.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "= 5.31.0"
    }
  }
}

provider "aws" {
  region = var.region
}

# ─────────────────────────────────────────
# VPC
# ─────────────────────────────────────────
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name        = "ssl-${var.environment}-vpc"
    Environment = var.environment
  }
}

# ─────────────────────────────────────────
# Internet Gateway
# ─────────────────────────────────────────
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name        = "ssl-${var.environment}-igw"
    Environment = var.environment
  }
}

# ─────────────────────────────────────────
# Subnets
# ─────────────────────────────────────────
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidr
  map_public_ip_on_launch = true
  availability_zone       = "${var.region}a"

  tags = {
    Name        = "ssl-${var.environment}-public-subnet"
    Environment = var.environment
  }
}

resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidr
  availability_zone = "${var.region}b"

  tags = {
    Name        = "ssl-${var.environment}-private-subnet"
    Environment = var.environment
  }
}

# ─────────────────────────────────────────
# Route Table
# ─────────────────────────────────────────
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name        = "ssl-${var.environment}-public-rt"
    Environment = var.environment
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# ─────────────────────────────────────────
# Security Group
# ─────────────────────────────────────────
resource "aws_security_group" "ec2_sg" {
  name        = "ssl-${var.environment}-ec2-sg"
  description = "Security group for ${var.environment} EC2 instances"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "SSH access"
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTP access"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "All outbound traffic"
  }

  tags = {
    Name        = "ssl-${var.environment}-ec2-sg"
    Environment = var.environment
  }
}

# ─────────────────────────────────────────
# EC2 Instance (Amazon Linux 2023)
# ─────────────────────────────────────────
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

resource "aws_instance" "app" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]

  tags = {
    Name        = "ssl-${var.environment}-app-server"
    Environment = var.environment
  }
}

# ─────────────────────────────────────────
# S3 App Bucket
# ─────────────────────────────────────────
resource "aws_s3_bucket" "app" {
  bucket        = "ssl-${var.environment}-app-storage-${random_id.suffix.hex}"
  force_destroy = true

  tags = {
    Name        = "ssl-${var.environment}-app-storage"
    Environment = var.environment
  }
}

resource "random_id" "suffix" {
  byte_length = 4
}

resource "aws_s3_bucket_versioning" "app" {
  bucket = aws_s3_bucket.app.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "app" {
  bucket                  = aws_s3_bucket.app.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
