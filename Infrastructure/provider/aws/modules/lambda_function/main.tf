locals {
  tracing_mode     = var.enable_tracing ? "Active" : "PassThrough"
}

resource aws_lambda_function function {
  function_name     = var.function_name
  role              = var.role_arn
  s3_bucket         = var.s3_bucket
  s3_key            = var.s3_key
  s3_object_version = var.s3_object_version == "" ? null : var.s3_object_version
  runtime           = var.runtime
  handler           = var.handler
  layers            = var.layers
  memory_size       = var.memory_size
  timeout           = var.timeout
  tags              = var.tags

  # TODO: figure out a sane method of generating source_code_hash

  tracing_config {
    mode = local.tracing_mode
  }

  environment {
    variables = var.environment_variables
  }
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
