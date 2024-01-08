variable "vpc_parameters" {
  description = "VPC parameters"
  type = map(object({
    cidr_block           = string
    enable_dns_support   = optional(bool, true)
    enable_dns_hostnames = optional(bool, true)
    tags                 = optional(map(string), {})
  }))
  default = {}
}


variable "subnet_parameters" {
  description = "Subnet parameters"
  type = map(object({
    cidr_block = string
    vpc_name   = string
    availability_zone = string
    tags       = optional(map(string), {})
  }))
  default = {}
}

variable "igw_parameters" {
  description = "IGW parameters"
  type = map(object({
    vpc_name = string
    tags     = optional(map(string), {})
  }))
  default = {}
}

variable "rt_parameters" {
  description = "RT parameters"
  type = map(object({
    vpc_name = string
    tags     = optional(map(string), {})
    routes = optional(list(object({
      cidr_block    = string
      use_igw       = optional(bool) 
      gateway_name  = string
    })), [])
  }))
  default = {}
}

variable "rt_association_parameters" {
  description = "RT association parameters"
  type = map(object({
    subnet_name = string
    rt_name     = string
  }))
}

variable "private_key_parameters" {
  description = "Private key parameters"
  type = map(object({
    algorithm   = string
    rsa_bits    = number
  }))
}

variable "key_parameters" {
  description = "Key parameters"
  type = map(object({
    key_name   = string
  }))
}

variable "sg_parameters" {
  description = "Security group parameters"
  type = object({
    name     = string
    vpc_name = string
    tags   = optional(map(string), {})
  })  
}

variable "ingress_parameters" {
  description = "Ingress rules parameters"
  type = map(object({
    security_group_name = string
    cidr_ipv4           = string
    from_port           = number
    ip_protocol         = string
    to_port             = number
    tags   = optional(map(string), {})
  }))    
}

variable "egress_parameters" {
  description = "Egress rules parameters"
  type = map(object({
    security_group_name = string
    cidr_ipv4           = string
    ip_protocol         = string
    tags   = optional(map(string), {})
  }))    
}

variable "ec2_parameters" {
  description = "EC2 instance parameters"
  type = map(object({
    ami                 = string
    instance_type       = string
    subnet_name         = string
    key_name            = string
    name                = string
    tags          = optional(map(string), {})
  }))
}

variable "eip_parameters" {
  description = "Elastic IP parameters"
  type = map(object({
    domain = string
    instance_name = string
    gateway_name  = string
    name          = string
    tags          = optional(map(string), {})
  }))
}

variable "rds_sg_parameters" {
  description = "RDS Security group parameters"
  type = object({
    name     = string
    vpc_name = string
    tags   = optional(map(string), {})
  })  
}

variable "rds_ingress_parameters" {
  description = "RDS Ingress rules parameters"
  type = map(object({
    security_group_name = string
    cidr_ipv4           = string
    from_port           = number
    ip_protocol         = string
    to_port             = number
    tags   = optional(map(string), {})
  }))    
}

variable "rds_egress_parameters" {
  description = "Egress rules parameters"
  type = map(object({
    security_group_name = string
    cidr_ipv4           = string
    ip_protocol         = string
    tags   = optional(map(string), {})
  }))    
}

variable "rds_subnet_group_parameters" {
  description = "RDS subnet group parameters"
  type = object({
    name = string
  })  
}

variable "rds_parameters" {
  description = "RDS postgres parameters"
  type = object({
    allocated_storage = number
    db_name           = string
    engine            = string
    engine_version    = string
    instance_class    = string
    username          = string
    password          = string
    name              = string
  })  
}

variable "private_key_parameters" {
  description = "Private key parameters"
  type = map(object({
    algorithm   = string
    rsa_bits    = number
  }))
}

variable "key_parameters" {
  description = "Key parameters"
  type = map(object({
    key_name   = string
  }))
}

variable "sg_parameters" {
  description = "Security group parameters"
  type = object({
    name     = string
    vpc_name = string
    tags   = optional(map(string), {})
  })  
}

variable "ingress_parameters" {
  description = "Ingress rules parameters"
  type = map(object({
    security_group_name = string
    cidr_ipv4           = string
    from_port           = number
    ip_protocol         = string
    to_port             = number
    tags   = optional(map(string), {})
  }))    
}

variable "egress_parameters" {
  description = "Egress rules parameters"
  type = map(object({
    security_group_name = string
    cidr_ipv4           = string
    ip_protocol         = string
    tags   = optional(map(string), {})
  }))    
}

variable "ec2_parameters" {
  description = "EC2 instance parameters"
  type = map(object({
    ami                 = string
    instance_type       = string
    subnet_name         = string
    key_name            = string
    name                = string
    tags          = optional(map(string), {})
  }))
}

variable "eip_parameters" {
  description = "Elastic IP parameters"
  type = map(object({
    domain = string
    instance_name = string
    gateway_name  = string
    name          = string
    tags          = optional(map(string), {})
  }))
}

variable "rds_sg_parameters" {
  description = "RDS Security group parameters"
  type = object({
    name     = string
    vpc_name = string
    tags   = optional(map(string), {})
  })  
}

variable "rds_ingress_parameters" {
  description = "RDS Ingress rules parameters"
  type = map(object({
    security_group_name = string
    cidr_ipv4           = string
    from_port           = number
    ip_protocol         = string
    to_port             = number
    tags   = optional(map(string), {})
  }))    
}

variable "rds_egress_parameters" {
  description = "Egress rules parameters"
  type = map(object({
    security_group_name = string
    cidr_ipv4           = string
    ip_protocol         = string
    tags   = optional(map(string), {})
  }))    
}

variable "rds_subnet_group_parameters" {
  description = "RDS subnet group parameters"
  type = object({
    name = string
  })  
}

variable "rds_parameters" {
  description = "RDS postgres parameters"
  type = object({
    allocated_storage = number
    db_name           = string
    engine            = string
    engine_version    = string
    instance_class    = string
    username          = string
    password          = string
    name              = string
  })  
}