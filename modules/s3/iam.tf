resource "aws_iam_role" "replication" {
  count = var.use_replication ? 1 : 0
  name  = "${var.prefix}-${var.bucket_name}-s3-replication"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "s3.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
POLICY
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_iam_role_policy_attachment" "replication" {
  count      = var.use_replication ? 1 : 0
  role       = aws_iam_role.replication[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}
