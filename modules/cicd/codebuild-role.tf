resource aws_iam_role codebuild_role {
  name               = "${var.project_name}-cicd-codebuild-role"
  assume_role_policy = data.aws_iam_policy_document.codebuild_role.json
}

data aws_iam_policy_document codebuild_role {
  version = "2012-10-17"
  statement {
    sid    = "CodeBuildAssumeRole"
    effect = "Allow"
    principals {
      type = "Service"
      identifiers = [
        "codebuild.amazonaws.com"
      ]
    }
    actions = [
      "sts:AssumeRole"
    ]
  }
}

data aws_iam_policy_document codebuild_policy {
  version = "2012-10-17"
  statement {
    sid    = "CodeBuildRole"
    effect = "Allow"
    actions = [
      "logs:*",
      "s3:*",
      "codecommit:*",
      "codebuild:*",
      "codepipeline:*",
      "sts:*",
      "kms:*",
      "ecr:*",
      "ec2:*",
      "ecs:*",
      "cognito-idp:*",
      "dynamodb:*",
      "iam:*",
      "sns:*",
      "elasticloadbalancing:*",
      "ssm:*",
      "organizations:*"
    ]
    resources = [
      "*"
    ]
  }
}

resource aws_iam_role_policy codebuild_policy {
  role   = aws_iam_role.codebuild_role.id
  policy = data.aws_iam_policy_document.codebuild_policy.json
}