locals {
  buckets_with_website = toset([for each in var.buckets : each.name if each.is_website])
  bucket_policy        = toset([for each in var.buckets : each.name if each.acl == "public-read"])
  cors_configuration   = toset([for bucket_name, bucket_config in var.buckets : {
    bucket = bucket_name
    cors   = bucket_config.cors
  } if length(bucket_config.cors) > 0])
  tags = {
    Terraform = true
  }
} 

resource "aws_s3_bucket" "this" {
  for_each      = var.buckets
  bucket        = each.key
  force_destroy = each.value.force_destroy
  tags          = local.tags
}

resource "aws_s3_bucket_ownership_controls" "this" {
  for_each = var.buckets
  bucket   = aws_s3_bucket.this[each.key].id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "this" {
  for_each   = local.bucket_policy
  depends_on = [aws_s3_bucket_ownership_controls.this]
  bucket     = aws_s3_bucket.this[each.key].id
  acl        = each.value.is_website ? "public-read" : null
}

resource "aws_s3_bucket_versioning" "this" {
  for_each = var.buckets
  bucket   = aws_s3_bucket.this[each.key].id

  versioning_configuration {
    status = each.value.versioning == true ? "Enabled" : "Disabled"
  }
}

resource "aws_s3_bucket_policy" "this" {
  for_each = local.bucket_policy
  bucket   = aws_s3_bucket.this[each.key].id

  policy = <<POLICY
  {    
      "Version": "2012-10-17",    
      "Statement": [        
        {            
            "Sid": "PublicReadGetObject",            
            "Effect": "Allow",            
            "Principal": "*",            
            "Action": [                
              "s3:GetObject"            
            ],            
            "Resource": [
              "arn:aws:s3:::${aws_s3_bucket.this[each.key].id}/*"            
            ]        
        }    
      ]
  }
  POLICY
}

resource "aws_s3_bucket_website_configuration" "this" {
  for_each = local.buckets_with_website
  bucket   = aws_s3_bucket.this[each.key].id

  index_document {
    suffix = "index.html"
  }
}

resource "aws_s3_bucket_cors_configuration" "this" {
  for_each = { for cors in local.cors_configuration : cors.bucket => cors }
  bucket   = aws_s3_bucket.this[each.key].id

  dynamic "cors_rule" {
    for_each = each.value.cors

    content {
      allowed_headers = cors_rule.value.allowed_headers
      allowed_methods = cors_rule.value.allowed_methods
      allowed_origins = cors_rule.value.allowed_origins
      max_age_seconds = cors_rule.value.max_age_seconds
    }
  }
}