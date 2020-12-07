##
# First we create the cloudwatch event for when PRs are updated or changed

resource aws_cloudwatch_event_rule pr_lambda {
  name        = "${var.project_name}-pr-create-lambda-event"
  description = "Invoke the PR Create lambda with a pull request event"

  event_pattern = <<EOF
{
  "source": [
    "aws.codecommit"
  ],
  "detail-type": [
    "CodeCommit Pull Request State Change"
  ],
  "resources": [
    "${aws_codecommit_repository.cicd.arn}"
  ]
}
EOF
}

resource aws_cloudwatch_event_target pr_create_lambda {
  rule      = aws_cloudwatch_event_rule.pr_lambda.name
  target_id = "SendToPrCreateLambda"
  arn       = aws_lambda_function.pr_create.arn
}


resource aws_lambda_permission allow_cloudwatch_pr_create {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.pr_create.function_name
  principal     = "events.amazonaws.com"
}

##
# Next we create a tigger for when the CI build completes

resource aws_cloudwatch_event_rule ci_complete {
  name        = "${var.project_name}-ci-complete-lambda-event"
  description = "Invoke the CI Complete lambda when the CI job is complete"

  event_pattern = <<EOF
{
  "source": [
    "aws.codebuild"
  ],
  "detail-type": [
    "CodeBuild Build State Change"
  ],
  "detail": {
    "build-status": [
      "SUCCEEDED",
      "FAILED"
    ],
    "project-name" : [
      "${aws_codebuild_project.cicd_ci.name}"
    ]
  }
}
EOF
}


resource aws_cloudwatch_event_target ci_complete_lambda {
  rule      = aws_cloudwatch_event_rule.ci_complete.name
  target_id = "SendToCiCompleteLambda"
  arn       = aws_lambda_function.ci_complete.arn
}


resource aws_lambda_permission allow_cloudwatch_ci_complete {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.ci_complete.function_name
  principal     = "events.amazonaws.com"
}