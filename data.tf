data "archive_file" "zip" {
  type        = "zip"
  source_dir  = "${path.module}/tmp/package-dependencies"
  output_path = "${path.module}/tmp/ami_cleaner.zip"

  depends_on = [
    null_resource.install_python_dependencies
  ]

}
data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "assume_role_policy_document" {
  statement {
    sid    = "LambdaAssumeRolePolicy"
    effect = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "ami_cleaner_lambda_policy_document" {
  statement {
    sid = "CWLogsLoggingAccess"
    actions = [
      "logs:PutLogEvents",
      "logs:CreateLogStream"
    ]
    resources = [
      "${aws_cloudwatch_log_group.ami_cleaner_labmda_loggroup.arn}:*"
    ]
  }

  statement {
    sid = "ValidateEC2Access"
    actions = [
      "ec2:DescribeImages",
      "ec2:DeleteSnapshot",
      "ec2:DeregisterImage"
    ]
    resources = ["arn:aws:ec2:${var.region}:${local.aws_account_id}:*"]
  }
}