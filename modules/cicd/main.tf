resource aws_codecommit_repository cicd {
  repository_name = "${var.project_name}-code"
  tags            = var.tags
}

resource aws_iam_role codecommit_role {
  name               = "${var.project_name}-codecommit-role"
  assume_role_policy = data.aws_iam_policy_document.codecommit_role.json
  tags               = var.tags
}

resource aws_iam_role_policy codecommit_policy {
  role   = aws_iam_role.codecommit_role.id
  policy = data.aws_iam_policy_document.codecommit_policy.json
}
