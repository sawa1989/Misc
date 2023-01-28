# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# SECURITY GROUP 
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
variable "sg_id_list" {
    type = list(string)
    default = [
    ]
}

locals {
    kyoin-sg-os-csv = file("./kyoin-sg-os.csv")
    kyoin-sg-os-csv-rules = csvdecode(local.kyoin-sg-os-csv)
}

resource "aws_security_group" "kyoin-sg-os" {
  name = "kyoin-sg-os"
  vpc_id = "${aws_vpc.kyoin-vpc.id}"
}

resource "aws_security_group_rule" "kyoin-sg-os-rule" {
  for_each          = { for rule in local.kyoin-sg-os-csv-rules : rule.key=> rule }
  security_group_id = aws_security_group.kyoin-sg-os.id
  type              = each.value.rule_type
  from_port         = each.value.from_port
  to_port           = each.value.to_port
  protocol          = each.value.protocol
  cidr_blocks = length(regexall("[a-z]",each.value.src_or_dst)) == 0 ? [each.value.src_or_dst] : null
  prefix_list_ids = substr(each.value.src_or_dst,0,2) == "pl" ? [each.value.src_or_dst] : null
  source_security_group_id = contains(var.sg_id_list, each.value.src_or_dst) ? "${each.value.src_or_dst}"  : null
  self = each.value.src_or_dst == "self" ? true : null
  description       = lookup(each.value, "desc", null)
}
