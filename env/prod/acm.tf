resource "aws_acm_certificate" "prod_cert" {
  provider    = aws.us_east_1
  domain_name = "rajdevops.click"
  # Optional: adds support for subdomains like www.rajdevops.click
  subject_alternative_names = ["*.rajdevops.click"]
  validation_method         = "DNS"

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Environment = "prod"
    Project     = "vegan-studio"
  }
}

# OUTPUTS: These provide the exact strings you need to paste into your other account
output "validation_record_name" {
  description = "CNAME Name to add to Route 53 in Account 951247597157"
  value       = tolist(aws_acm_certificate.prod_cert.domain_validation_options)[0].resource_record_name
}

output "validation_record_value" {
  description = "CNAME Value to add to Route 53 in Account 951247597157"
  value       = tolist(aws_acm_certificate.prod_cert.domain_validation_options)[0].resource_record_value
}
