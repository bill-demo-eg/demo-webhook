# Specify the provider and access details
provider "aws" {
  region = "${var.aws_region}"
}

# Create a VPC to launch our instances into
resource "aws_vpc" "acme_root" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "acme_root"
  }
}

# Create an internet gateway to give our subnet access to the outside world
resource "aws_internet_gateway" "acme_root" {
  vpc_id = "${aws_vpc.acme_root.id}"
  tags = {
    Name = "acme_root"
  }
}

# Grant the VPC internet access on its main route table
resource "aws_route" "acme_root" {
  route_table_id         = "${aws_vpc.acme_root.main_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.acme_root.id}"
}

# Create a subnet to launch our instances into
resource "aws_subnet" "acme_web" {
  vpc_id                  = "${aws_vpc.acme_root.id}"
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  tags = {
    Name = "acme_web"
  }
}

resource "aws_key_pair" "auth" {
  key_name   = "${var.key_name}"
  public_key = "${file(var.public_key_path)}"
}

resource "aws_s3_bucket" "acme_main" {
  bucket = "test-bucket"
  acl    = "private"
  versioning {
    enabled    = true
    mfa_delete = true
  }
  website {
    index_document = "index.html"
    error_document = "error.html"
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}
resource "aws_s3_bucket_policy" "acme_mainPolicy" {
  bucket = "${aws_s3_bucket.acme_main.id}"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "acme_main-restrict-access-to-users-or-roles",
      "Effect": "Allow",
      "Principal": [
        {
          "AWS": [
            "arn:aws:iam::##acount_id##:role/##role_name##",
            "arn:aws:iam::##acount_id##:user/##user_name##"
          ]
        }
      ],
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::${aws_s3_bucket.acme_main.id}/*"
    }
  ]
}
POLICY
}
resource "aws_flow_log" "acme_root" {
  vpc_id          = "${aws_vpc.acme_root.id}"
  iam_role_arn    = "##arn:aws:iam::111111111111:role/sample_role##"
  log_destination = "${aws_s3_bucket.acme_root.arn}"
  traffic_type    = "ALL"

  tags = {
    GeneratedBy      = "Accurics"
    ParentResourceId = "aws_vpc.acme_root"
  }
}
resource "aws_s3_bucket" "acme_root" {
  bucket        = "acme_root_flow_log_s3_bucket"
  acl           = "private"
  force_destroy = true

  versioning {
    enabled    = true
    mfa_delete = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}
resource "aws_s3_bucket_policy" "acme_root" {
  bucket = "${aws_s3_bucket.acme_root.id}"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "acme_root-restrict-access-to-users-or-roles",
      "Effect": "Allow",
      "Principal": [
        {
          "AWS": [
            "arn:aws:iam::##acount_id##:role/##role_name##",
            "arn:aws:iam::##acount_id##:user/##user_name##"
          ]
        }
      ],
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::${aws_s3_bucket.acme_root.id}/*"
    }
  ]
}
POLICY
}