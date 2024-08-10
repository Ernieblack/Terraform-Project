
variable "region" {
  type        = string
  description = "vpc-region"
  default     = "eu-west-1"

}

variable "vpc-cidr" {
  type        = string
  description = "vpc-cidr"
  default     = "10.0.0.0/16"

}

variable "instance_tenancy" {
  type        = string
  description = "vpc tenancy"
  default     = "default"
}


variable "dns-hostnames" {
  type        = bool
  description = "vpc dns hostnames"
  default     = true
}


variable "dns-support" {
  type        = bool
  description = "vpc dns support"
  default     = true
}




variable "az" {
  type        = string
  description = "availability-zone"
  default     = "eu-west-1a"

}

variable "az1" {
  type        = string
  description = "availability-zone"
  default     = "eu-west-1b"

}

variable "map-public" {
  type        = bool
  description = "IPv4 to access internet"
  default     = true

}



