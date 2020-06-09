resource aws_iam_role terraform_pipeline {
  tags                 = var.tags
  name                 = "${local.resource_prefix}-pipeline"
  permissions_boundary = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/PCSKPermissionsBoundary"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "sts:AssumeRole"
        Principal = {
          Service = [
            "codebuild.amazonaws.com",
            "codepipeline.amazonaws.com"
          ]
        }
      }
    ]
  })

}

data aws_iam_policy_document terraform_pipeline {
  # CodePipeline and CodeBuild use CloudWatch logs for managing their console output.
  # This statement gives them them appropriate access according to the docs.
  statement {
    sid    = "AllowLogging"
    effect = "Allow"

    resources = ["*"]

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
  }

  statement {
    sid    = "AllowAccessToDynamoDBStateLockTable"
    effect = "Allow"

    resources = [
      data.aws_dynamodb_table.tf_state_lock.arn
    ]

    actions = ["dynamodb:*"]
  }

  statement {
    sid    = "AllowAccessToTheKMSKey"
    effect = "Allow"

    resources = [
      module.pipeline_bucket.bucket_key.arn
    ]

    actions = [
      "kms:DescribeKey",
      "kms:ListKeyPolicies",
      "kms:GetKeyPolicy",
      "kms:GetKeyRotationStatus",
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:GenerateDataKey*",
      "kms:ReEncrypt*",
    ]
  }

  statement {
    sid = "AllowAccessToApplicationArtifactsInS3"

    resources = [
      "${data.terraform_remote_state.region_base.outputs.artifact_bucket.bucket.arn}/*"
    ]

    actions = [
      "s3:DeleteObject",
      "s3:GetObject*",
      "s3:PutObject*",
    ]
  }

  statement {
    sid = "AllowAccessToApplicationArtifactBucketInS3"

    resources = [
      data.terraform_remote_state.region_base.outputs.artifact_bucket.bucket.arn
    ]

    actions = [
      "s3:GetBucketVersioning",
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:ListBucket",
    ]
  }

  statement {
    sid = "AllowAccessToPipelineArtifactsInS3"

    resources = [
      "${module.pipeline_bucket.bucket.arn}/*"
    ]

    actions = [
      "s3:DeleteObject",
      "s3:GetObject*",
      "s3:PutObject*",
    ]
  }

  statement {
    sid = "AllowAccessToPipelineArtifactBucketInS3"

    resources = [
      module.pipeline_bucket.bucket.arn
    ]

    actions = [
      "s3:GetBucketVersioning",
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:ListBucket",
    ]
  }

  statement {
    sid    = "AllowCodePipelineToManageResourcesItCreates"
    effect = "Allow"

    resources = [
      "arn:aws:s3:::codepipeline*",
      "arn:aws:s3:::elasticbeanstalk*",
    ]

    actions = [
      "s3:PutObject",
    ]
  }

  statement {
    sid    = "AllowCodePipelineToInvokeLambdaFunctions"
    effect = "Allow"

    resources = [
      "*",
    ]

    actions = [
      "lambda:invokefunction",
      "lambda:listfunctions",
    ]
  }

  statement {
    sid    = "AllowCodePipelineToManageCodeBuildJobs"
    effect = "Allow"

    resources = [
      "*",
    ]

    actions = [
      "codebuild:StartBuild",
      "codebuild:StopBuild",
      "codebuild:BatchGetBuilds",
      "codebuild:BatchGetProjects",
      "codebuild:ListBuilds",
      "codebuild:ListBuildsForProject",
      "codebuild:ListProjects",
    ]
  }

  statement {
    sid = "AllowCodeBuildToReadGitTokenSecret"

    resources = [
      data.aws_secretsmanager_secret_version.github_oauth_token.arn
    ]

    actions = [
      "secretsmanager:GetResourcePolicy",
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret",
      "secretsmanager:ListSecretVersionIds"
    ]
  }

  statement {
    sid = "AllowCodeBuildAccessToStateBucketObjects"

    resources = [
      "${data.aws_s3_bucket.state_bucket.arn}/*"
    ]

    actions = [
      "s3:DeleteObject",
      "s3:GetObject*",
      "s3:PutObject*",
    ]
  }

  statement {
    sid = "AllowCodeBuildAccessToStateBucket"

    resources = [
      data.aws_s3_bucket.state_bucket.arn
    ]

    actions = [
      "s3:GetBucketVersioning",
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:ListBucket",
    ]
  }

  statement {
    sid = "AllowCodeBuildToRunTerraformPlanAndApply"

    resources = [
      "*"
    ]

    actions = [
      "iam:*",
      "secretsmanager:*",
      "ec2:*",
      "elasticloadbalancing:*",
      "route53:*",
      "sns:*",
      "dynamodb:*",
      "eks:*",
      "ssm:*",
      "logs:*",
      "execute-api:*",
      "lambda:*",
      "apigateway:*",
      "events:*",
      "autoscaling:*"
    ]
  }
}

resource aws_iam_policy terraform_pipeline {
  name   = "${local.resource_prefix}-pipeline"
  policy = data.aws_iam_policy_document.terraform_pipeline.json
}

resource aws_iam_role_policy_attachment terraform_pipeline {
  role       = aws_iam_role.terraform_pipeline.id
  policy_arn = aws_iam_policy.terraform_pipeline.arn
}