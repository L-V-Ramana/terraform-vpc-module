output "aws-zones" {
  value = data.aws_availability_zones.available.names  
}