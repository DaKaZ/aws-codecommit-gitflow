provider "aws" {
  region = var.aws_region
}

resource aws_s3_bucket cicd_artifact_bucket {
  bucket = "${var.project_name}-cicd-artifact-bucket"
  acl    = "private"
}

resource aws_kms_key pipeline_kms_key {
  description = "${var.project_name}-cicd-pipeline-key"
}

module cicd {
  source              = "./modules/cicd"
  project_name        = var.project_name
  artifacts_bucket    = aws_s3_bucket.cicd_artifact_bucket.id
  ci_buildspec        = data.template_file.ci_buildspec.rendered
  cd_buildspec        = data.template_file.cd_buildspec.rendered
  kms_key_arn         = aws_kms_key.pipeline_kms_key.arn
}

