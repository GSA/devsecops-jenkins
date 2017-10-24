module "mgmt_vpc" {
  source = "github.com/GSA/terraform-aws-vpc"

  name = "${var.vpc_name}"

  cidr = "${var.vpc_cidr}"
  public_subnets  = ["${var.app_public_subnet_cidrs}"]
  private_subnets = ["${var.app_private_subnet_cidrs}"]
  database_subnets = ["${var.database_subnet_cidrs}"]

  enable_nat_gateway = "${var.enable_nat_gateway}"
  enable_dns_hostnames = "${var.enable_dns_hostnames}"
  enable_dns_support = "${var.enable_dns_support}"

  azs = ["${var.aws_az1}", "${var.aws_az2}"]

  create_database_subnet_group = "${var.create_database_subnet_group}"

# TODO: Update tags to conform to DevSecOps Framework
  tags {
    "Terraform" = "true"
    "Repository" = "https://github.com/GSA/DevSecOps"
  }
}

module "vpc_flow_log" {
  source = "github.com/GSA/DevSecOps//terraform//modules//vpc_flow_log"
  vpc_name = "${var.vpc_name}"
  vpc_id = "${module.mgmt_vpc.vpc_id}"
}

resource "aws_route53_zone" "vpc_private_zone" {
  name = "${var.private_vpc_zone_name}"
  vpc_id = "${module.mgmt_vpc.vpc_id}"
}