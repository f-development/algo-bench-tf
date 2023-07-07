module "ecs_service_main" {
  source = "./modules/ecs_fargate_service"
  service_name           = "main"
  cpu                    = 256
  memory                 = 512
  capacity_provider_name = "FARGATE"
  execution_role_arn     = var.global_params.execution_role_arn
  task_role_arn          = var.global_params.task_role_arn
  network_configuration = {
    subnets          = aws_subnet.public.*.id
    security_groups  = [aws_security_group.ecs_container.id, aws_security_group.main_default.id]
    assign_public_ip = true
  }
  repository_url = "${local.ecr_uri}/${var.global_params.prefix}-ecs-main"
  container_env = [
    {
      name  = "API_LISTEN_PORT"
      value = "80"
    },
    {
      name  = "FLUTTER_ORIGIN"
      value = var.global_params.env == "prd" ? "" : "http://localhost:4005"
    },
    {
      name  = "HOST_DOMAIN"
      value = var.global_params.domain
    },
    {
      name  = "HOST_PORT"
      value = ""
    },
    {
      name  = "PROTOCOL"
      value = "https"
    },
    {
      name  = "ENV"
      value = var.global_params.env
    },
    {
      name  = "AWS_REGION"
      value = data.aws_region.current.name
    },
    {
      name  = "GIN_MODE"
      value = var.global_params.env == "prd" ? "release" : "debug"
    },
    {
      name  = "TIMELINE_RDS_ENDPOINT"
      value = aws_rds_cluster.timeline.endpoint
    },
    {
      name  = "SQS_WIP_URL"
      value = aws_sqs_queue.wip.url
    },
    {
      name  = "SQS_READY_URL"
      value = aws_sqs_queue.ready.url
    },
    {
      name  = "USER_TABLE"
      value = "flicspy-${var.global_params.env}-ms-user-user"
    },
    {
      name  = "ACTIVITY_TABLE"
      value = var.global_params.activity_table
    },
    {
      name  = "FOLLOW_TABLE"
      value = var.global_params.follow_table
    },
    # {
    #   name  = "TIMELINE_RDS_PROXY_ENDPOINT"
    #   value = aws_db_proxy.main.endpoint
    # },
    {
      name  = "RSH_WORKGROUP"
      value = aws_redshiftserverless_workgroup.main.workgroup_name
    },
    {
      name  = "RSH_ROLE_ARN"
      value = var.global_params.redshift_role_arn
    },
  ]
  #   container_secrets = [
  #     {
  #       name      = "FIREBASE_ADMIN_KEY"
  #       valueFrom = var.global_params.firebase_admin_key_arn
  #     }
  #   ]

  service_registry_arn = aws_service_discovery_service.this.arn
  arch                 = "x86"

  common = local.service_common_params
}

