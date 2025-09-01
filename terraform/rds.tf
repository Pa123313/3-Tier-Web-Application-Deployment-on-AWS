resource "aws_db_subnet_group" "db_subnets" {
  name       = "${var.project}-db-subnets"
  subnet_ids = [aws_subnet.private_a.id, aws_subnet.private_b.id]
  tags       = { Name = "${var.project}-db-subnets" }
}

resource "aws_db_instance" "db" {
  identifier              = "${var.project}-mysql"
  allocated_storage       = 20
  engine                  = "mysql"
  engine_version          = "8.0"
  instance_class          = "db.t3.micro"
  username                = var.db_username
  password                = var.db_password
  db_name                 = var.db_name
  vpc_security_group_ids  = [aws_security_group.db_sg.id]
  db_subnet_group_name    = aws_db_subnet_group.db_subnets.name
  skip_final_snapshot     = true
  publicly_accessible     = false
  deletion_protection     = false
  backup_retention_period = 0
  tags                    = { Name = "${var.project}-rds" }
}
