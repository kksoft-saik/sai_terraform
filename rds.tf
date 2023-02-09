/*
resource "aws_rds_cluster" "saidb" {
  cluster_identifier      = "aurora-cluster-demo"
  engine = "aurora"
  engine_version = "5.6.mysql_aurora.1.22.3"
  availability_zones      = ["ap-northeast-1a"]
  database_name           = "mydb"
  master_username         = "foo"
  master_password         = "foo12345"
  backup_retention_period = 10
  preferred_backup_window = "07:00-09:00"
  copy_tags_to_snapshot = false
  final_snapshot_identifier = "id-saidb"
  skip_final_snapshot = true
  engine_mode = "serverless"
}

 #   engine_version ="5.7.mysql_aurora.2.08.3"
 
resource "aws_s3_bucket_object" "object" {
  bucket = "saikous3"
  key    = "new_object_key"
  etag = aws_rds_cluster.saidb.final_snapshot_identifier
}*/