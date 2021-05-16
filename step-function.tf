data "aws_iam_policy_document" "sfn_assume_role_policy_document" {
    statement {
      sid = "StepFunctionAssumeRolePolicy"
      effect = "Allow"

      actions = [
          "sts:AssumeRole"
      ]
      principals {
          type = "Service"
          identifiers = [
              "states.${var.region}.amazonaws.com",
              "events.amazonaws.com"
          ]
      }
    }
}

data "aws_iam_policy_document" "deregister_state_machine_policy_document" {
    statement {
      sid = "InvokeLambdaAccess"
      actions = [
          "lambda:InvokeFunction",
      ]

      resources = [
          aws_lambda_function.ami_cleaner_lambda.arn,
      ]
    }
}

data "template_file" "step_function_defenition_template" {
    template = file("${path.module}/step-functions/ami-cleaner-step-function.json.tmpl")
    vars = {
        ami-cleaner-lambda-arn = aws_lambda_function.ami_cleaner_lambda.arn
    }
}

resource "aws_iam_role" "deregister_state_machine_role" {
    name = "deregister"
    assume_role_policy = data.aws_iam_policy_document.sfn_assume_role_policy_document.json
    #permissions_boundary
}

resource "aws_iam_policy" "deregister_state_machine_policy" {
    description = "IAM policy for the AMI deregistring step function"
    name = "deregister"
    policy = data.aws_iam_policy_document.deregister_state_machine_policy_document.json
}
resource "aws_iam_role_policy_attachment" "deregister_assume_role_policy_attachment" {
  role       = aws_iam_role.deregister_state_machine_role.name
  policy_arn = aws_iam_policy.deregister_state_machine_policy.arn
}

resource "aws_sfn_state_machine" "deregister_state_machine" {
    name = "deregister"
    role_arn = aws_iam_role.deregister_state_machine_role.arn

    definition = data.template_file.step_function_defenition_template.rendered
    tags = local.tags
}