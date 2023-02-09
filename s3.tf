/*
data "aws_elb_service_account" main{}
data "aws_caller_identity" "self" { }


resource "aws_s3_bucket" "lb-logssai3" {
  bucket = "lb-logssai2"
}

resource "aws_s3_bucket_object" "folder1" {
    bucket = "${aws_s3_bucket.lb-logssai3.bucket}"
    acl    = "private"
    key    = "/AWSLogs/${data.aws_caller_identity.self.account_id}/"

    depends_on = [aws_s3_bucket.lb-logssai3]

  }

  data "aws_iam_policy_document" "alb_log" {

    statement {
    sid       = "AWSConsoleStmt"
    effect    = "Allow"
    actions   = [ "s3:PutObject" ]
    resources = ["arn:aws:s3:::lb-logssai2/AWSLogs/${data.aws_caller_identity.self.account_id}/*"]
    principals {
      type = "AWS"
      identifiers = ["${data.aws_elb_service_account.main.arn}"]
    }
  }
    statement {
    sid       = "AWSLogDeliveryWrite"
    effect    = "Allow"
    actions   = [ "s3:PutObject" ]
    resources = ["arn:aws:s3:::lb-logssai2/AWSLogs/${data.aws_caller_identity.self.account_id}/*"]
    principals {
      type = "Service"
      identifiers = [ "delivery.logs.amazonaws.com" ]
    }
  }
    statement {
    sid       = "AWSLogDeliveryAclCheck"
    effect    = "Allow"
    actions   = [ "s3:GetBucketAcl" ]
    resources = ["arn:aws:s3:::lb-logssai2"]
    principals {
      type = "Service"
      identifiers = [ "delivery.logs.amazonaws.com" ]
    }
  }

}
resource "aws_s3_bucket_policy" "alb_logs" {
  bucket = aws_s3_bucket.lb-logssai3.bucket
  #policy =  file("s3-policy.json")
  policy = data.aws_iam_policy_document.alb_log.json
 
  depends_on = [aws_s3_bucket.lb-logssai3]
}


*/