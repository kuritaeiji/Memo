terraform {
  required_version = "~> 1.0"

  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    key = "examples/storage/log-s3/terraform.tfstate"
  }
}

provider "aws" {
  region = "ap-northeast-1"
  profile = "default"
}

resource "aws_s3_bucket" "alb_log" {
  bucket = "alb-log-kuritaeiji"
}

resource "aws_s3_bucket_lifecycle_configuration" "alb_log" {
  bucket = aws_s3_bucket.alb_log.id

  rule {
    id = "delete-in-180"
    status = "Enabled"

    expiration {
      days = 180
    }
  }
}

resource "aws_s3_bucket_policy" "alb_log" {
  bucket = aws_s3_bucket.alb_log.id
  policy = data.aws_iam_policy_document.alb_log.json
}

data "aws_iam_policy_document" "alb_log" {
  statement {
    effect = "Allow"
    actions = ["s3:PutObject"]
    # リソース="arn:aws:s3:::<バケット名>/AWSLogs/<AWSアカウントID>/*"
    resources = ["arn:aws:s3:::${aws_s3_bucket.alb_log.id}/AWSLogs/838135940574/*"]
    principals {
      type = "AWS"
      # identifiers=["arn:aws:iam::<LBのアカウント名>:root"]
      # 東京リージョンのLBのアカウントID=582318560864
      identifiers = ["arn:aws:iam::582318560864:root"]
    }
  }
}

data "aws_caller_identity" "current" {}