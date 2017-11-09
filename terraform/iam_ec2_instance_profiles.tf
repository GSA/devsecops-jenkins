resource "aws_iam_role" "jenkins_master_ec2_role" {
    name = "${var.jenkins_iam_role_name}"
    assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
            "Service": "ec2.amazonaws.com"
            },
                "Effect": "Allow",
            "Sid": ""
        }
    ]
}
EOF
}

resource "aws_iam_policy" "jenkins_iam_role_permissions" {
  name        = "jenkins_aws_permissions"
  path        = "/"
  description = "Jenkins AWS permissions"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
        "Sid": "AllowActions",
        "Effect": "Allow",
        "Action": [
            "ec2:*",
            "rds:*",
            "dynamodb:*"
        ],
        "Resource": "*"
    },
    {
        "Sid": "AllowS3Buckets",
        "Effect": "Allow",
        "Action": [
            "s3:CreateBucket",
            "s3:GetObject",
            "s3:ListAllMyBuckets"
        ],
        "Resource": [
            "*"
        ]
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "add_jenkins_policy" {
    role       = "${aws_iam_role.jenkins_master_ec2_role.name}"
    policy_arn = "${aws_iam_policy.jenkins_iam_role_permissions.arn}"
}

resource "aws_iam_instance_profile" "jenkins_master_ec2_instance_profile" {
    name = "jenkins_master_ec2_instance_profile"
    role = "${aws_iam_role.jenkins_master_ec2_role.name}"
}