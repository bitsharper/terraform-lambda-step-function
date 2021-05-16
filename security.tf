resource "aws_cloudwatch_log_group" "ami_cleaner_labmda_loggroup" {
  name              = "/aws/lambda/ami_cleaner"
  retention_in_days = 7
  tags              = local.tags
}

resource "aws_iam_role" "ami_cleaner_lambda_role" {
  name                 = "ami_cleaner_lambda_role"
  #permissions_boundary = "arn:aws:iam::${local.aws_account_id}:policy/WorkloadPermissionsBoundary"
  assume_role_policy   = data.aws_iam_policy_document.assume_role_policy_document.json
}

resource "aws_iam_policy" "ami_cleaner_lambda_policy" {
  description = "IAM policy for ami deregistration lambda function"
  name        = "ami_cleaner_lambda_policy"
  policy      = data.aws_iam_policy_document.ami_cleaner_lambda_policy_document.json
}

resource "aws_iam_role_policy_attachment" "ami_cleaner_lambda_policy_attachment" {
  role       = aws_iam_role.ami_cleaner_lambda_role.name
  policy_arn = aws_iam_policy.ami_cleaner_lambda_policy.arn
}