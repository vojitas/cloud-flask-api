resource "aws_vpc" "this" {
  for_each             = var.vpc_parameters
  cidr_block           = each.value.cidr_block
  enable_dns_support   = each.value.enable_dns_support
  enable_dns_hostnames = each.value.enable_dns_hostnames
  tags = merge(each.value.tags, {
    Name : each.key
  })
}

resource "aws_subnet" "this" {
  for_each   = var.subnet_parameters
  vpc_id     = aws_vpc.this[each.value.vpc_name].id
  cidr_block = each.value.cidr_block
  availability_zone = each.value.availability_zone
  tags = merge(each.value.tags, {
    Name : each.key
  })
}

resource "aws_internet_gateway" "this" {
  for_each = var.igw_parameters
  vpc_id   = aws_vpc.this[each.value.vpc_name].id
  tags = merge(each.value.tags, {
    Name : each.key
  })
}

resource "aws_route_table" "this" {
  for_each = var.rt_parameters
  vpc_id   = aws_vpc.this[each.value.vpc_name].id
  tags = merge(each.value.tags, {
    Name : each.key
  })

  dynamic "route" {
    for_each = each.value.routes
    content {
      cidr_block = route.value.cidr_block
      gateway_id = route.value.use_igw ? aws_internet_gateway.this[route.value.gateway_id].id : route.value.gateway_id
    }
  }
}

resource "aws_route_table_association" "this" {
  for_each       = var.rt_association_parameters
  subnet_id      = aws_subnet.iac_subnet[each.value.subnet_name].id
  route_table_id = aws_route_table.iac_route_table[each.value.rt_name].id
}

resource "tls_private_key" "rsa" {
  algorithm   = "RSA"
  rsa_bits    = 4096
}

resource "aws_key_pair" "iac_key" {
  for_each   = var.key_parameters
  key_name   = each.value.key_name
  public_key = tls_private_key.rsa.public_key_openssh
}

resource "aws_ssm_parameter" "secret_key_private" {
  name  = "iac_secret_key_private"
  type  = "String"
  value = tls_private_key.rsa.private_key_pem
}

resource "aws_ssm_parameter" "secret_key_public" {
  name  = "iac_secret_key"
  type  = "String"
  value = tls_private_key.rsa.public_key_openssh
}


resource "aws_security_group" "iac_security_group" {
  name       = var.sg_parameters.name
  vpc_id     = aws_vpc.iac_vpc[var.sg_parameters.vpc_name].id
  tags = merge(var.sg_parameters.tags, {
    Name : var.sg_parameters.name
  })
}

resource "aws_vpc_security_group_ingress_rule" "iac_ingress_rule" {
  for_each          = var.ingress_parameters
  security_group_id = aws_security_group.iac_security_group.id
  cidr_ipv4         = each.value.cidr_ipv4
  from_port         = each.value.from_port
  ip_protocol       = each.value.ip_protocol
  to_port           = each.value.to_port 
}

resource "aws_vpc_security_group_egress_rule" "iac_egress_rule" {
  for_each          = var.egress_parameters
  security_group_id = aws_security_group.iac_security_group.id
  cidr_ipv4         = each.value.cidr_ipv4
  ip_protocol       = each.value.ip_protocol
}

resource "aws_instance" "iac_ec2" {
  for_each                    = var.ec2_parameters
  ami                         = each.value.ami
  subnet_id                   = aws_subnet.iac_subnet[each.value.subnet_name].id
  instance_type               = each.value.instance_type
  key_name                    = each.value.key_name
  security_groups             = [aws_security_group.iac_security_group.id]
  tags = merge(each.value.tags, {
    Name : each.value.name
  })
}

resource "aws_eip" "iac_eip" {
  for_each   = var.eip_parameters
  domain     = each.value.domain
  instance   = aws_instance.iac_ec2[each.value.instance_name].id
  #depends_on = [aws_internet_gateway.iac_internet_gateway[iac_eip.value.gateway_name].id]
  tags = merge(each.value.tags, {
    Name : each.value.name
  })
}


resource "aws_security_group" "iac_rds_security_group" {
  name       = var.rds_sg_parameters.name
  vpc_id     = aws_vpc.iac_vpc[var.rds_sg_parameters.vpc_name].id
  tags = merge(var.rds_sg_parameters.tags, {
    Name : var.sg_parameters.name
  })
}

resource "aws_vpc_security_group_ingress_rule" "iac_rds_ingress" {
  for_each          = var.rds_ingress_parameters
  security_group_id = aws_security_group.iac_rds_security_group.id
  cidr_ipv4         = each.value.cidr_ipv4
  from_port         = each.value.from_port
  ip_protocol       = each.value.ip_protocol
  to_port           = each.value.to_port 
}

resource "aws_vpc_security_group_egress_rule" "iac_rds_egress" {
  for_each          = var.rds_egress_parameters
  security_group_id = aws_security_group.iac_rds_security_group.id
  cidr_ipv4         = each.value.cidr_ipv4
  ip_protocol       = each.value.ip_protocol
}

resource "aws_db_subnet_group" "iac_subnet_group" {
  name = var.rds_subnet_group_parameters.name
  subnet_ids = [for x in aws_subnet.iac_subnet : x.id]
}

resource "aws_db_instance" "iac_pg_rds" {
  allocated_storage    = var.rds_parameters.allocated_storage
  db_name              = var.rds_parameters.db_name
  engine               = var.rds_parameters.engine
  engine_version       = var.rds_parameters.engine_version
  instance_class       = var.rds_parameters.instance_class
  username             = var.rds_parameters.username
  password             = var.rds_parameters.password
  db_subnet_group_name = var.rds_subnet_group_parameters.name
  vpc_security_group_ids = [aws_security_group.iac_rds_security_group.id]
  identifier = var.rds_parameters.name
}