resource "aws_cloudwatch_metric_alarm" "validator" {
  alarm_description  = "This metric auto recovers EC2 instances"
  alarm_name         = "hnt-validator-autorecovery-${random_id.validator.hex}-${count.index}"
  evaluation_periods = "2"
  namespace          = "AWS/EC2"
  period             = "60"

  alarm_actions = ["arn:aws:automate:${data.aws_region.current.name}:ec2:recover"]

  comparison_operator = "GreaterThanThreshold"
  metric_name         = "StatusCheckFailed_System"
  statistic           = "Minimum"
  threshold           = "0.0"

  dimensions = {
    InstanceId = aws_instance.validator[count.index].id
  }

  tags = merge({
    Name = "hnt-validator-${random_id.validator.hex}-${count.index}"
  }, var.validator_tags)

  count = var.validator_autorecover ? var.validator_count : 0
}
