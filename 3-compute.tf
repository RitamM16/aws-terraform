data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_placement_group" "spread_placement" {
  name     = "spread_placement_group"
  strategy = "spread"
}

# Launch Template
resource "aws_launch_template" "web_app" {
  name          = "web-app-template"
  image_id      = data.aws_ami.ubuntu.image_id
  instance_type = var.ec2-instance-type

  vpc_security_group_ids = [
    aws_security_group.server_sg.id
  ]

  placement {
    group_name = aws_placement_group.spread_placement.name
  }

  user_data = base64encode(<<-EOF
              #!/bin/bash
              sudo apt update -y
              sudo apt install apache2 -y
              INSTANCE_ID=$(curl http://169.254.169.254/latest/meta-data/instance-id)
              INSTANCE_IP=$(curl http://169.254.169.254/latest/meta-data/local-ipv4)
              INSTANCE_MAC=$(curl http://169.254.169.254/latest/meta-data/mac)
              echo "<html><body><h1>Instance ID: $INSTANCE_ID</h1><h2>IP Address: $INSTANCE_IP</h2><h3>MAC Address: $INSTANCE_MAC</h3></body></html>" > /var/www/html/index.html
              EOF
  )
}

# Listener
resource "aws_lb_listener" "web_listener" {
  load_balancer_arn = aws_lb.web_lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web_tg.arn
  }
}

# Auto Scaling Group
resource "aws_autoscaling_group" "web_asg" {
  vpc_zone_identifier = [
    aws_subnet.private-subnet-1.id, 
    aws_subnet.private-subnet-2.id
  ]

  desired_capacity    = 2
  max_size            = 3
  min_size            = 1

  launch_template {
    id      = aws_launch_template.web_app.id
    version = "$Latest"
  }

  target_group_arns = [aws_lb_target_group.web_tg.arn]
}

# Load Balancer
resource "aws_lb" "web_lb" {
  name               = "web-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [aws_subnet.public-subnet-1.id, aws_subnet.public-subnet-2.id]
}

# Target Group
resource "aws_lb_target_group" "web_tg" {
  name     = "web-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    interval            = 30
    path                = "/"
    protocol            = "HTTP"
    timeout             = 5
    unhealthy_threshold = 2
    healthy_threshold   = 2
  }
}