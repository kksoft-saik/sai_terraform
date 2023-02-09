/*
data "aws_subnet" "public-ap-northeast-1a" {
 vpc_id= aws_vpc.vpc.id
 filter {
  name="tag:Name"
  values=["test-ec2-subnet-a"]
 }
}

data "aws_subnet" "public-ap-northeast-1c" {
 vpc_id= aws_vpc.vpc.id
  filter {
  name="tag:Name"
  values=["public-ap-northeast-1c"]
 }
}

data "aws_subnet" "public-ap-northeast-1d" {
 vpc_id= aws_vpc.vpc.id
  filter {
  name="tag:Name"
  values=["public-ap-northeast-1d"]
 }
}
*/

/*
data "aws_ssm_parameter" "amzn2_latest_ami" {
  name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}*/
