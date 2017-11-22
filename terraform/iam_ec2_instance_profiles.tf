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
            "cloudwatch:PutMetricAlarm",
            "cloudfront:ListDistributions",
            "elasticloadbalancing:DescribeLoadBalancers",
            "elasticbeanstalk:DescribeEnvironments",
            "sns:ListTopics",
            "sns:ListSubscriptionsByTopic",
            "cloudwatch:DescribeAlarms",
            "cloudwatch:GetMetricStatistics"
        ],
        "Resource": "*"
    },
    {
        "Sid": "AllowS3Buckets",
        "Effect": "Allow",
        "Action": [
            "s3:CreateBucket",
            "s3:GetObject",
            "s3:ListAllMyBuckets",
            "s3:ListBucket",
            "s3:GetBucketLocation",
            "s3:GetBucketWebsiteConfiguration"
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

resource "aws_iam_role_policy_attachment" "add_rds_policy" {
    role       = "${aws_iam_role.jenkins_master_ec2_role.name}"
    policy_arn = "arn:aws:iam::aws:policy/AmazonRDSFullAccess"
}

resource "aws_iam_role_policy_attachment" "add_ec2_policy" {
    role       = "${aws_iam_role.jenkins_master_ec2_role.name}"
    policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
}

resource "aws_iam_role_policy_attachment" "add_autoscaling_policy" {
    role       = "${aws_iam_role.jenkins_master_ec2_role.name}"
    policy_arn = "arn:aws:iam::aws:policy/AutoScalingFullAccess"
}

resource "aws_iam_role_policy_attachment" "add_s3_policy" {
    role       = "${aws_iam_role.jenkins_master_ec2_role.name}"
    policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
}

resource "aws_iam_role_policy_attachment" "add_dynamodb_policy" {
    role       = "${aws_iam_role.jenkins_master_ec2_role.name}"
    policy_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
}

resource "aws_iam_role_policy_attachment" "add_vpc_policy" {
    role       = "${aws_iam_role.jenkins_master_ec2_role.name}"
    policy_arn = "arn:aws:iam::aws:policy/AmazonVPCFullAccess"
}

resource "aws_iam_role_policy_attachment" "add_route53_policy" {
    role       = "${aws_iam_role.jenkins_master_ec2_role.name}"
    policy_arn = "arn:aws:iam::aws:policy/AmazonRoute53FullAccess"
}

resource "aws_iam_instance_profile" "jenkins_master_ec2_instance_profile" {
    name = "${var.jenkins_master_ec2_instance_profile_name}"
    role = "${aws_iam_role.jenkins_master_ec2_role.name}"
}