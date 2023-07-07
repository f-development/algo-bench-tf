output "arn" {
  value = aws_s3_bucket.my.arn
}

output "id" {
  value = aws_s3_bucket.my.id
}

output "bucket_regional_domain_name" {
  value = aws_s3_bucket.my.bucket_regional_domain_name
}

output "bucket_domain_name" {
  value = aws_s3_bucket.my.bucket_domain_name
}
