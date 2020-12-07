output cicd_outputs {
  value = {
    codecommit_role_arn       = aws_iam_role.codecommit_role.arn
    codecommit_repo_name      = aws_codecommit_repository.cicd.repository_name
    codecommit_repo_arn       = aws_codecommit_repository.cicd.arn
    codebuild_project_name    = aws_codebuild_project.cicd_cd.id
    codebuild_project_arn     = aws_codebuild_project.cicd_cd.arn
    codepipeline_project_name = aws_codepipeline.cicd.id
    codepipeline_project_arn  = aws_codepipeline.cicd.arn
  }
}
