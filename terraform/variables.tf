variable "environment" {
  type        = string
  default     = "DEV"
  description = "Type of environment, DEV, UAT, PROD, QA, etc "
}

variable "vpc_id" {
  type        = string
  description = "VPC id were we'll deploy the bastion"
}

variable "public_subnets_ids" {
  type        = list(string)
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
  description = "Patching cron schedule param"

  validation {
    condition     = can(regex("cron(.+)", var.patching_schedule_cron))
    error_message = "Invalid schedule cron! Must be of format eg. cron(0 16 ? * TUE *)."
  }
}

