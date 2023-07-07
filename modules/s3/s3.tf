resource "aws_s3_bucket" "my" {
  bucket = "${var.prefix}-${var.bucket_name}"

  tags = {
    "f:resource" = "s3-${var.bucket_name}"
  }
}

resource "aws_s3_bucket_replication_configuration" "my" {
  count  = var.use_replication ? 1 : 0
  role   = aws_iam_role.replication[0].arn
  bucket = aws_s3_bucket.my.id

  dynamic "rule" {
    for_each = { for arn in var.replication_arns : index(var.replication_arns, arn) => arn }
    content {
      id       = tostring(rule.key)
      priority = rule.key
      status   = "Enabled"
      destination {
        bucket        = rule.value
        storage_class = "STANDARD"
      }
    }
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "my" {
  bucket = aws_s3_bucket.my.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "my" {
  bucket = aws_s3_bucket.my.id
  # block_public_acls       = var.enable_acl ? false : true
  block_public_acls = true
  # ignore_public_acls      = var.enable_acl ? false : true
  ignore_public_acls      = true
  block_public_policy     = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_ownership_controls" "my" {
  bucket = aws_s3_bucket.my.id

  rule {
    object_ownership = var.enable_acl ? "BucketOwnerPreferred" : "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_versioning" "my" {
  count  = (var.versioning || var.use_replication) ? 1 : 0
  bucket = aws_s3_bucket.my.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "my" {
  count      = var.versioning ? 1 : 0
  depends_on = [aws_s3_bucket_versioning.my[0]]

  bucket = aws_s3_bucket.my.bucket

  rule {
    id = "all"

    filter {}

    noncurrent_version_expiration {
      noncurrent_days = 1
    }

    status = "Enabled"
  }
}
