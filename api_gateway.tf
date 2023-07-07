resource "aws_service_discovery_private_dns_namespace" "this" {
  name = "service-discovery.${local.prefix}"
  vpc  = data.aws_vpc.main.id
}

resource "aws_service_discovery_service" "this" {
  name = local.prefix

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.this.id

    dns_records {
      ttl  = 60
      type = "SRV"
    }

    routing_policy = "MULTIVALUE"
  }

  health_check_custom_config {
    failure_threshold = 1
  }
}

resource "aws_apigatewayv2_api" "this" {
  name          = local.prefix
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_domain_name" "this" {
  for_each    = toset(local.api_gateway_domain_names)
  domain_name = each.value

  domain_name_configuration {
    certificate_arn = aws_acm_certificate.this.arn
    endpoint_type   = "REGIONAL"
    security_policy = "TLS_1_2"
  }
}

# resource "aws_apigatewayv2_api_mapping" "this" {
#   for_each    = toset(local.api_gateway_domain_names)
#   api_id      = aws_apigatewayv2_api.this.id
#   domain_name = aws_apigatewayv2_domain_name.this[each.value].id
#   stage       = aws_apigatewayv2_stage.this.id
# }

resource "aws_apigatewayv2_vpc_link" "this" {
  name               = local.prefix
  security_group_ids = [aws_security_group.main_default.id]
  subnet_ids         = [data.aws_subnet.public_1.id]
}

resource "aws_apigatewayv2_integration" "this" {
  api_id             = aws_apigatewayv2_api.this.id
  integration_type   = "HTTP_PROXY"
  connection_type    = "VPC_LINK"
  connection_id      = aws_apigatewayv2_vpc_link.this.id
  integration_method = "ANY"
  integration_uri    = aws_service_discovery_service.this.arn
}

resource "aws_apigatewayv2_route" "this" {
  api_id    = aws_apigatewayv2_api.this.id
  route_key = "$default"
  target    = "integrations/${aws_apigatewayv2_integration.this.id}"
}

resource "aws_apigatewayv2_deployment" "this" {
  api_id = aws_apigatewayv2_api.this.id

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [
    aws_apigatewayv2_route.this
  ]
}

resource "aws_apigatewayv2_stage" "this" {
  api_id        = aws_apigatewayv2_api.this.id
  name          = "$default"
  auto_deploy   = true
  deployment_id = aws_apigatewayv2_deployment.this.id

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_gateway.arn
    format          = "$context.error.message,$context.identity.sourceIp,$context.requestTime,$context.httpMethod,$context.routeKey,$context.protocol,$context.status,$context.responseLength,$context.requestId"
  }

  lifecycle {
    ignore_changes = [deployment_id]
  }
}

resource "aws_cloudwatch_log_group" "api_gateway" {
  name = "${local.prefix}-apigateway"
}
