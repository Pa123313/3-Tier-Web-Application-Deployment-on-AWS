# Backend SG (allow SSH 22 from your IP, HTTP 80 open for demo)
resource "aws_security_group" "backend_sg" {
  name        = "${var.project}-backend-sg"
  description = "Backend security group"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH (limit to your IP!)"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["36.255.7.120/32"] # change this!
  }

  egress {
    description = "all egress"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${var.project}-backend-sg" }
}

# DB SG
resource "aws_security_group" "db_sg" {
  name        = "${var.project}-db-sg"
  description = "DB security group"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "MySQL from backend SG"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.backend_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${var.project}-db-sg" }
}
