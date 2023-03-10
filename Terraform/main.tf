terraform {
  required_providers {
    aws = {
        source = "hashicorp/aws"
        version = "~> 4.58.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

data "aws_lambda_function" "initializeTask_lambda" {
  function_name = var.initializeTask_lambda_name
  qualifier = var.initializeTask_lambda_qualifier
} 

data "aws_lambda_function" "retrieveTask_lambda" {
  function_name = var.retrieveTask_lambda_name
  qualifier = var.retrieveTask_lambda_qualifier
} 

resource "aws_apigatewayv2_api" "api" {
  name = "TTS-API"
  protocol_type = "HTTP"
  cors_configuration {
    allow_headers = ["x-tts-taskid"]
    allow_methods = ["OPTIONS", "PUT", "POST", "GET"]
    allow_origins = [var.bucket_origin]
  }
  description = "Web API for interfacing with the TTS Lambda functions."
}

resource "aws_apigatewayv2_integration" "initializeTask_integration" {
  api_id = aws_apigatewayv2_api.api.id

  integration_type = "AWS_PROXY"
  integration_method = "ANY"
  integration_uri = data.aws_lambda_function.initializeTask_lambda.invoke_arn

  payload_format_version = "2.0"
  timeout_milliseconds = 30000

  description = "Integration between this API and TTS_initializeTask.py Lambda function"
}

resource "aws_apigatewayv2_integration" "retrieveTask_integration" {
  api_id = aws_apigatewayv2_api.api.id

  integration_type = "AWS_PROXY"
  integration_method = "ANY"
  integration_uri = data.aws_lambda_function.retrieveTask_lambda.invoke_arn

  payload_format_version = "2.0"
  timeout_milliseconds = 30000

  description = "Integration between this API and TTS_retrieveTask.py Lambda function"
}

resource "aws_apigatewayv2_route" "initializeTask_route" {
  api_id = aws_apigatewayv2_api.api.id
  route_key = "POST /initializeTask"
  target = "integrations/${aws_apigatewayv2_integration.initializeTask_integration.id}"
}

resource "aws_apigatewayv2_route" "retrieveTask_route" {
  api_id = aws_apigatewayv2_api.api.id
  route_key = "POST /retrieveTask"
  target = "integrations/${aws_apigatewayv2_integration.retrieveTask_integration.id}"
}

resource "aws_apigatewayv2_stage" "default" {
  api_id = aws_apigatewayv2_api.api.id
  name = "$default"
  auto_deploy = true

  default_route_settings {
    throttling_burst_limit = var.default_api_burst_limit
    throttling_rate_limit = var.default_api_rate_limit
  }
}