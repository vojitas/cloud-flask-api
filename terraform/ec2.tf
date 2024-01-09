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
  vpc_security_group_ids      = [aws_security_group.iac_security_group.id]
  
  user_data = <<-EOL
  #!/bin/bash -xe
  sudo yum update -y
  sudo yum install git -y
  sudo yum install docker -y
  sudo service docker start
  sudo usermod -a -G docker ec2-user
  sudo curl -L https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose
  sudo chmod +x /usr/local/bin/docker-compose
  rm -rf /flask-api
  cd /home/ec2-user
  su ec2-user -c "git clone https://github.com/vojitas/flask-api.git"
  EOL
  
  tags = merge(each.value.tags, {
    Name : each.value.name
  })
}

resource "aws_eip" "iac_eip" {
  for_each   = var.eip_parameters
  domain     = each.value.domain
  instance   = aws_instance.iac_ec2[each.value.instance_name].id
  tags = merge(each.value.tags, {
    Name : each.value.name
  })
}