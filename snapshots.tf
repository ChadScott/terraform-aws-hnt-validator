resource "aws_iam_role" "validator_dlm_role" {
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "dlm.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

  count = var.validator_snapshot_retention > 0 ? 1 : 0
}

resource "aws_iam_role_policy" "validator_dlm_lifecycle" {
  role = aws_iam_role.validator_dlm_role[0].id

  policy = <<EOF
{
   "Version": "2012-10-17",
   "Statement": [
      {
         "Effect": "Allow",
         "Action": [
            "ec2:CreateSnapshot",
            "ec2:CreateSnapshots",
            "ec2:DeleteSnapshot",
            "ec2:DescribeInstances",
            "ec2:DescribeSnapshots",
            "ec2:DescribeVolumes"
         ],
         "Resource": "*"
      },
      {
         "Effect": "Allow",
         "Action": [
            "ec2:CreateTags"
         ],
         "Resource": "arn:aws:ec2:*::snapshot/*"
      }
   ]
}
EOF

  count = var.validator_snapshot_retention > 0 ? 1 : 0
}

resource "aws_dlm_lifecycle_policy" "validator" {
  description        = "Helium Validator ${random_id.validator.hex} automatic snapshot"
  execution_role_arn = aws_iam_role.validator_dlm_role[0].arn
  state              = "ENABLED"

  policy_details {
    resource_types = ["VOLUME"]

    schedule {
      name = "Keep ${var.validator_snapshot_retention} daily backups"

      create_rule {
        interval      = 24
        interval_unit = "HOURS"
        times         = ["23:45"]
      }

      retain_rule {
        count = var.validator_snapshot_retention
      }

      tags_to_add = {
        SnapshotCreator = "DLM"
      }

      copy_tags = true
    }

    target_tags = {
      Name = "hnt-validator-${random_id.validator.hex}"
    }
  }

  count = var.validator_snapshot_retention > 0 ? 1 : 0
}
