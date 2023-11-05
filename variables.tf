variable "environment" {
  type        = string
  default     = "DEV"
  description = "Type of environment, DEV, UAT, PROD, QA, etc "
}

variable "vpc_id" {
  type        = string
  default     = "vpc-0bd4d067366d5ed94"
  description = "VPC id were we'll deploy the bastion"
}

variable "public_subnets_ids" {
  type        = list(string)
  default     = ["subnet-08ab210c09c7de10f", "subnet-070d57305cda0c966", "subnet-0ef8f6ea48ec6a445"]
  description = "List of private subnets ids were the instances will be deployed"
}

variable "instance_count" {
  type        = number
  default     = 1
  description = "Optional number of desired instances"
}

variable "instance_type" {
  type        = string
  default     = "t3.medium"
  description = "Optional EC2 instance type"
}

variable "ebs_volume_size" {
  type        = string
  default     = 30
  description = "Optional EBS volume size for EC2 instances"
}

variable "patching_schedule_cron" {
  type    = string
  default = "cron(0 1 ? * * *)"

  validation {
    condition     = can(regex("cron(.+)", var.patching_schedule_cron))
    error_message = "Invalid schedule cron! Must be of format eg. cron(0 16 ? * TUE *)."
  }
}

