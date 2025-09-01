resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags                 = { Name = "${var.project}-vpc" }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags   = { Name = "${var.project}-igw" }
}

# Public subnets
resource "aws_subnet" "public_a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = var.az_a
  map_public_ip_on_launch = true
  tags                    = { Name = "${var.project}-public-a" }
}
resource "aws_subnet" "public_b" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = var.az_b
  map_public_ip_on_launch = true
  tags                    = { Name = "${var.project}-public-b" }
}

# Private subnets (DB)
resource "aws_subnet" "private_a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = var.az_a
  tags              = { Name = "${var.project}-private-a" }
}
resource "aws_subnet" "private_b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = var.az_b
  tags              = { Name = "${var.project}-private-b" }
}

# Public RT
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = { Name = "${var.project}-public-rt" }
}

resource "aws_route_table_association" "public_a_assoc" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.public_rt.id
}
resource "aws_route_table_association" "public_b_assoc" {
  subnet_id      = aws_subnet.public_b.id
  route_table_id = aws_route_table.public_rt.id
}

# NAT is optional. If needed for private subnets' outbound access, enable below.
# resource "aws_eip" "nat" { domain = "vpc" }
# resource "aws_nat_gateway" "nat" {
#   allocation_id = aws_eip.nat.id
#   subnet_id     = aws_subnet.public_a.id
#   depends_on    = [aws_internet_gateway.igw]
# }
# resource "aws_route_table" "private_rt" {
#   vpc_id = aws_vpc.main.id
#   route {
#     cidr_block     = "0.0.0.0/0"
#     nat_gateway_id = aws_nat_gateway.nat.id
#   }
#   tags = { Name = "${var.project}-private-rt" }
# }
# resource "aws_route_table_association" "private_a_assoc" {
#   subnet_id      = aws_subnet.private_a.id
#   route_table_id = aws_route_table.private_rt.id
# }
# resource "aws_route_table_association" "private_b_assoc" {
#   subnet_id      = aws_subnet.private_b.id
#   route_table_id = aws_route_table.private_rt.id
# }
