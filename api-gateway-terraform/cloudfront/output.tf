output "cloudfront_id" {
  value       = "${aws_cloudfront_distribution.api_gateway_distribution.id}"
  description = "ID of AWS CloudFront distribution"
}

output "cloudfront_arn" {
  value       = "${aws_cloudfront_distribution.api_gateway_distribution.arn}"
  description = "ID of AWS CloudFront distribution"
}

output "cloudfront_domain_name" {
  value       = "${aws_cloudfront_distribution.api_gateway_distribution.domain_name}"
  description = "Domain name corresponding to the distribution"
}