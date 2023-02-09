
############################################################################
# VPC
############################################################################
resource "aws_vpc" "saivpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "sai-vpc"
  }
}

resource "aws_subnet" "private-ap-northeast-1a" {
 vpc_id= aws_vpc.saivpc.id
  cidr_block = "10.0.0.0/16"
 availability_zone = "ap-northeast-1a"

  tags={
  name="private-ap-northeast-1a"
 }
}
