resource "aws_iam_role" "rds_proxy" {
  name = "${local.prefix}-rds-proxy"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "",
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "rds.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })

  inline_policy {
    name = "read-secret"
    policy = jsonencode({
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Action" : [
            "secretsmanager:GetResourcePolicy",
            "secretsmanager:GetSecretValue",
            "secretsmanager:DescribeSecret",
            "secretsmanager:ListSecretVersionIds",
            "secretsmanager:GetRandomPassword",
            "secretsmanager:ListSecrets"
          ],
          "Resource" : "*",
        },
      ]
    })
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_iam_role" "lambda_divide" {
  name = "${local.prefix}-lambda-divide"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : "sts:AssumeRole",
        "Principal" : {
          "Service" : "lambda.amazonaws.com"
        },
        "Effect" : "Allow"
      }
    ]
  })

  inline_policy {
    name = "all"
    policy = jsonencode({
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Action" : [
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:PutLogEvents",
            "ecr:*",
            "dynamodb:DescribeStream",
            "dynamodb:GetRecords",
            "dynamodb:GetShardIterator",
            "dynamodb:ListStreams",
            "dynamodb:Query",
            "dynamodb:GetItem",
            "dynamodb:PutItem",
            "sqs:SendMessage",
            "sqs:DeleteMessage",
            "sqs:ChangeMessageVisibility",
            "sqs:ReceiveMessage",
            "sqs:TagQueue",
            "sqs:UntagQueue",
            "sqs:PurgeQueue",
            "sqs:GetQueueAttributes",
            "ec2:CreateNetworkInterface",
            "ec2:DescribeNetworkInterfaces",
            "ec2:DeleteNetworkInterface",
            "rds-db:connect",
            "kms:*",
            "s3:*",
            "redshift-serverless:*",
            "redshift-data:*",
          ],
          "Resource" : "*"
        }
      ]
    })
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_iam_role" "ecs_task_execution" {
  name = "${local.prefix}-ecs-task-execution"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "",
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "ecs-tasks.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })
  inline_policy {
    name = "GetSsmParameter"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action = [
            "ssm:GetParameters",
          ]
          Effect   = "Allow"
          Resource = "*"
        }
      ]
    })
  }
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy",
  ]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_iam_role" "ecs_main" {
  name = "${local.prefix}-ecs-main"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "",
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "ecs-tasks.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })
  inline_policy {
    name = "all"
    policy = jsonencode({
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Action" : [
            "dynamodb:*",
            "sqs:SendMessage",
            "sqs:DeleteMessage",
            "sqs:ChangeMessageVisibility",
            "sqs:ReceiveMessage",
            "sqs:TagQueue",
            "sqs:UntagQueue",
            "sqs:PurgeQueue",
            "sqs:GetQueueAttributes",
            "rds-db:connect",
            "redshift-serverless:*",
            "redshift-data:*",
          ],
          "Resource" : "*"
        }
      ]
    })
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_iam_role" "lamdbda_stop_rds" {
  name = "${local.prefix}-lambda-stop-rds"

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : "sts:AssumeRole",
        "Principal" : {
          "Service" : "lambda.amazonaws.com"
        },
        "Effect" : "Allow"
      }
    ]
  })
  inline_policy {
    name = "Devops"
    policy = jsonencode({
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Action" : [
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:PutLogEvents",
            "ecr:*",
            "rds:*",
          ],
          "Resource" : "*"
        }
      ]
    })
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_iam_role" "redshift" {
  name = "${local.prefix}-redshift"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : [
            "sagemaker.amazonaws.com",
            "redshift.amazonaws.com",
            "redshift-serverless.amazonaws.com"
          ]
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })

  inline_policy {
    name = "S3"
    policy = jsonencode({
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Action" : ["s3:*"],
          "Resource" : "*"
        }
      ]
    })
  }

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonRedshiftAllCommandsFullAccess"
  ]

  lifecycle {
    create_before_destroy = true
  }
}
