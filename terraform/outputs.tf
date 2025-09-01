output "frontend_bucket" { value = aws_s3_bucket.frontend.bucket }
output "db_endpoint" { value = aws_db_instance.db.address }
# Fetching ASG instance public IP needs data source; we’ll test via console or curl to instance DNS.
