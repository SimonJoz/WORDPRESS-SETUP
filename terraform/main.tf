/**
 * # Terraform Module Documentation
 *
 * This Terraform code defines a module for deploying a web server in AWS. The module provisions an EC2 instance, configures it with an AWS Systems Manager role,
 * and sets up a security group. The web server is built using an AWS Launch Template and is included in an AWS Auto Scaling Group.
 * Additionally, the code defines an AWS Systems Manager patch baseline and an associated patch group to manage patching.
 * The user data script installs and configures the Apache web server and MySQL, and it sets up a WordPress instance.
 *
 * ## User Data
 *
 * The user data script installs Apache, MySQL, and WordPress on the EC2 instance.
 *
 */


locals {
  web_server_instance_name = "WEB-SERVER"
  web_server_patch_group   = "WEB-SERVER-PATCH-GROUP"

  default_tags = {
    "environment" = var.environment
    "iac"         = "TRUE"
  }
}

data "aws_ami" "ubuntu22" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

data "aws_iam_policy_document" "web_server" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_instance_profile" "web_server" {
  role = aws_iam_role.web_server.name
}

resource "aws_iam_role" "web_server" {
  name               = "SSMManagedWebServerRole"
  assume_role_policy = data.aws_iam_policy_document.web_server.json
}

resource "aws_iam_role_policy_attachment" "web_server" {
  role       = aws_iam_role.web_server.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}


resource "aws_security_group" "web_server" {
  name        = "${local.web_server_instance_name}-SG"
  description = "Default security group"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = merge(local.default_tags, { "Name" = "${local.web_server_instance_name}-SG" })
}

resource "aws_launch_template" "web_server_lt" {
  name_prefix                          = "${local.web_server_instance_name}-Launch-Template-"
  image_id                             = data.aws_ami.ubuntu22.id
  instance_type                        = var.instance_type
  instance_initiated_shutdown_behavior = "terminate"

  monitoring {
    enabled = true
  }

  block_device_mappings {
    device_name = tolist(data.aws_ami.ubuntu22.block_device_mappings)[0].device_name

    ebs {
      volume_size = var.ebs_volume_size
    }
  }

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.web_server.id]
  }

  iam_instance_profile {
    name = aws_iam_instance_profile.web_server.name
  }

  tag_specifications {
    resource_type = "instance"
    tags          = merge(local.default_tags, {
      "Name"       = local.web_server_instance_name,
      "PatchGroup" = local.web_server_patch_group
    })
  }

  tags = local.default_tags

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "web_server_asg" {
  name_prefix               = "${local.web_server_instance_name}-ASG-"
  min_size                  = var.instance_count
  max_size                  = var.instance_count
  desired_capacity          = var.instance_count
  vpc_zone_identifier       = var.public_subnets_ids
  default_cooldown          = 180
  health_check_grace_period = 180
  health_check_type         = "EC2"
  termination_policies      = ["OldestLaunchTemplate"]

  launch_template {
    id      = aws_launch_template.web_server_lt.id
    version = "$Latest"
  }

  dynamic "tag" {
    for_each = local.default_tags

    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_ssm_patch_baseline" "this" {
  operating_system                     = "UBUNTU"
  name                                 = "${local.web_server_patch_group}-Baseline"
  description                          = "Patch baseline for Ubuntu private Bastion-Host instances"
  approved_patches_enable_non_security = false

  global_filter {
    key    = "PRODUCT"
    values = ["*"]
  }

  approval_rule {
    approve_after_days  = 7
    enable_non_security = false

    patch_filter {
      key    = "PRIORITY"
      values = ["Required", "Important", "Standard"]
    }
  }
}

resource "aws_ssm_patch_group" "this" {
  patch_group = local.web_server_patch_group
  baseline_id = aws_ssm_patch_baseline.this.id
}

resource "aws_ssm_association" "this" {
  name                = "AWS-RunPatchBaseline"
  association_name    = "${local.web_server_patch_group}-RunPatchBaseline-Association"
  schedule_expression = var.patching_schedule_cron

  parameters = {
    "Operation" = "Install"
  }

  targets {
    key    = "tag:PatchGroup"
    values = [local.web_server_patch_group]
  }
}

/**
 * # Footer
 *
 * Copyright (c) 2023 Simon Joz. All rights reserved.
 *
 */


