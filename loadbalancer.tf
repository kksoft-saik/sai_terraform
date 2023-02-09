
#---------------------------------------------------------------------------
# NLB
#---------------------------------------------------------------------------
/*
# NLB本体
resource "aws_lb" "nlb" {
  name               = "test-nlb"
  internal           = false
  load_balancer_type = "application"#"network"#sai

  subnets = [
    aws_subnet.ec2_subnet["a"].id,
    aws_subnet.ec2_subnet["c"].id
  ]
  
 subnet_mapping {
  subnet_id =  aws_subnet.ec2_subnet["a"].id
  # private_ipv4_address = "${element(var.target_list, 0)}"
  allocation_id = aws_eip.one.id
 }
 subnet_mapping {
 subnet_id =  aws_subnet.ec2_subnet["c"].id
#  private_ipv4_address = "${element(var.target_list, 1)}"
 allocation_id = aws_eip.two.id
 }

  #enable_deletion_protection = true
  enable_cross_zone_load_balancing = true
  ip_address_type = "ipv4"

    access_logs {
    bucket = aws_s3_bucket.lb-logssai3.bucket
    enabled = true
  }
    tags = {
    Name = "test-nlb"
  }
}
resource "aws_eip" "one" {
  vpc                       = true
  lifecycle {
   prevent_destroy = true
  }
}
resource "aws_eip" "two" {
  vpc                       = true
  lifecycle {
   prevent_destroy = true
  }
}

# NLBのリスナー設定（NLBとターゲットグループの紐づけ）
resource "aws_lb_listener" "listener_nlb" {
  load_balancer_arn = aws_lb.nlb.arn
  port              = "443"
  protocol          = "HTTP"#"TCP"#sai
  #ssl_policy = "ELBSecurityPolicy-2016-08"
  #certificate_arn = aws_acm_certificate.cert.arn
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg_nlb.arn
  }
}
# NLBのターゲットグループ
resource "aws_lb_target_group" "tg_nlb" {
  name        = "test-tg-nlb"
  port        = 8080
  protocol    = "HTTP"#"TCP"#sai
  vpc_id      = aws_vpc.vpc.id
  deregistration_delay =300 
  target_type = "ip"#"instance" #sai
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

resource "aws_lb_target_group_attachment" "alb" {
  count ="${length(var.target_list)}"
  target_group_arn = aws_lb_target_group.tg_nlb.arn
  target_id        = "${element(var.target_list, count.index)}"
  port             = 8080
}*/
