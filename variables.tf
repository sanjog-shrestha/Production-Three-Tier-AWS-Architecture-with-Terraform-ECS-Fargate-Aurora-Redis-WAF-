# ------------------------------------------------------------------------------
# variables.tf — Input variables for region, project name, environment, and DB credentials.
# ------------------------------------------------------------------------------

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

# Aurora master username; stored in Secrets Manager after first apply (sensitive).
variable "db_username" {
  description = "Aurora master username — stored in Secrets Manager after first apply"
  type        = string
  sensitive   = true
}

# Aurora master password; stored in Secrets Manager after first apply (sensitive).
variable "db_password" {
  description = "Aurora master password — stored in Secrets Manager after first apply"
  type        = string
  sensitive   = true
}