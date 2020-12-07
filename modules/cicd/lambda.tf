data archive_file pr_create_lambda_zip {
    type          = "zip"
    source_file   = "${path.module}/src/pr-create.js"
    output_path   = "${path.module}/pr-create-function.zip"
}

data archive_file ci_complete_lambda_zip {
    type          = "zip"
    source_file   = "${path.module}/src/ci-complete.js"
    output_path   = "${path.module}/ci-complete-function.zip"
}

resource aws_lambda_function pr_create {
  filename         = "${path.module}/pr-create-function.zip"
  function_name    = "${var.project_name}-pr-create-function"
  role             = aws_iam_role.lambda_role.arn
  handler          = "pr-create.handler"
  source_code_hash = data.archive_file.pr_create_lambda_zip.output_base64sha256
  runtime          = "nodejs12.x"

  environment {
    variables = {
      CODEBUILD_CI_PROJECT_NAME = "${aws_codebuild_project.cicd_ci.name}"
      CODECOMMIT_REPO = "${aws_codecommit_repository.cicd.clone_url_http}"
    }
  }
}

resource aws_lambda_function ci_complete {
  filename         = "${path.module}/ci-complete-function.zip"
  function_name    = "${var.project_name}-ci-complete-function"
  role             = aws_iam_role.lambda_role.arn
  handler          = "ci-complete.handler"
  source_code_hash = data.archive_file.ci_complete_lambda_zip.output_base64sha256
  runtime          = "nodejs12.x"

  environment {
    variables = {
      CODEBUILD_CI_PROJECT_NAME = "${aws_codebuild_project.cicd_ci.name}"
      CODECOMMIT_REPO = "${aws_codecommit_repository.cicd.clone_url_http}"
    }
  }
}

resource aws_iam_role lambda_role {
  name = "${var.project_name}-lambda-assume-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

data aws_iam_policy_document lambda_policy {
  version = "2012-10-17"
  statement {
    sid    = "LambdaCodeBuildRole"
    effect = "Allow"
    actions = [
      "logs:*",
      "codecommit:*",
      "codebuild:*",
      "codepipeline:*",
    ]
    resources = [
      "*"
    ]
  }
}

resource aws_iam_role_policy lambda_codebuild_policy {
  role   = aws_iam_role.lambda_role.id
  policy = data.aws_iam_policy_document.lambda_policy.json
}