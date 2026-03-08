# AWS region used for all resources.
variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
}

# Project name used in resource naming and tags.
variable "project_name" {
  description = "Used to name all resources"
  type        = string
}

# Environment name used in tags for filtering in the AWS console.
variable "environment" {
  description = "Environment name used for tagging (e.g. dev/stage/prod)"
  type        = string
  default     = "dev"
}