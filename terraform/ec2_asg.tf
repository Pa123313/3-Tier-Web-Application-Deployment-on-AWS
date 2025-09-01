# Launch template installs Docker and starts the container on port 80
resource "aws_launch_template" "backend_lt" {
  name_prefix   = "${var.project}-lt-"
  image_id      = data.aws_ami.al2.id
  instance_type = "t3.micro"
  key_name      =  aws_key_pair.dev-key-pair.key_name  # ✅ use new key pair

  user_data = base64encode(<<-EOT
    #!/bin/bash
    yum update -y
    amazon-linux-extras install docker -y || yum install -y docker
    systemctl enable docker
    systemctl start docker
    docker pull ${var.backend_image}
    # pass DB env via file for simplicity
    echo "DB_HOST=${aws_db_instance.db.address}" >> /etc/environment
    echo "DB_USER=${var.db_username}" >> /etc/environment
    echo "DB_PASSWORD=${var.db_password}" >> /etc/environment
    echo "DB_NAME=${var.db_name}" >> /etc/environment
    # load vars and run
    set -a && . /etc/environment && set +a
    docker run -d --restart unless-stopped --name api -p 80:5000 \
      -e DB_HOST -e DB_USER -e DB_PASSWORD -e DB_NAME \
      ${var.backend_image}
  EOT
  )

  network_interfaces {
    security_groups             = [aws_security_group.backend_sg.id]
    associate_public_ip_address = true
  }

  tag_specifications {
    resource_type = "instance"
    tags          = { Name = "${var.project}-backend" }
  }
}

# ASG (min 1, max 1) — keeps shape without ALB
resource "aws_autoscaling_group" "backend_asg" {
  name                = "${var.project}-asg"
  max_size            = 1
  min_size            = 1
  desired_capacity    = 1
  vpc_zone_identifier = [aws_subnet.public_a.id, aws_subnet.public_b.id]

  launch_template {
    id      = aws_launch_template.backend_lt.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${var.project}-backend"
    propagate_at_launch = true
  }

  lifecycle {
    ignore_changes = [desired_capacity]
  }

  depends_on = [aws_db_instance.db] # ensure DB exists first
}

data "aws_ami" "al2" {
  most_recent = true
  owners      = ["137112412989"] # Amazon
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

