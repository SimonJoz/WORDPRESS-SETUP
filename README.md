<!-- BEGIN_TF_DOCS -->
# Terraform Module Documentation

This Terraform code defines a module for deploying a web server in AWS. The module provisions an EC2 instance, configures it with an AWS Systems Manager role,
and sets up a security group. The web server is built using an AWS Launch Template and is included in an AWS Auto Scaling Group.
Additionally, the code defines an AWS Systems Manager patch baseline and an associated patch group to manage patching.
The user data script installs and configures the Apache web server and MySQL, and it sets up a WordPress instance.

## User Data

The user data script installs Apache, MySQL, and WordPress on the EC2 instance.

# Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.1.9 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 4.67.0 |

# Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 4.67.0 |

# Modules

No modules.

# Resources

| Name | Type |
|------|------|
| [aws_autoscaling_group.web_server_asg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_group) | resource |
| [aws_iam_instance_profile.web_server](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_role.web_server](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.web_server](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_launch_template.web_server_lt](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/launch_template) | resource |
| [aws_security_group.web_server](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_ssm_association.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_association) | resource |
| [aws_ssm_patch_baseline.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_patch_baseline) | resource |
| [aws_ssm_patch_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_patch_group) | resource |
| [aws_ami.ubuntu22](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |
| [aws_iam_policy_document.web_server](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

# Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_ebs_volume_size"></a> [ebs\_volume\_size](#input\_ebs\_volume\_size) | Optional EBS volume size for EC2 instances | `string` | `30` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Type of environment, DEV, UAT, PROD, QA, etc | `string` | `"DEV"` | no |
| <a name="input_instance_count"></a> [instance\_count](#input\_instance\_count) | Optional number of desired instances | `number` | `1` | no |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | Optional EC2 instance type | `string` | `"t3.medium"` | no |
| <a name="input_patching_schedule_cron"></a> [patching\_schedule\_cron](#input\_patching\_schedule\_cron) | Patching cron schedule param | `string` | `"cron(0 1 ? * * *)"` | no |
| <a name="input_public_subnets_ids"></a> [public\_subnets\_ids](#input\_public\_subnets\_ids) | List of private subnets ids were the instances will be deployed | `list(string)` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC id were we'll deploy the bastion | `string` | n/a | yes |

# Outputs

| Name | Description |
|------|-------------|
| <a name="output_web_server_instance_name"></a> [web\_server\_instance\_name](#output\_web\_server\_instance\_name) | n/a |
<!-- END_TF_DOCS -->