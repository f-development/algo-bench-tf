locals {
  ecr_uri = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${data.aws_region.current.name}.amazonaws.com"
}

resource "aws_cloudwatch_log_group" "rails" {
  name = "${local.prefix}-rails"
}

resource "aws_cloudwatch_log_group" "mysql" {
  name = "${local.prefix}-mysql"
}

resource "aws_ecs_cluster" "this" {
  name = local.prefix

  setting {
    name  = "containerInsights"
    value = "disabled"
  }
}

resource "aws_ecs_cluster_capacity_providers" "this" {
  cluster_name = aws_ecs_cluster.this.name

  capacity_providers = compact([
    "FARGATE",
    "FARGATE_SPOT"
  ])

  default_capacity_provider_strategy {
    capacity_provider = "FARGATE"
    weight            = 100
  }
}

resource "aws_ecs_service" "this" {
  name                 = "${local.prefix}-main"
  cluster              = local.prefix
  task_definition      = aws_ecs_task_definition.this.arn
  desired_count        = 1
  iam_role             = null
  force_new_deployment = true

  capacity_provider_strategy {
    capacity_provider = "FARGATE"
    weight            = 100
  }

  network_configuration {
    subnets          = [data.aws_subnet.public_1.id]
    security_groups  = [data.aws_security_group.main_default.id]
    assign_public_ip = true
  }

  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

  service_registries {
    registry_arn = aws_service_discovery_service.this.arn
    port         = 80
  }

  propagate_tags = "TASK_DEFINITION"

  tags = {
    "f:resource" = "ecs-service-main"
  }
}

resource "aws_ecs_task_definition" "this" {
  family                   = "${local.prefix}-main"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"

  cpu    = 256
  memory = 512

  container_definitions = jsonencode([
    {
      name      = "rails"
      image     = "${aws_ecr_repository.rails.repository_url}:linux-x86"
      essential = true
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
        }
      ]
      environment = [
        {
          name  = "DB_HOST"
          value = "127.0.0.1"
        },
        {
          name  = "DB_PORT"
          value = "3306"
        },
        {
          name  = "DB_USER"
          value = "root"
        },
        {
          name  = "DB_PASSWD"
          value = "password"
        },
        {
          name  = "BENCH_PORT"
          value = "80"
        },
        {
          name  = "RAILS_ENV"
          value = "production"
        },
        {
          name  = "SECRET_KEY_BASE"
          value = "abc"
        },
        {
          name  = "RAILS_SERVE_STATIC_FILES"
          value = "true"
        },
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.rails.name
          awslogs-region        = data.aws_region.current.name
          awslogs-stream-prefix = local.prefix
        }
      }
    },
    {
      name      = "mysql"
      image     = "${aws_ecr_repository.mysql.repository_url}:linux-x86"
      essential = true
      portMappings = [
        {
          containerPort = 3306
          hostPort      = 3306
        }
      ]
      environment = [
        {
          name  = "MYSQL_ROOT_PASSWORD"
          value = "password"
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.mysql.name
          awslogs-region        = data.aws_region.current.name
          awslogs-stream-prefix = local.prefix
        }
      }
    }
  ])

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }

  execution_role_arn = aws_iam_role.ecs_task_execution.arn
  task_role_arn      = aws_iam_role.ecs_main.arn

  tags = {
    "f:resource" = "ecs-task-main"
  }
}

