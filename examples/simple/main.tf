terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.40"
    }
  }

  required_version = ">= 1.3"
}

provider "aws" {
}

data "aws_route53_zone" "this" {
  name = var.zone_name
}

module "parked_domain" {
  source = "../../"

  zone_id = data.aws_route53_zone.this.zone_id
  ttl     = 86400 # One day
}
