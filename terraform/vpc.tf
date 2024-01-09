resource "aws_vpc" "iac_vpc" {
  for_each             = var.vpc_parameters
  cidr_block           = each.value.cidr_block
  tags = merge(each.value.tags, {
    Name : each.key
  })
}

resource "aws_subnet" "iac_subnet" {
  for_each   = var.subnet_parameters
  vpc_id     = aws_vpc.iac_vpc[each.value.vpc_name].id
  cidr_block = each.value.cidr_block
  availability_zone = each.value.availability_zone
  tags = merge(each.value.tags, {
  })
}

resource "aws_internet_gateway" "iac_ig" {
  for_each = var.igw_parameters
  vpc_id   = aws_vpc.iac_vpc[each.value.vpc_name].id
  tags = merge(each.value.tags, {
  })
}

resource "aws_route_table" "iac_route_table" {
  for_each = var.rt_parameters
  vpc_id   = aws_vpc.iac_vpc[each.value.vpc_name].id
  tags = merge(each.value.tags, {
  })

  dynamic "route" {
    for_each = each.value.routes
    content {
      cidr_block = route.value.cidr_block
      gateway_id = route.value.use_igw ? aws_internet_gateway.iac_ig[route.value.gateway_name].id : "local"
    }
  }
}

resource "aws_route_table_association" "iac_route_table_association" {
  for_each       = var.rt_association_parameters
  subnet_id      = aws_subnet.iac_subnet[each.value.subnet_name].id
  route_table_id = aws_route_table.iac_route_table[each.value.rt_name].id
}