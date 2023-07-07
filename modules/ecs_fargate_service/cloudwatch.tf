resource "aws_cloudwatch_log_group" "this" {
  name = "${var.common.prefix}-${var.service_name}-${var.common.region_nick}"
}
