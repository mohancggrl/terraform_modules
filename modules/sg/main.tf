# -------------------------------------------------------------------
# Security Group
# -------------------------------------------------------------------

resource "aws_security_group" "main" {
  count       = var.create_security_group ? 1 : 0
  name        = var.name
  description = var.description
  vpc_id      = var.vpc_id
  tags = merge(var.tags, { Name = var.name })
}

# -------------------------------------------------------------------
# Ingress Rules
# -------------------------------------------------------------------

resource "aws_security_group_rule" "ingress" {
  count             = var.create_security_group && length(var.ingress_rules) > 0 ? length(var.ingress_rules) : 0
  type              = "ingress"
  from_port         = var.ingress_rules[count.index].from_port
  to_port           = var.ingress_rules[count.index].to_port
  protocol          = var.ingress_rules[count.index].protocol
  cidr_blocks       = lookup(var.ingress_rules[count.index], "cidr_blocks", null)
  ipv6_cidr_blocks  = lookup(var.ingress_rules[count.index], "ipv6_cidr_blocks", null)
  security_group_id = aws_security_group.main[0].id
  description       = lookup(var.ingress_rules[count.index], "description", null)
  depends_on = [aws_security_group.main]
}

# -------------------------------------------------------------------
# Egress Rules
# -------------------------------------------------------------------

resource "aws_security_group_rule" "egress" {
  count             = var.create_security_group && length(var.egress_rules) > 0 ? length(var.egress_rules) : 0
  type              = "egress"
  from_port         = var.egress_rules[count.index].from_port
  to_port           = var.egress_rules[count.index].to_port
  protocol          = var.egress_rules[count.index].protocol
  cidr_blocks       = lookup(var.egress_rules[count.index], "cidr_blocks", null)
  ipv6_cidr_blocks  = lookup(var.egress_rules[count.index], "ipv6_cidr_blocks", null)
  security_group_id = aws_security_group.main[0].id
  description       = lookup(var.egress_rules[count.index], "description", null)
  depends_on = [aws_security_group.main]
}