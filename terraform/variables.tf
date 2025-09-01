variable "project" { type = string }
variable "region" { type = string }
variable "az_a" { type = string }
variable "az_b" { type = string }
variable "public_key_name" { type = string } # EC2 KeyPair name

# Docker image for backend
variable "backend_image" { type = string }

# RDS
variable "db_username" { type = string }
variable "db_password" { type = string }
variable "db_name" {
  type    = string
  default = "appdb"
}

