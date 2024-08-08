
variable "region" {
    type = string
    description = "vpc-region"
    default = "eu-west-1"
  
}

variable "vpc-cidr" {
    type = string
    description = "vpc-cidr"
    default = "10.0.0.0/16"
  
}

variable "az" {
    type = string
    description = "availability-zone"
    default = "eu-west-1a"
  
}

variable "az1" {
    type = string
    description = "availability-zone"
    default = "eu-west-1b"
  
}

variable "map-public" {
    type = bool
    description = "IPv4 to access internet"
    default = true
  
}


  
