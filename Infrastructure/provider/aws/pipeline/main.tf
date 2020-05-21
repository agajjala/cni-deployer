variable region {}
variable env_name {}
variable deployment_id {}
variable tags {
  type = map(string)
}

terraform {
  backend s3 {}
}

provider aws {
  region = var.region
}

provider github {
  token        = local.git_token
  organization = local.repo_org
}

locals {
  resource_prefix     = join("-", [var.env_name, var.region, var.deployment_id])
  manifest_filename   = "${local.resource_prefix}.yaml"
  webhook_action_name = "CheckoutManifestSource"
  repo_org            = "sf-sdn"
  repo_name           = "cni-manifests"
  branch_name         = "master"
  plan_timeout        = "5"
  apply_timeout       = "60"
  git_token_secret_id = "SF-SDN-GIT-TOKEN"
  git_token           = jsondecode(data.aws_secretsmanager_secret_version.github_oauth_token.secret_string)["GIT_PASSWORD"]
  unary_module_names  = ["stack_base", "control_plane", "monitoring", "inbound_data_plane"]
  tf_codebuild_environment_variables = [
    {
      name  = "ENV_NAME"
      type  = "PLAINTEXT"
      value = var.env_name
    },
    {
      name  = "MANIFEST_FILENAME"
      type  = "PLAINTEXT"
      value = local.manifest_filename
    }
  ]
}

###############################
#  Webhook Secret
###############################

resource aws_secretsmanager_secret webhook {
  tags                    = var.tags
  name_prefix             = "${local.resource_prefix}-webhook"
  recovery_window_in_days = 0
}

resource aws_secretsmanager_secret_version webhook {
  secret_id     = aws_secretsmanager_secret.webhook.arn
  secret_string = random_password.password.result
}

resource random_password password {
  length  = 32
  special = true
}

###############################
#  GitHub Webhook
###############################

resource github_repository_webhook github_manifest {
  repository = data.github_repository.manifest.name

  configuration {
    url          = aws_codepipeline_webhook.github_manifest.url
    content_type = "json"
    //    insecure_ssl = true
    secret = random_password.password.result
  }

  events = ["push"]
}

###############################
#  CodePipeline Webhook
###############################

resource aws_codepipeline_webhook github_manifest {
  name            = "${local.resource_prefix}-github-manifest"
  authentication  = "GITHUB_HMAC"
  target_pipeline = aws_codepipeline.stack.name
  target_action   = local.webhook_action_name

  authentication_configuration {
    secret_token = random_password.password.result
  }

  filter {
    json_path    = "$.head_commit.modified"
    match_equals = "/aws/${var.env_name}/${local.resource_prefix}.yaml"
  }

  filter {
    json_path    = "$.ref"
    match_equals = "refs/heads/master"
  }
}

###############################
#  CodePipeline Bucket
###############################

module pipeline_bucket {
  source            = "../modules/s3_bucket"
  tags              = var.tags
  bucket_name       = "${local.resource_prefix}-pipeline"
  region            = var.region
  admin_principals  = data.terraform_remote_state.region_base.outputs.admin_principals
  enable_mfa_delete = false
}

###############################
#  CodeBuild for TF Plan
###############################

resource aws_codebuild_project terraform_plan {
  tags           = var.tags
  name           = "${local.resource_prefix}-tf-plan"
  service_role   = aws_iam_role.terraform_pipeline.arn
  encryption_key = module.pipeline_bucket.bucket_key.arn
  build_timeout  = local.plan_timeout
  queued_timeout = local.plan_timeout

  artifacts {
    type = "CODEPIPELINE"
  }

  cache {
    type     = "S3"
    location = "${module.pipeline_bucket.bucket.bucket}/codebuild/cache/tf-plan"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:2.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
  }

  source {
    type = "CODEPIPELINE"
    buildspec = templatefile("${path.module}/buildspecs/tf_plan.yaml", {
      env_name        = var.env_name
      resource_prefix = local.resource_prefix
    })
  }
}

###############################
#  CodeBuild for TF Apply
###############################

resource aws_codebuild_project terraform_apply {
  tags           = var.tags
  name           = "${local.resource_prefix}-tf-apply"
  service_role   = aws_iam_role.terraform_pipeline.arn
  encryption_key = module.pipeline_bucket.bucket_key.arn
  build_timeout  = local.apply_timeout
  queued_timeout = local.apply_timeout

  artifacts {
    type = "CODEPIPELINE"
  }

  cache {
    type     = "S3"
    location = "${module.pipeline_bucket.bucket.bucket}/codebuild/cache/tf-apply"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:2.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
  }

  source {
    type = "CODEPIPELINE"
    buildspec = templatefile("${path.module}/buildspecs/tf_apply.yaml", {
      env_name        = var.env_name
      resource_prefix = local.resource_prefix
    })
  }
}

###################################
#  CodeBuild for EKS Dataplane Plan
###################################

resource aws_codebuild_project dataplane_plan {
  tags           = var.tags
  name           = "${local.resource_prefix}-dp-plan"
  service_role   = aws_iam_role.terraform_pipeline.arn
  encryption_key = module.pipeline_bucket.bucket_key.arn
  build_timeout  = local.plan_timeout
  queued_timeout = local.plan_timeout

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:2.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
  }

  source {
    type = "CODEPIPELINE"
    buildspec = templatefile("${path.module}/buildspecs/dp_plan.yaml", {
      env_name        = var.env_name
      resource_prefix = local.resource_prefix
    })
  }
}

###############################
#  CodeBuild for TF Apply
###############################

resource aws_codebuild_project dataplane_apply {
  tags           = var.tags
  name           = "${local.resource_prefix}-dp-apply"
  service_role   = aws_iam_role.terraform_pipeline.arn
  encryption_key = module.pipeline_bucket.bucket_key.arn
  build_timeout  = local.apply_timeout
  queued_timeout = local.apply_timeout

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:2.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
  }

  source {
    type = "CODEPIPELINE"
    buildspec = templatefile("${path.module}/buildspecs/dp_apply.yaml", {
      env_name        = var.env_name
      resource_prefix = local.resource_prefix
    })
  }
}

###############################
#  CodePipeline
###############################

resource aws_codepipeline stack {
  name     = local.resource_prefix
  role_arn = aws_iam_role.terraform_pipeline.arn

  artifact_store {
    location = module.pipeline_bucket.bucket.bucket
    type     = "S3"

    encryption_key {
      id   = module.pipeline_bucket.bucket_key.arn
      type = "KMS"
    }
  }

  stage {
    name = local.webhook_action_name

    action {
      name             = local.webhook_action_name
      category         = "Source"
      owner            = "ThirdParty"
      provider         = "GitHub"
      output_artifacts = ["ManifestSource"]
      version          = "1"

      configuration = {
        Owner      = local.repo_org
        Repo       = local.repo_name
        Branch     = "master"
        OAuthToken = local.git_token
      }
    }
  }

  # create a stage for each module with a single instance (i.e. not outbound_data_plane)
  dynamic "stage" {
    for_each = local.unary_module_names
    content {
      name = stage.value

      action {
        name             = "TerraformPlan"
        category         = "Build"
        owner            = "AWS"
        provider         = "CodeBuild"
        input_artifacts  = ["ManifestSource"]
        output_artifacts = ["${stage.value}_plan"]
        version          = "1"
        run_order        = "1"

        configuration = {
          ProjectName = aws_codebuild_project.terraform_plan.name
          EnvironmentVariables = jsonencode(concat(local.tf_codebuild_environment_variables, [
            {
              name  = "MODULE_NAME"
              type  = "PLAINTEXT"
              value = stage.value
            }
          ]))
        }
      }

      action {
        name      = "FirstApproval"
        category  = "Approval"
        owner     = "AWS"
        provider  = "Manual"
        version   = "1"
        run_order = "2"
      }

      action {
        name             = "TerraformApply"
        category         = "Build"
        owner            = "AWS"
        provider         = "CodeBuild"
        input_artifacts  = ["${stage.value}_plan"]
        output_artifacts = []
        version          = "1"
        run_order        = "3"

        configuration = {
          ProjectName = aws_codebuild_project.terraform_apply.name
          EnvironmentVariables = jsonencode(concat(local.tf_codebuild_environment_variables, [
            {
              name  = "MODULE_NAME"
              type  = "PLAINTEXT"
              value = stage.value
            }
          ]))
        }
      }
    }
  }

  stage {
    name = "DataplaneDeployment"

    action {
      name             = "DataplanePlan"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["ManifestSource"]
      output_artifacts = []
      version          = "1"
      run_order        = "1"

      configuration = {
        ProjectName          = aws_codebuild_project.dataplane_plan.name
        EnvironmentVariables = jsonencode(local.tf_codebuild_environment_variables)
      }
    }

    action {
      name      = "FirstApproval"
      category  = "Approval"
      owner     = "AWS"
      provider  = "Manual"
      version   = "1"
      run_order = "2"
    }

    action {
      name             = "DataplaneApply"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["ManifestSource"]
      output_artifacts = []
      version          = "1"
      run_order        = "3"

      configuration = {
        ProjectName          = aws_codebuild_project.dataplane_apply.name
        EnvironmentVariables = jsonencode(local.tf_codebuild_environment_variables)
      }
    }
  }
}
