variable "bucket_origin" {
    description = "The domain of the static website which will be accessing this API. Typically of the form http://bucket-name.s3-website[-/.]Region.amazonaws.com. May also be set to '*' (NOT SECURE)"
    type = string
}

variable "initializeTask_lambda_name" {
    description = "The name of the Lambda function containing the TTS_initializeTask.py code"
    type = string
}

variable "initializeTask_lambda_qualifier" {
    description = "The Alias name or version number of the initializeTask Lambda function. E.g., $LATEST, my-alias, or 1"
    type = string
    default = "$LATEST"
}

variable "retrieveTask_lambda_name" {
    description = "The name of the Lambda function containing the TTS_retrieveTask.py code"
    type = string
}

variable "retrieveTask_lambda_qualifier" {
    description = "The Alias name or version number of the retrieveTask Lambda function. E.g., $LATEST, my-alias, or 1"
    type = string
    default = "$LATEST"
}

variable "default_api_burst_limit" {
    description = "The default route throttling burst limit. The default it low too avoid calling this API too often and racking up charges."
    type = number
    default = 5
}
variable "default_api_rate_limit" {
    description = "The default route throttling burst limit. The default it low too avoid calling this API too often and racking up charges."
    type = number
    default = 5
}