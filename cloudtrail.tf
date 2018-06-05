# S3
# S3 policy
data "aws_iam_policy_document" "s3-traillog_policy" {
    statement {
        sid = "AWSTrailLogsBucketPermissionsCheck"
  	    effect = "Allow"
        principals = {
            type = "Service"
            identifiers = ["cloudtrail.amazonaws.com"]
        }
        actions = ["s3:GetBucketAcl"]
        resources = ["arn:aws:s3:::awslogs-cloudtrail-${data.aws_caller_identity.current.account_id}"]
    }
    statement {
        sid = "AWSTrailLogsBucketDelivery"
        effect = "Allow"
        principals = {
            type = "Service"
            identifiers = ["cloudtrail.amazonaws.com"]
        }
        actions = ["s3:PutObject"]
        resources = ["arn:aws:s3:::awslogs-cloudtrail-${data.aws_caller_identity.current.account_id}/*"]
        condition = {
            test = "StringEquals"
            variable = "s3:x-amz-acl" 
            values = ["bucket-owner-full-control"]
        }
    }
}

## S3 Bucket
resource "aws_s3_bucket" "s3-traillog" {
  bucket = "awslogs-cloudtrail-${data.aws_caller_identity.current.account_id}"
  force_destroy = true
  policy = "${data.aws_iam_policy_document.s3-traillog_policy.json}"

  lifecycle_rule {
    id = "trailsLifeCycle"
    enabled = true
    expiration {
      days = "${var.trail-expired-day}"
    }
  }
}

# CloudTrail
resource "aws_cloudtrail" "trails" {
  name = "trails"
  s3_bucket_name = "${aws_s3_bucket.s3-traillog.id}"
  include_global_service_events = true
  enable_log_file_validation = true 
  is_multi_region_trail = true
  cloud_watch_logs_role_arn = "${aws_iam_role.trails-role.arn}"
  cloud_watch_logs_group_arn = "${aws_cloudwatch_log_group.trails-loggroup.arn}"
}

resource "aws_cloudwatch_log_group" "trails-loggroup" {
  name_prefix = "/cloudtrail/trails"
  retention_in_days = "${var.cw-log-retention-days}"
}

## IAM-Role
resource "aws_iam_role" "trails-role" {
  name = "trails-role"
  assume_role_policy = "${data.aws_iam_policy_document.trails-role-data.json}"
}
resource "aws_iam_role_policy" "trails-rolepolicy-attach" {
  name = "trails-rolepolicy"
  role = "${aws_iam_role.trails-role.id}"
  policy = "${data.aws_iam_policy_document.trails-rolepolicy-data.json}"
}

## Role-Policy
data "aws_iam_policy_document" "trails-role-data" {
    statement {
  	    effect = "Allow"
        principals = {
            type        = "Service"
            identifiers = [
                "cloudtrail.amazonaws.com"
                ]
        }
        actions = [
            "sts:AssumeRole"
            ]
    }
}

## Role-Policy
data "aws_iam_policy_document" "trails-rolepolicy-data" {
    statement {
        effect = "Allow"
        actions = [
            "logs:CreateLogStream",
            "logs:PutLogEvents"
            ]
        resources = [
            "*"
            ]
    }
}