output "alb-dns-name" {
  description = "The DNS name of the ALB"
  value = aws_lb.web_lb.dns_name
}