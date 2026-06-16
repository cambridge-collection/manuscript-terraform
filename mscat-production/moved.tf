# In-place VPC migration for architecture-ecs v2.5.0 -> v4.4.1 (Approach B).
#
# v4.0.0 rebuilt the VPC data plane from per-AZ named resources (_a / _b) to
# count-based [*] and shipped NO `moved` blocks. Without these, the entire 
# deployment needs to be destroyed, base architecture applies and then a full 
# `terraform apply`. 
# These blocks map the existing v2.5.0 state addresses
# onto the new count indices so the resources are preserved in place.
#
# Target is single-NAT (vpc_nat_gateway_single = true): only nat_a / eip_a are
# kept (as index [0]); nat_b / eip_b are intentionally NOT moved and are destroyed.
# Index 0 == eu-west-1a, index 1 == eu-west-1b (matches the old _a/_b AZ assignment),
# so with the CIDRs pinned in main.tf the subnets keep their AZ + CIDR and show
# in-place (tag-only) updates rather than replacement.

# --- Subnets ---
moved {
  from = module.base_architecture.aws_subnet.public_a
  to   = module.base_architecture.aws_subnet.public[0]
}
moved {
  from = module.base_architecture.aws_subnet.public_b
  to   = module.base_architecture.aws_subnet.public[1]
}
moved {
  from = module.base_architecture.aws_subnet.private_a
  to   = module.base_architecture.aws_subnet.private[0]
}
moved {
  from = module.base_architecture.aws_subnet.private_b
  to   = module.base_architecture.aws_subnet.private[1]
}

# --- Private route tables (the public RT was already a singleton -> unchanged) ---
moved {
  from = module.base_architecture.aws_route_table.private_a
  to   = module.base_architecture.aws_route_table.private[0]
}
moved {
  from = module.base_architecture.aws_route_table.private_b
  to   = module.base_architecture.aws_route_table.private[1]
}

# --- Route table associations ---
moved {
  from = module.base_architecture.aws_route_table_association.public_a
  to   = module.base_architecture.aws_route_table_association.public[0]
}
moved {
  from = module.base_architecture.aws_route_table_association.public_b
  to   = module.base_architecture.aws_route_table_association.public[1]
}
moved {
  from = module.base_architecture.aws_route_table_association.private_a
  to   = module.base_architecture.aws_route_table_association.private[0]
}
moved {
  from = module.base_architecture.aws_route_table_association.private_b
  to   = module.base_architecture.aws_route_table_association.private[1]
}

# --- NAT gateway + EIP: keep ONLY the first (single-NAT target). ---
# nat_b / eip_b are intentionally omitted -> destroyed. Keeping nat_a as [0]
# retains its Elastic IP, so the egress IP for the kept gateway does not change.
moved {
  from = module.base_architecture.aws_nat_gateway.nat_a
  to   = module.base_architecture.aws_nat_gateway.nat[0]
}
moved {
  from = module.base_architecture.aws_eip.nat_a
  to   = module.base_architecture.aws_eip.nat[0]
}
