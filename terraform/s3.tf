# TODO: Change to encrypted bucket: https://github.com/18F/cg-provision/blob/master/terraform/modules/s3_bucket/encrypted_bucket/encrypted_bucket.tf
# After discussing what to do about ecnryption-at-rest and GSA ISE KMS requirements.
# module "jenkins_master_s3_backup" {
#     source = "github.com/18F/cg-provision/terraform/modules/s3_bucket/encrypted_bucket"
#     bucket = "${var.jenkins_backup_s3_bucket}"
#     versioning = "true"
#     expiration_days = "30"
#     aws_partition = "${var.aws_partition}"
# }

resource "aws_s3_bucket" "jenkins_master_s3_backup" {
  bucket = "${var.jenkins_backup_s3_bucket}"
  acl = "${var.jenkins_backup_s3_bucket_acl}"

  versioning {
    enabled = true
  }

  lifecycle_rule {
    prefix = ""
    enabled = "${lookup(map("0", "false"), var.jenkins_backup_s3_bucket_expiration_days, "true")}"
    expiration {
        days = "${var.jenkins_backup_s3_bucket_expiration_days}"
    }
  }
}

resource "aws_s3_bucket_policy" "jenkins_master_s3_backup_bucket_policy" {
  bucket = "${aws_s3_bucket.jenkins_master_s3_backup.id}"
  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Id": "Policy1505253515205",
    "Statement": [
        {
            "Sid": "Stmt1505253385762",
            "Effect": "Allow",
            "Principal": {
                "AWS": "${aws_iam_role.jenkins_master_ec2_role.arn}"
            },
            "Action": "s3:*",
            "Resource": "${aws_s3_bucket.jenkins_master_s3_backup.arn}"
        },
        {
            "Sid": "Stmt1505253513853",
            "Effect": "Allow",
            "Principal": {
                "AWS": "${aws_iam_role.jenkins_master_ec2_role.arn}"
            },
            "Action": "s3:*",
            "Resource": "${aws_s3_bucket.jenkins_master_s3_backup.arn}/*"
        },
        {
            "Sid": "DenyUnencryptedPut",
            "Effect": "Deny",
            "Principal": {
                "AWS": "*"
            },
            "Action": "s3:PutObject",
            "Resource": "${aws_s3_bucket.jenkins_master_s3_backup.arn}/*",
            "Condition": {
                "StringNotEquals": {
                    "s3:x-amz-server-side-encryption": "AES256"
                }
            }
        }
    ]
}
POLICY
}