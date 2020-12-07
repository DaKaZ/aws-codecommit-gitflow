variable project_name {
  type        = string
  description = "The name of the CICD project"
}

variable kms_key_arn {
  type        = string
  description = "KMS key for the cicd pipeline"
}

variable artifacts_bucket {
  type        = string
  description = "name of the S3 bucket to use for build artifacts"
}

variable ci_buildspec {
  type        = string
  description = "rendered buildspec template for the Continuous Inteegration (PR Create) step"
}

variable cd_buildspec {
  type        = string
  description = "rendered buildspec template for the Continuous Deployment (Merge) step"
}

variable govcloud {
  type    = bool
  default = false
}

variable tags {
  type        = map(string)
  description = "resource tags"
  default     = {}
}
