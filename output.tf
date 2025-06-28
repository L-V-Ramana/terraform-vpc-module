output "aws-zones" {
  value = data.aws_availability_zones.available.names  
}

output "public-subnet-id"{
  value = aws_subnet.public.id 
}