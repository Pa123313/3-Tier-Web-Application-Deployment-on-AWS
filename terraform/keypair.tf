resource "aws_key_pair" "dev-key-pair" {
  key_name   = "dev-key-pair"
  public_key = file("/mnt/c/Users/Akshay/dev-key-pair.pub")
}
