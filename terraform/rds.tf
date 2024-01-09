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