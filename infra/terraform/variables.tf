variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "sa-east-1"
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "kombot"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "prod"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "ssh_cidr" {
  description = "CIDR allowed for SSH access"
  type        = string
}

variable "streamlit_cidr" {
  description = "CIDR allowed for Streamlit access"
  type        = string
  default     = "189.120.79.18/32"
}

variable "key_name" {
  description = "EC2 key pair name"
  type        = string
}

variable "gemini_api_key" {
  description = "Gemini API key to store in SSM"
  type        = string
  sensitive   = true
}

variable "log_level" {
  description = "Application log level"
  type        = string
  default     = "INFO"
}

variable "app_env" {
  description = "Application environment value stored in SSM"
  type        = string
  default     = "prod"
}