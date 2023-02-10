/*data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "role" {
  name               = "doc_role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json

}*/


data "aws_iam_policy_document" "task-assume-role-policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs_task_role" {
  name               = "ecs_task_role-sai-server"
  path               = "/system/"
  assume_role_policy = data.aws_iam_policy_document.task-assume-role-policy.json
}

resource "aws_iam_role_policy_attachment" "ecs_task_role_attach_ecs_task_execution" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

data "aws_iam_policy_document" "ecs_task_role_policy_document" {
  statement {
    effect = "Allow"

    actions = [
      "iam:CreateRole",
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

resource "aws_iam_role_policy_attachment" "ecs_task_role_policy_attachment" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = aws_iam_policy.ecs_task_role_policy.arn
}
resource "aws_iam_role" "role" {
  name               = "instance_profile"
  assume_role_policy = data.aws_iam_policy_document.task-assume-role-policy.json
}

resource "aws_iam_role_policy_attachment" "role_policy_attach_ecr_readonly" {
  role       = aws_iam_role.role.id
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_instance_profile" "instance_profile" {
  name = "instance_profile"
  path = "/"
  role = aws_iam_role.role.name
}