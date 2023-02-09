/*
##############################################################################
# EC2インスタンス
##############################################################################
resource "aws_instance" "ec2" {
  for_each = {
    "a" = "1"
    "c" = "2"
  }
 ami                         = data.aws_ssm_parameter.amzn2_latest_ami.value
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.ec2_subnet["${each.key}"].id
  vpc_security_group_ids = [aws_security_group.sg_ec2.id]
  tags = {
    Name = "sai-ec2-1${each.key}"
  }
}

# EC2用プライベートサブネット

resource "aws_subnet" "ec2_subnet" {
    for_each = {
    "a" = "10.0.4.0/24"
    "c" = "10.0.5.0/24"
  }
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = each.value
  availability_zone = "ap-northeast-1${each.key}"
  tags = {
    Name = "public-ap-northeast-1${each.key}"
  }
}

# EC2作成
resource "aws_instance" "sai-alb_ec2"{
  ami                         = data.aws_ssm_parameter.amzn2_latest_ami.value
  instance_type               = "t2.micro"
  #availability_zone           =  "ap-northeast-1a"
  vpc_security_group_ids      = [ aws_security_group.sg_ec2.id]
  
  subnet_id                   =aws_subnet.alb_subnet.public-ap-northeast-1a.id
  associate_public_ip_address = "true"
  tags = {
    Name = "sai-alb_ec2"
  }
}

# EC2用セキュリティグループ
resource "aws_security_group" "sg_ec2" {
  name        = "test-sg-ec2"
  description = "Allow http from ALB"
  vpc_id      = aws_vpc.vpc.id
}


resource "aws_security_group" "sg_alb" {
  name        = "test-sg-alb"
  description = "Allow http from NLB"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"
    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }
  egress {
    cidr_blocks = [
      "0.0.0.0/0",
    ]
    from_port = 80
    protocol  = "tcp"
    to_port   = 80
  }
}
# EC2用セキュリティグループのインバウンドへALBのセキュリティグループをソースに指定
resource "aws_security_group_rule" "sg_ec2_rule" {
  type                     = "ingress"
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.sg_alb.id
  from_port                = 80
  security_group_id        = aws_security_group.sg_ec2.id
}
*/