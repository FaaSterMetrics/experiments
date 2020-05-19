variable "handler" {
  default = "index.azureHandler"
}

variable "memory_size" {
  default = 256
}

variable "timeout" {
  default = 60
}

variable "project_name" {
  type = string
}

variable "build_id" {
  type = string
}

variable "google_invoke_url" {
  type = string
}

variable "aws_invoke_url" {
  type = string
}

variable "fn_file" {
  type = string
}