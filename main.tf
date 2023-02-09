 /*
resource "aws_acm_certificate" "cert" {
  domain_name       = "sai.nlb.ca.pf.org"
  validation_method = "DNS"
  lifecycle {
    create_before_destroy = true
  }
}
 
resource aws_route53_record cert_validation {
for_each = {
    for dvo in aws_acm_certificate.cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }
  zone_id = data.aws_route53_zone.sai_nlb_ca.id
  name    = tolist(aws_acm_certificate.cert.domain_validation_options)[0].resource_record_name
  type    = tolist(aws_acm_certificate.cert.domain_validation_options)[0].resource_record_type
 # records         = [each.value.record]
  records = [tolist(aws_acm_certificate.cert.domain_validation_options)[0].resource_record_value]
  ttl     = 60
}

data "aws_route53_zone" sai_nlb_ca{
 name = "sai.nlb.ca.pf.org"
}

resource aws_acm_certificate_validation cert {
  certificate_arn = aws_acm_certificate.cert.arn
  //  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]

  validation_record_fqdns = [aws_route53_record.cert_validation.fqdn]
}
############################################################################
# インターネットゲートウェイ
############################################################################

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "test-igw"
  }
}
*/
############################################################################
# サブネット
############################################################################
# NLB用パブリックサブネット
/*
resource "aws_subnet" "nlb_subnet" {
  for_each = {
    "a" = "10.0.0.0/24"
    "c" = "10.0.1.0/24"
  }
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = each.value
  availability_zone = "ap-northeast-1[${each.key}]"
  tags = {
    Name = "test-nlb-subnet-${each.key}"
  }
}

# ALB用プライベートサブネット
resource "aws_subnet" "alb_subnet" {
  for_each = {
    "a" = "10.0.2.0/24"
    "c" = "10.0.3.0/24"
  }
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = each.value
  availability_zone = "ap-northeast-1${each.key}"
  tags = {
    Name = "test-alb-subnet-${each.key}"
  }
}
*/
/*
############################################################################
# ルートテーブル
############################################################################
resource "aws_route_table" "public_route" {
  vpc_id = aws_vpc.vpc.id
  route {
    gateway_id = aws_internet_gateway.igw.id
    cidr_block = "0.0.0.0/0"
  }
  tags = {
    Name = "test-public-route"
  }
}

# サブネットとの紐づけ
resource "aws_route_table_association" "route_public_association" {
  for_each = {
    "a" = "1"
    "c" = "2"
  }
  subnet_id      = aws_subnet.nlb_subnet["${each.key}"].id
  route_table_id = aws_route_table.public_route.id
}*/

############################################################################
# セキュリティグループ
############################################################################
# ALB用セキュリティグループ

/*

resource "aws_kms_key" "lambda_key" {
  description             = "My Lambda Function Customer Master Key"
  enable_key_rotation     = true
  deletion_window_in_days = 7
}

resource "aws_kms_alias" "lambda_key_alias" {
  name          = "alias/my-lambda-key"
  target_key_id = aws_kms_key.lambda_key.id
}

data "archive_file" "function_source" {
  type        = "zip"
  source_dir  = "app"
  output_path = "archive/my_lambda_function.zip"
}

# Function
resource "aws_lambda_function" "get_unixtime" {
  function_name = "get_unixtime"

  handler                        = "src/lambda_handler"
  filename                       = "${data.archive_file.function_source.output_path}"
  runtime                        = "python3.8"
  #runtime                        = "${1==21 ? "python3.8" : "python3.7"}"
  role                           = "${aws_iam_role.lambda_iam_role.arn}"
  source_code_hash               = "${data.archive_file.function_source.output_base64sha256}"
 # layers = ["${aws_lambda_layer_version.lambda_layer.arn}"]
}

# Role
resource "aws_iam_role" "lambda_iam_role" {
  name = "iam_role"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
POLICY
}

# Policy
resource "aws_iam_role_policy" "lambda_access_policy" {
  name   = "lambda_access_policy"
  role   = "${aws_iam_role.lambda_iam_role.id}"
  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogStream",
        "logs:CreateLogGroup",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:*"
    }
  ]
}
POLICY
}

*/