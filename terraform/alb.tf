resource "aws_security_group" "iac_alb_sg" {
  name   = var.alb_security_group_parameters.name
  vpc_id = aws_vpc.iac_vpc[var.alb_security_group_parameters.vpc_name].id
}

resource "aws_vpc_security_group_ingress_rule" "iac_alb_ingress_rule" {
  for_each          = var.alb_ingress_parameters
  security_group_id = aws_security_group.iac_alb_sg.id
  cidr_ipv4         = each.value.cidr_ipv4
  from_port         = each.value.from_port
  ip_protocol       = each.value.ip_protocol
  to_port           = each.value.to_port 
}

resource "aws_vpc_security_group_egress_rule" "iac_alb_egress_rule" {
  for_each          = var.alb_egress_parameters
  security_group_id = aws_security_group.iac_alb_sg.id
  cidr_ipv4         = each.value.cidr_ipv4
  ip_protocol       = each.value.ip_protocol
}

resource "aws_lb" "iac_alb" {
  name               = var.alb_parameters.name
  internal           = var.alb_parameters.internal
  load_balancer_type = var.alb_parameters.load_balancer_type
  security_groups    = [aws_security_group.iac_alb_sg.id]
  subnets            = [for subnet in aws_subnet.iac_subnet : subnet.id]
}

resource "aws_lb_target_group" "iac_alb_target_group" {
  name        = var.alb_tg_parameters.name
  port        = var.alb_tg_parameters.port
  protocol    = var.alb_tg_parameters.protocol
  target_type = var.alb_tg_parameters.target_type
  vpc_id      = aws_vpc.iac_vpc[var.alb_tg_parameters.vpc_name].id
}

resource "aws_lb_target_group_attachment" "iac_alb_tg_attachment" {
  target_group_arn = aws_lb_target_group.iac_alb_target_group.arn
  target_id        = aws_instance.iac_ec2[var.alb_tg_attachment_parameters.instance_name].id
  port             = var.alb_tg_attachment_parameters.port
}

resource "aws_lb_listener" "iac_alb_listener" {
  load_balancer_arn = aws_lb.iac_alb.arn
  port              = var.alb_listener_parameters.port
  protocol          = var.alb_listener_parameters.protocol
  default_action {
    type             = var.alb_listener_parameters.type
    target_group_arn = aws_lb_target_group.iac_alb_target_group.arn
  }
}