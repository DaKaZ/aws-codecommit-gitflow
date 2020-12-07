resource aws_codebuild_project cicd_ci {
  name         = "${var.project_name}-ci-build"
  service_role = aws_iam_role.codebuild_role.arn
  tags         = var.tags

  artifacts {
    type = "NO_ARTIFACTS"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_MEDIUM"
    image                       = "aws/codebuild/standard:4.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = true
  }

  source {
    type      = "NO_SOURCE" # we invoke from lambda triggered by cloudwatch
    buildspec = var.ci_buildspec
  }

  logs_config {
    cloudwatch_logs {
      status     = "ENABLED"
      group_name = "/aws/codebuild/${var.project_name}"
    }
  }
}

resource aws_codebuild_project cicd_cd {
  name         = "${var.project_name}-cd-build"
  service_role = aws_iam_role.codebuild_role.arn
  tags         = var.tags

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_MEDIUM"
    image                       = "aws/codebuild/standard:4.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = true
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = var.cd_buildspec
  }

  logs_config {
    cloudwatch_logs {
      status     = "ENABLED"
      group_name = "/aws/codebuild/${var.project_name}"
    }
  }
}