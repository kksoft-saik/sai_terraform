
resource "aws_ecs_cluster_capacity_providers" "dictionary-server-ccp" {
  cluster_name = "${var.prefix}dictionary-server-ccp"
  capacity_providers = [aws_ecs_capacity_provider.dictionary-server-cp.name]
  default_capacity_provider_strategy {
    base              = 0
    weight            = 1
    capacity_provider = aws_ecs_capacity_provider.dictionary-server-cp.name
  }
}
resource "aws_ecs_capacity_provider" "dictionary-server-cp" {
  name = "${var.prefix}dictionary-server-cp"

  auto_scaling_group_provider {
    auto_scaling_group_arn = aws_autoscaling_group.dictionary-server-ag.arn
    managed_scaling {
      maximum_scaling_step_size = 10000
      minimum_scaling_step_size = 1
      status                    = "ENABLED"
      target_capacity           = 100
    }
  }
}
resource "aws_autoscaling_group" "dictionary-server-ag" {
  name                      = "${var.prefix}dictionary-server-cp"
  max_size                  = var.server_instances
  min_size                  = var.server_instances
  health_check_grace_period = 0
  health_check_type         = "EC2"
  desired_capacity          = 1

  vpc_zone_identifier       =  [aws_subnet.private-ap-northeast-1a.id]
  

  launch_template {
    id      = aws_launch_template.launch_template-ecs.id
    version = "$Latest"
  }

  #target_group_arns = var.target_group_arns

  #vpc_zone_identifier =  [
 #   aws_subnet.private-ap-northeast-1a.id
#  ]
  #load_balancers      = var.load_balancers
  enabled_metrics = [
    "GroupMinSize",
    "GroupMaxSize",
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupPendingInstances",
    "GroupStandbyInstances",
    "GroupTerminatingInstances",
    "GroupTotalInstances",
  ]

  lifecycle {
    ignore_changes = ["desired_capacity"]
  }

  timeouts {
    delete = "15m"
  }

}


resource "aws_launch_template" "launch_template-ecs" {
  name = "launch_template-ecs"

  instance_type = var.server_instance_type
  image_id      = "ami-0fcfb0266308303f6"
  ebs_optimized = false

  iam_instance_profile {
    arn = aws_iam_instance_profile.instance_profile.arn
  }

  user_data = base64gzip(templatefile("shell/user_data_ecs.sh", {
    cluster_name = aws_ecs_cluster.cluster1.name
    docker_image   = ""
    mysql_host     = ""
    mysql_username = ""
    mysql_password = var.aurora_master_password
    redis_host     = ""

    jvm_metaspace_size = var.jvm_metaspace_size
    jvm_heap_size      = var.jvm_heap_size

    tomcat_max_keep_alive_requests = 75000
    tomcat_keep_alive_timeout      = 10
    compression_enabled            = false
  }))

  tags = {
    Application = var.application
    Stack       = var.stack
  }

  tag_specifications {
    resource_type = "instance"
  tags = {
    Application = var.application
    Stack       = var.stack
  }
  }

  tag_specifications {
    resource_type = "volume"

  tags = {
    Application = var.application
    Stack       = var.stack
  }
  }

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_type           = "gp2"
      volume_size           = 100
      delete_on_termination = true
    }
  }

  network_interfaces {
    associate_public_ip_address = true
    delete_on_termination       = true
  }
    depends_on = [aws_ecs_cluster.cluster1]
}

