variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "stage_name" {
  description = "The name of the stage for deployment"
  type        = string
  default     = "dev"
}