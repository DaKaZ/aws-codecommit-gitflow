resource aws_codepipeline cicd {
  name     = "${var.project_name}-pipeline"
  role_arn = aws_iam_role.codepipeline_role.arn
  tags     = var.tags

  artifact_store {
    location = var.artifacts_bucket
    type     = "S3"
    encryption_key {
      type = "KMS"
      id   = var.kms_key_arn
    }
  }

  stage {
    name = "Source"
    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeCommit"
      version          = "1"
      output_artifacts = ["source_output"]
      configuration = {
        RepositoryName = aws_codecommit_repository.cicd.repository_name
        BranchName     = "master"
      }
    }
  }

  stage {
    name = "Build"
    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_output"]
      version          = "1"

      configuration = {
        ProjectName = aws_codebuild_project.cicd_cd.name
      }
    }
  }
}
