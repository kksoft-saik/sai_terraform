variable "aws_access_key" {}
variable "aws_secret_key" {}

provider "aws" {
  region     = "ap-northeast-1"
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}


#
#resource "aws_iam_role" "aws_iam_glue_role" {
#  name = "AWSGlueServiceRoleDefault"
#
#  assume_role_policy = <<EOF
#{
#  "Version": "2012-10-17",
#  "Statement": [
#    {
#      "Action": "sts:AssumeRole",
#      "Principal": {
#        "Service": "glue.amazonaws.com"
#      },
#      "Effect": "Allow",
#      "Sid": ""
#    }
#  ]
#}
#EOF
#}
#resource "aws_iam_role_policy_attachment" "glue_service_attachment" {
#  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
#  role = aws_iam_role.aws_iam_glue_role.id
#}