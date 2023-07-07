resource "aws_appautoscaling_target" "this" {
  max_capacity       = 16
  min_capacity       = 1
  resource_id        = "service/${var.common.prefix}/${var.common.prefix}-${var.service_name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"

  depends_on = [
    aws_ecs_service.this
  ]
}

resource "aws_appautoscaling_policy" "this" {
  name               = "ECSServiceAverageCPUUtilization :${aws_appautoscaling_target.this.resource_id}"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.this.resource_id
  scalable_dimension = aws_appautoscaling_target.this.scalable_dimension
  service_namespace  = aws_appautoscaling_target.this.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    scale_in_cooldown  = 60
    scale_out_cooldown = 0
    target_value       = 20
  }
}

resource "aws_ecs_service" "this" {
  name                 = "${var.common.prefix}-${var.service_name}"
  cluster              = var.common.prefix
  task_definition      = aws_ecs_task_definition.this.arn
  desired_count        = 1
  iam_role             = null
  force_new_deployment = true

  capacity_provider_strategy {
    capacity_provider = var.capacity_provider_name
    weight            = 100
  }

  network_configuration {
    subnets          = var.network_configuration.subnets
    security_groups  = var.network_configuration.security_groups
    assign_public_ip = var.network_configuration.assign_public_ip
  }

  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

  service_registries {
    registry_arn = var.service_registry_arn
    port         = 80
  }

  propagate_tags = "TASK_DEFINITION"

  tags = {
    "f:resource" = "ecs-service-${var.service_name}"
  }

  lifecycle {
    ignore_changes = [desired_count]
  }
}

resource "aws_ecs_task_definition" "this" {
  family                   = "${var.common.prefix}-${var.service_name}"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"

  cpu    = var.cpu
  memory = var.memory

  container_definitions = jsonencode([
    {
      name              = var.service_name
      image             = "${var.repository_url}:linux-${var.arch}"
      command           = var.container_command
      essential         = true
      cpu               = var.cpu
      memoryReservation = var.memory
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
        }
      ]
      environment = var.container_env
      secrets     = var.container_secrets

      # mountPoints = [{
      #   sourceVolume  = "efs"
      #   containerPath = "/my/efs"
      #   readOnly      = false
      # }]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.this.name
          awslogs-region        = data.aws_region.current.name
          awslogs-stream-prefix = var.common.prefix
        }
      }
    }
  ])

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = var.arch == "arm" ? "ARM64" : "X86_64"
  }

  execution_role_arn = var.execution_role_arn
  task_role_arn      = var.task_role_arn

  tags = {
    "f:resource" = "ecs-task-${var.service_name}"
  }
}

