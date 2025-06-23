variable "cidr_block" {
    default = "10.0.0.0/16"   
}

variable "project"{
    type = string
}

variable "environment"{
    type = string
}

variable "public_subnet_cidr_block" {
    type = list(string)

}

variable "vpc_tags" {
  type = map(string)
  default = {}
}

variable "ig_tags"{
    type = map(string)
    default = {}
}

variable "public_subnet_tags"{
    type = map(string)
    default = {}
}

variable "private_cidr_blocks" {
    type=list(string)
  
}

variable "private_subnet_tags" {
    type = map(string)
    default = {}
  
}

variable "database_cidrs"{
    type = list(string)
}

variable "database_tags" {
    type = map(string)
    default = {}
  
}

variable "elastic_ip_tags" {
    type= map(string)
    default = {}
}

variable "is_peering_required"{
    default = "false"
}