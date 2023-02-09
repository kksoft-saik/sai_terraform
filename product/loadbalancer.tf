/*module "s3" {
  rsurce = "s3"
}

resource "aw_lb" "test" {
  
  name               = "test-lb-tf3"
 # availability_zone = "ap-northeast-1"
  internal           = true
  load_balancer_type = "application"
 
 subnet_mapping{
  subnet_id = "subnet-03b91e9f117ff4c46"
  private_ipv4_address = "10.0.0.7"
 }

  enable_deletion_protection = true
  //access_logs {
   // bucket = aws_s3_bucket.lb-logssai3.bucket
   // enabled = true
  //}
  tags = {
    Environment = "production"
  }
  //depends_on = [module.aws_s3_bucket.lb-logssai3]
}

*/
