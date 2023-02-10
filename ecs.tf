
resource "aws_ecs_cluster" "cluster1" {
  name = "ecs-claster-1"
}

resource "aws_ecs_task_definition" "cluster-task1" {
  family                   = "cluster-task"
  cpu                      = 256
  memory                   = 512
  container_definitions = templatefile("task/task.json",{
    log_env ="test"
  })
  execution_role_arn       = aws_iam_role.ecs_task_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn

  requires_compatibilities = ["EC2"]
  network_mode             = "awsvpc"

  depends_on = [aws_cloudwatch_log_group.sai-server]
}

resource "aws_ecs_service" "service" {
  name            = "cluster-task"
  cluster         = aws_ecs_cluster.cluster1.id
  task_definition = aws_ecs_task_definition.cluster-task1.arn
  desired_count   = var.server_instances

  deployment_circuit_breaker {
    enable = true
    rollback = true
  }
    placement_constraints {
    # インスタンスごとに 1 つのタスクのみを配置します
    type = "distinctInstance" 
  }
  network_configuration {
    subnets = [aws_subnet.private-ap-northeast-1a.id]
  }
    lifecycle {
    ignore_changes = [task_definition]
  }
}


# awslogs
resource "aws_cloudwatch_log_group" "sai-server" {
  name = "awslogs-sai-server-log"
}