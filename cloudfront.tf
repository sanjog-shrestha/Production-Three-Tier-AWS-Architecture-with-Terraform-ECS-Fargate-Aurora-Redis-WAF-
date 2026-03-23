# ------------------------------------------------------------------------------
# cloudfront.tf — CloudFront distribution providing free trusted HTTPS.
# No custom domain, no ACM certificate request, no DNS validation required.
# CloudFront uses its own AWS-managed certificate on *.cloudfront.net.
# ------------------------------------------------------------------------------
resource "aws_cloudfront_distribution" "app" {
  enabled             = true
  comment             = "${var.project_name}-${var.environment} three-tier distribution"
  default_root_object = ""

  # Origin — the ALB receives HTTP from CloudFront on port 80.
  # WAFv2 is already attached to the ALB so all CloudFront origin
  # requests still pass through the WAF rule groups.
  origin {
    domain_name = aws_lb.main.dns_name
    origin_id   = "${var.project_name}-alb-origin"

    # Default cache behaviour — pass all requests through to the ALB unchanged.
    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  # Allow all HTTP methods for a full application stack
  # with POST/PUT/DELETE operations to the backend.
  default_cache_behavior {
    target_origin_id       = "${var.project_name}-alb-origin"
    viewer_protocol_policy = "redirect-to-https"

    allowed_methods = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods  = ["GET", "HEAD"]

    # Disable caching — forward all requests to the ALB in real time.
    forwarded_values {
      query_string = true
      headers      = ["*"]

      cookies {
        forward = "all"
      }
    }

    # TTL = 0 disables caching — every request hits the ALB and ECS tasks.
    min_ttl     = 0
    default_ttl = 0
    max_ttl     = 0
    compress    = true
  }


  # No geographic restrictions — serve all regions.s
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  depends_on = [aws_lb_listener.http]

  tags = {
    Name        = "${var.project_name}-cloudfront"
    Environment = var.environment
  }
}