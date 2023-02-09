
resource "aws_ecs_cluster" "cluster1" {
  name = "ecs-claster-1"
  capacity_providers =["FARGATE"]
  default_capacity_provider_strategy{
  base =1
  capacity_provider ="FARGATE"
  weight =1
}
}

resource "aws_ecs_task_definition" "cluster-task1" {
  family                   = "cluster-task"
  cpu                      = 256
  memory                   = 512

  container_definitions = templatefile("task/task.json",{
    log_env ="test"
  })
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
}

resource "aws_ecs_service" "service" {
  name            = "cluster-task"
  cluster         = aws_ecs_cluster.cluster1.id
  task_definition = aws_ecs_task_definition.cluster-task1.arn
  desired_count   = 0

  network_configuration {
    subnets = [aws_subnet.private-ap-northeast-1a.id]
  }
}


data "aws_iam_policy_document" "ecs_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

data "aws_iam_policy" "ecs_task_execution_role_policy" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name               = "MyEcsTaskExecutionRole"
  assume_role_policy = data.aws_iam_policy_document.ecs_assume_role.json
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy_attachment" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = data.aws_iam_policy.ecs_task_execution_role_policy.arn
}

data "aws_iam_policy_document" "ecs_task_role_policy_document" {
  statement {
    effect = "Allow"

    actions = [
      "logs:DescribeLogStreams",
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]

    resources = ["*"]
  }
}
resource "aws_iam_policy" "ecs_task_role_policy" {
  name   = "MyEcsTaskPolicy"
  policy = data.aws_iam_policy_document.ecs_task_role_policy_document.json
}

resource "aws_iam_role" "ecs_task_role" {
  name               = "MyEcsTaskRole"
  assume_role_policy = data.aws_iam_policy_document.ecs_assume_role.json
}

resource "aws_iam_role_policy_attachment" "ecs_task_role_policy_attachment" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = aws_iam_policy.ecs_task_role_policy.arn
}