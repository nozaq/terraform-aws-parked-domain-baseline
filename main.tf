terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.40"
    }
  }
  required_version = ">= 1.3"
}

# Null MX record specified in RFC 7505
# https://datatracker.ietf.org/doc/rfc7505/
resource "aws_route53_record" "mx_root" {
  zone_id = var.zone_id
  type    = "MX"
  name    = ""
  records = ["0 ."]
  ttl     = var.ttl
}

resource "aws_route53_record" "mx_subdomains" {
  count = var.include_subdomains ? 1 : 0

  zone_id = var.zone_id
  type    = "MX"
  name    = "*"
  records = ["0 ."]
  ttl     = var.ttl
}

# Ensure all SPF validations to fail for the root domain.
resource "aws_route53_record" "spf_root" {
  zone_id = var.zone_id
  type    = "TXT"
  name    = ""
  records = ["v=spf1 -all"]
  ttl     = var.ttl
}

# Ensure all SPF validations to fail for subdomains.
resource "aws_route53_record" "spf_subdomains" {
  count = var.include_subdomains ? 1 : 0

  zone_id = var.zone_id
  type    = "TXT"
  name    = "*"
  records = ["v=spf1 -all"]
  ttl     = var.ttl
}

# Advise receivers to reject emails when DMARC alignment fails.
resource "aws_route53_record" "dmarc" {
  zone_id = var.zone_id
  type    = "TXT"
  name    = "_dmarc"
  records = [var.aggregate_feedback_email != "" ? "v=DMARC1; p=reject; rua=${var.aggregate_feedback_email}" : "v=DMARC1; p=reject;"]
  ttl     = var.ttl
}
