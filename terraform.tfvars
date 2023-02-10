aws_access_key = "AKIATTVTOE5FO6F36I6A"
aws_secret_key = "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"


prefix     = "sai-"
dns_prefix = "sai-"
stack      = "saing"

application = "aaa"

aurora_master_password = "sss"
aurora_max_capacity    = 1
aurora_min_capacity    = 1

source_ips = [
 ]

server_instance_type = "t2.micro"
server_instances     = 1

jvm_heap_size      = "1g"
jvm_metaspace_size = "128m"

redis_availability_zones = ["ap-northeast-1a", "ap-northeast-1c"]
