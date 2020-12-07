variable "aws_region" {
  type        = string
  description = "AWS Region to deploy to"
  default     = "us-west-2"
}

variable "project_name" {
  type        = string
  description = "The name of the CICD project"
}

variable terraform_version {
  type = string
}

variable candidaws_version {
  type = string
}

variable aws_provider_version {
  type = string
  
}