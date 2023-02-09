terraformer import aws --resources=vpc,subnet --connect=true --regions=ap-northeast-1
terraformer import aws --resources=vpc,subnet --filter=aws_vpc=vpc_id1:vpc_id2:vpc_id3 --regions=ap-northeast-1

bash -x terraform_exe/sh execute -q --use-assume-role

terraform init

terraform plan

terraform apply -auto-approve

create table mydb.user (id int, name varchar(10));
show tables
