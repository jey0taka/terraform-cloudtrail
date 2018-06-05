# Provider
provider "aws" {
  region     = "${var.region}"
}

# General
data "aws_caller_identity" "current" {}

# AWS
variable "region" {
  default = "ap-northeast-1"
}
variable "trail-expired-day" {
  default = "2557"
}
variable "cwlogs-retention-days" {
  default = "30"
}
