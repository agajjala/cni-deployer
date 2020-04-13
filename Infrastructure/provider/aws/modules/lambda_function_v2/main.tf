locals {
  tracing_mode     = var.enable_tracing ? "Active" : "PassThrough"
}

resource aws_lambda_function function {
  tags              = var.tags
  function_name     = var.function_name
  role              = var.function_role.arn
  s3_bucket         = var.artifact_bucket.bucket
  s3_key            = var.s3_key
  runtime           = var.runtime
  handler           = var.handler
  layers            = var.layers
  memory_size       = var.memory_size
  timeout           = var.timeout
  publish           = true

  tracing_config {
    mode = local.tracing_mode
  }

  # Lambda expects at least one environment variable if the environment block is expected
  dynamic environment {
    for_each = length(var.environment_variables) > 0 ? [var.environment_variables] : []
    content {
      variables = environment.value
    }
  }
}

resource aws_lambda_alias alias {
  name = format("%s-%s", var.function_name, aws_lambda_function.function.version)
  function_name = aws_lambda_function.function.function_name
  function_version = aws_lambda_function.function.version
}

resource aws_lambda_provisioned_concurrency_config config {
  function_name = aws_lambda_alias.alias.function_name
  provisioned_concurrent_executions = var.provisioned_concurrent_executions
  qualifier = aws_lambda_alias.alias.name

  # If provisioned_concurrent_executions is 0, don't create this resource
  count = var.provisioned_concurrent_executions > 0 ? var.provisioned_concurrent_executions : 0
}

###############################
#  Cloudwatch
###############################

resource aws_cloudwatch_event_rule schedule {
  name                = aws_lambda_function.function.function_name
  schedule_expression = var.schedule

  count               = var.has_schedule ? 1 : 0
}

resource aws_lambda_permission cloudwatch {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.function.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.schedule[count.index].arn

  count         = var.has_schedule ? 1 : 0
}

resource aws_cloudwatch_event_target function {
  target_id = aws_lambda_function.function.function_name
  rule      = aws_cloudwatch_event_rule.schedule[count.index].name
  arn       = aws_lambda_function.function.arn

  count     = var.has_schedule ? 1 : 0
}

###############################
#  Event Source
###############################

resource aws_lambda_event_source_mapping mapping {
  event_source_arn  = var.event_source_arn
  function_name     = aws_lambda_function.function.function_name
  starting_position = "LATEST"

  count             = var.has_event_source ? 1 : 0
}

###############################
#  SNS
###############################

resource aws_lambda_permission sns {
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.function.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = var.sns_topic_arn

  count         = var.has_sns_topic ? 1 : 0
}

resource aws_sns_topic_subscription subscription {
  topic_arn = var.sns_topic_arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.function.arn

  count     = var.has_sns_topic ? 1 : 0
}