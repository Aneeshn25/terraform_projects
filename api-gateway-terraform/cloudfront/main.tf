provider "aws" {
  region = "${var.AWS_REGION}"
  version = "~> 2.4"
}

// -------- Data Remote State VPC --------- //
data "terraform_remote_state" "onica_api_gateway" {
  backend = "s3"

  config = {
    bucket   = "${var.bucket_remote_state}"
    key      = "env:/${var.workspace}/api_gateway/terraform.tfstate"
    region   = "${var.bucket_region}"
    role_arn = "${var.tf_mgmt_role_arn}"
  }
}


resource "aws_cloudfront_distribution" "api_gateway_distribution" {
  origin {
    domain_name = replace(data.terraform_remote_state.onica_api_gateway.outputs.prod_base_url, "/^https?://([^/]*).*/", "$1")
    origin_id   = "${var.api_orgin_id}"
    origin_path = "/prod"

        custom_origin_config {
            http_port              = 80
            https_port             = 443
            origin_protocol_policy = "https-only"
            origin_ssl_protocols   = ["TLSv1.2"]
        }
    }
    enabled             = true
    is_ipv6_enabled     = true
    comment             = "sample test for api"
    default_root_object = "id"
    
    default_cache_behavior {
        allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
        cached_methods   = ["GET", "HEAD"]
        target_origin_id = "${var.api_orgin_id}"

        forwarded_values {
            query_string = false

            cookies {
                forward = "none"
            }
        }
        viewer_protocol_policy = "allow-all"
        min_ttl                = 0
        default_ttl            = 3600
        max_ttl                = 86400
    }
    
    ordered_cache_behavior {
        path_pattern     = "/*"
        allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
        cached_methods   = ["GET", "HEAD"]
        target_origin_id = "${var.api_orgin_id}"


        forwarded_values {
            query_string = true
            cookies {
                forward = "all"
            }
        }

        min_ttl                = 0
        default_ttl            = 86400
        max_ttl                = 31536000
        compress               = true
        viewer_protocol_policy = "redirect-to-https"
    }

  restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations        = ["US", "CA", "GB", "DE"]
    }
  }


  tags = {
    Environment = "production"
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}