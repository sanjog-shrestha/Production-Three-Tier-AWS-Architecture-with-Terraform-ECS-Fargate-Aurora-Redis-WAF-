# ------------------------------------------------------------------------------
# providers.tf — Terraform and AWS provider configuration and default tags.
# ------------------------------------------------------------------------------

terraform {
  # Terraform CLI + provider constraints for reproducible deployments.
  required_version = ">=1.14.0"

  required_providers {
    aws = {
      # AWS provider used to create all infrastructure resources.
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    # null provider for null_resource if needed by other modules
    null = {
      source  = "hashicorp/null"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  # Primary AWS provider configuration for this project.
  region = var.aws_region

  # Apply consistent tags to all taggable AWS resources for easy filtering in AWS Console.
  default_tags {
    tags = {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  }
}