variable "service_name" {

}

variable "cpu" {

}

variable "memory" {

}

# Only for Fargate
variable "network_configuration" {
  type = object({
    subnets          = list(string)
    security_groups  = list(string)
    assign_public_ip = bool
  })

  default = null
}

variable "container_env" {

}

variable "container_secrets" {
  default = null
}

variable "task_role_arn" {

}

variable "execution_role_arn" {

}

variable "capacity_provider_name" {

}

variable "container_command" {
  default = ["./main"]
}

variable "repository_url" {

}

variable "service_registry_arn" {

}

# https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_definition_parameters.html#runtime-platform
variable "arch" {

}

variable "common" {
  type = object({
    vpc_id      = string
    prefix      = string
    region_nick = string
    env         = string
  })
}
