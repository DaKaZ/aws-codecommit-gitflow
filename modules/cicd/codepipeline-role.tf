resource aws_iam_role codepipeline_role {
  name               = "${var.project_name}-cicd-codepipeline-role"
  assume_role_policy = data.aws_iam_policy_document.codepipeline_role.json
}

resource aws_iam_role_policy codepipeline_policy {
  role   = aws_iam_role.codepipeline_role.id
  policy = data.aws_iam_policy_document.codepipeline_policy.json
}

data aws_iam_policy_document codepipeline_role {
  version = "2012-10-17"

  statement {
    sid    = "CodePipelineAssumeRole"
    effect = "Allow"
    principals {
      type = "Service"
      identifiers = [
        "codepipeline.amazonaws.com"
      ]
    }
    actions = [
      "sts:AssumeRole"
    ]
  }
}

data aws_iam_policy_document codepipeline_policy {
  version = "2012-10-17"

  statement {
    sid    = "CodePipelineCodeCommitPolicy"
    effect = "Allow"
    actions = [
      "codecommit:GetBranch",
      "codecommit:GetCommit",
      "codecommit:UploadArchive",
      "codecommit:GetUploadArchiveStatus",
      "codecommit:CancelUploadArchive"
    ]
    resources = [
      "*"
    ]
  }

  statement {
    sid    = "CodePipelineCodeBuildPolicy"
    effect = "Allow"
    actions = [
      "codebuild:BatchGetBuilds",
      "codebuild:StartBuild"
    ]
    resources = [
      "*"
    ]
  }

  statement {
    sid    = "CodePipelineEcrPolicy"
    effect = "Allow"
    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:BatchGetImage",
      "ecr:CompleteLayerUpload",
      "ecr:DescribeImages",
      "ecr:DescribeRepositories",
      "ecr:GetDownloadUrlForLayer",
      "ecr:GetRepositoryPolicy",
      "ecr:InitiateLayerUpload",
      "ecr:ListImages",
      "ecr:PutImage",
      "ecr:UploadLayerPart"
    ]
    resources = [
      "*"
    ]
  }

  statement {
    sid    = "CodePipelineEcsPolicy"
    effect = "Allow"
    actions = [
      "ecs:DescribeServices",
      "ecs:DescribeTaskDefinition",
      "ecs:DescribeTasks",
      "ecs:ListTasks",
      "ecs:RegisterTaskDefinition",
      "ecs:UpdateService"
    ]
    resources = [
      "*"
    ]
  }

  statement {
    sid    = "CodePipelineS3Policy"
    effect = "Allow"
    actions = [
      "s3:GetObject*",
      "s3:PutObject",
      "s3:List*",
      "s3:PutObjectAcl"
    ]
    resources = [
      "*"
    ]
  }

  statement {
    sid    = "CodePipelineStsPolicy"
    effect = "Allow"
    actions = [
      "sts:AssumeRole",
      "sts:GetCallerIdentity"
    ]
    resources = [
      "*"
    ]
  }

  statement {
    sid    = "CodePipelineKmsPolicy"
    effect = "Allow"
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey"
    ]
    resources = [
      "*"
    ]
  }

  statement {
    sid    = "CodePipelineVpcPolicy"
    effect = "Allow"
    actions = [
      "ec2:AllocateAddress",
      "ec2:AssociateRouteTable",
      "ec2:AttachInternetGateway",
      "ec2:CreateInternetGateway",
      "ec2:CreateNatGateway",
      "ec2:CreateRoute",
      "ec2:CreateRouteTable",
      "ec2:CreateSecurityGroup",
      "ec2:CreateSubnet",
      "ec2:CreateVpc",
      "ec2:DescribeAvailabilityZones",
      "ec2:ModifyVpcAttribute"
    ]
    resources = [
      "*"
    ]
  }
}
