#output server public IP address 
output "alb_dns_name" {
  #link variable with ec2 instance
  value = aws_lb.example.dns_name
  description = "DNS name of the load balancer"
}