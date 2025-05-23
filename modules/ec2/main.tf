resource "aws_launch_template" "ec2_launch_template" {
  name = "ec2-launch-template"
  image_id = var.ami_id
  instance_type = var.instance_type
  key_name = var.key_name
  user_data = var.user_data

  vpc_security_group_ids = var.security_group_ids
}

resource "aws_autoscaling_group" "ec2_autoscaling_group" {
  name = "ec2-autoscaling-group"
  min_size = var.min_size
  max_size = var.max_size
  desired_capacity = var.desired_capacity
  health_check_type = "ELB"
  health_check_grace_period = var.health_check_grace_period
  target_group_arns = [var.target_group_arn]
  launch_template {
    id = aws_launch_template.ec2_launch_template.id
    version = "$Latest"
  }
  vpc_zone_identifier = var.subnet_id
}

resource "aws_autoscaling_policy" "target_tracking_policy" {
  name = "target-tracking-policy"
  policy_type = "TargetTrackingScaling"
  autoscaling_group_name = aws_autoscaling_group.ec2_autoscaling_group.name

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = var.target_cpu_value
  }
}