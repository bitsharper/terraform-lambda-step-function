locals {
  tags = {
    owner = "pasha.demichev@gmail.com"
  }

  aws_account_id      = data.aws_caller_identity.current.account_id
  permissions_boundry = join("", ["arn:aws:iam::", local.aws_account_id, ":policy/WorkloadPermissionsBoundry"])
}