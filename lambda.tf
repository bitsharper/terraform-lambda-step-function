provider "aws" {
  profile = "default"
  region  = var.region
}

provider "archive" {}

resource "null_resource" "install_destribute_python_dependencies" {
  provisioner "local-exec" {
    #command = "set -e; mkdir -p ${path.module}/tmp/package-destribute; rm -rf ${path.module}/tmp/package-destribute/*; pip install -r ${path.module}/python/requirements.txt -t ${path.module}/tmp/package-destribute; cp -r ${path.module}/python/*.py ${path.module}/tmp/package-distribute/; chmod -R 755 ${path.module}/tmp/package-destribute"
    command = "mkdir -force ${path.module}\\tmp\\package-destribute; rm -recurse -force ${path.module}\\tmp\\package-destribute\\*; pip install -r ${path.module}/python/requirements.txt -t ${path.module}/tmp/package-destribute; cp ${path.module}\\python\\*.py -Destination ${path.module}\\tmp\\package-destribute\\ -Recurse"
    interpreter = ["powershell"]
  }
  triggers = {
    always_run = "${timestamp()}"
  }
}

resource "aws_lambda_function" "ami_cleaner_lambda" {
  runtime          = "python3.7"
  function_name    = "ami_cleaner"
  description      = "Lambda function for cleanering AMI and deleting snapshots"
  timeout          = 5
  handler          = "ami_cleaner.lambda_handler"
  filename         = data.archive_file.zip.output_path
  source_code_hash = data.archive_file.zip.output_base64sha256
  role             = aws_iam_role.ami_cleaner_lambda_role.arn

  tags = {
    Name = "ami cleaner"
  }
}