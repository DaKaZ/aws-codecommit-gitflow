locals {
  partition = var.govcloud ? "aws-us-gov" : "aws"
}

data aws_region current {}

data aws_iam_policy_document codecommit_role {
  version = "2012-10-17"
  statement {
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    actions = [
      "sts:AssumeRole"
    ]
    condition {
      test     = "StringLike"
      variable = "aws:PrincipalArn"
      values = [
        "arn:${local.partition}:iam::*:role/CodeBuildRole",
        "arn:${local.partition}:iam::*:role/CodePipelineRole",
        # TODO: Replace the below with an SSO role
        "arn:${local.partition}:iam::*:role/*"
      ]
    }
    # condition {
    #   test = "StringEquals"
    #   # TODO: Possibly change this out for aws:PrincipalAccount if we want to limit it to a certain account
    #   variable = "aws:PrincipalOrgID"
    #   values   = [data.aws_organizations_organization.principal_organization.id]
    # }
  }
}

data aws_iam_policy_document codecommit_policy {
  version = "2012-10-17"

  statement {
    sid    = "CodeCommitPolicy"
    effect = "Allow"
    actions = [
      "codecommit:BatchGet*",
      "codecommit:Create*",
      "codecommit:DeleteBranch",
      "codecommit:Get*",
      "codecommit:List*",
      "codecommit:Describe*",
      "codecommit:Put*",
      "codecommit:Post*",
      "codecommit:Merge*",
      "codecommit:Test*",
      "codecommit:Update*",
      "codecommit:GitPull",
      "codecommit:GitPush",
      "codecommit:UploadArchive",
      "codecommit:GetUploadArchiveStatus",
      "codecommit:CancelUploadArchive"
    ]
    resources = [aws_codecommit_repository.cicd.arn]
  }

  statement {
    sid    = "S3Policy"
    effect = "Allow"
    actions = [
      "s3:Get*",
      "s3:Put*",
      "s3:List*"
    ]
    resources = [
      "*"
    ]
  }

  statement {
    sid    = "KMSPolicy"
    effect = "Allow"
    actions = [
      "kms:DescribeKey",
      "kms:GenerateDataKey*",
      "kms:Encrypt",
      "kms:ReEncrypt*",
      "kms:Decrypt"
    ]

    resources = [
      "*"
    ]
  }
}
