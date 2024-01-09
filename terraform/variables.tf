variable "vpc_parameters" {
  description = "VPC parameters"
  type = map(object({
    cidr_block           = string
    tags                 = optional(map(string), {})
  }))
}


variable "subnet_parameters" {
  description = "Subnet parameters"
  type = map(object({
    cidr_block = string
    vpc_name   = string
    availability_zone = string
    tags       = optional(map(string), {})
  }))
}

variable "igw_parameters" {
  description = "IGW parameters"
  type = map(object({
    vpc_name = string
    tags     = optional(map(string), {})
  }))
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
  description = "RDS parameters"
  type = object({
    allocated_storage    = number
    db_name              = string
    engine               = string
    engine_version       = string
    instance_class       = string
    username             = string
    password             = string
    name                 = string
  }) 
}

variable "alb_security_group_parameters" {
  description = "Security group parameters for ALB"
  type = object({
    name     = string
    vpc_name = string
  }) 
}

variable "alb_ingress_parameters" {
  description = "ALB Ingress rules parameters"
  type = map(object({
    cidr_ipv4           = string
    from_port           = number
    ip_protocol         = string
    to_port             = number
    tags   = optional(map(string), {})
  }))    
}

variable "alb_egress_parameters" {
  description = "ALB Egress rules parameters"
  type = map(object({
    cidr_ipv4           = string
    ip_protocol         = string
    tags   = optional(map(string), {})
  }))    
}

variable "alb_parameters" {
    description = "ALB parameters"
    type = object({
      name               = string
      internal           = bool
      load_balancer_type = string
  }) 
}

variable "alb_tg_parameters" {
    description = "ALB target group parameters"
    type = object({
      name        = string
      port        = number
      protocol    = string
      target_type = string
      vpc_name    = string
  }) 
}

variable "alb_tg_attachment_parameters" {
    description = "ALB target group parameters"
    type = object({
      instance_name = string
      port          = number
  }) 
}

variable "alb_listener_parameters" {
    description = "ALB listener parameters"
    type = object({
      port     = number
      protocol = string
      type     = string
  }) 
}