locals {
  pre_fix                     = "${var.resource_name}-${var.environment}"
  visibility                  = var.enable_public_access ? "public" : "private"
  launch_template_name        = "${local.pre_fix}-lt"
  sg_name                     = "${local.pre_fix}-${local.visibility}-sg"
  auto_scaling_group_name     = "${local.pre_fix}-${local.visibility}-asg"
  placement_group_name        = "${local.pre_fix}-${local.visibility}-plg"
  scale_out_metric_alarm_name = "${local.pre_fix}-scale-out-${local.visibility}-ec2"
  scale_in_metric_alarm_name  = "${local.pre_fix}-scale-in-${local.visibility}-ec2"
  subnet_ids                  = concat(var.public_subnet_ids, var.private_subnet_ids)
  key_name                    = "${local.pre_fix}-key"
  key_pair_name               = var.key_pair_name != null ? var.key_pair_name : aws_key_pair.generated_key[0].key_name
  image_id                    = var.ecs_cluster_name != null ? data.aws_ami.al2023_ecs_kernel6plus.image_id : data.aws_ami.al2023_kernel6plus.image_id
  user_data                   = var.ecs_cluster_name != null ? data.template_file.ecs_user_data.rendered : data.template_file.init_user_data.rendered
  ecs_instance_role_name      = "${local.pre_fix}-ecsInstanceRole"
  ecs_instance_profile_name   = "${local.pre_fix}-ecsInstanceProfile"
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    Visibility  = local.visibility
  }
}

variable "project_name" {
  type        = string
  description = "Name of the overall project. Used for naming and tagging resources."
}

variable "resource_name" {
  type        = string
  description = "Base name used to identify resources (e.g., EC2, SG, etc.)."
}

variable "use_spot" {
  type        = bool
  default     = false
  description = "set it to true if want to use spot instances"
}

variable "ecs_cluster_name" {
  type        = string
  default     = null
  description = "Name of ECS cluster"
}

variable "health_check_type" {
  type        = string
  default     = "EC2"
  description = "EC2 health check type EC2 or ELB"
}

variable "instance_placement_strategy" {
  type        = string
  default     = "spread"
  description = "Name of ECS cluster"
}

variable "loadbalancer_sg_id" {
  type        = string
  default     = null
  description = "Security group ID for the load balancer. Required when public access is disabled or no public subnets are defined."
  validation {
    condition = (
      !(var.enable_public_access == false) || (var.loadbalancer_sg_id != null)
    )
    error_message = "When public access is disabled or no public subnets are defined, 'loadbalancer_sg_id' must be provided."
  }
}

variable "environment" {
  type        = string
  description = "Deployment environment (e.g., dev, staging, prod)."
}

variable "public_subnet_ids" {
  type        = list(string)
  default     = []
  description = "List of public subnet IDs used when public access is enabled."
}

variable "instance_type" {
  type        = string
  default     = "t2.micro"
  description = "EC2 instance type for the server(s)."
}

variable "ebs_type" {
  type        = string
  default     = "gp2"
  description = "EBS volume type for EC2 instances (e.g., gp2, gp3, io1)."
}

variable "ebs_size" {
  type        = string
  default     = 30
  description = "EBS volume type for EC2 instances (e.g., gp2, gp3, io1)."
}

variable "enable_public_access" {
  type        = bool
  default     = false
  description = "Whether to enable public access for EC2 instances via public subnets."
  validation {
    condition     = !(var.enable_public_access == true && length(var.public_subnet_ids) == 0)
    error_message = "To enable public access, at least one public subnet is needed."
  }
}

variable "enable_auto_scaling_alarms" {
  type        = bool
  default     = false
  description = "Whether to enable public access for EC2 instances via public subnets."
}

variable "enable_http" {
  type        = bool
  default     = false
  description = "Whether to allow HTTP traffic (port 80) to the EC2 instances."
}

variable "enable_https" {
  type        = bool
  default     = false
  description = "Whether to allow HTTPS traffic (port 443) to the EC2 instances."
}

variable "enable_ssh" {
  type        = bool
  default     = false
  description = "Whether to allow SSH access (port 22) to the EC2 instances."
}

variable "private_subnet_ids" {
  type        = list(string)
  default     = []
  description = "List of private subnet IDs for launching EC2 instances without public access."
}

variable "availability_zone_ids" {
  type        = list(string)
  description = "List of availability zone IDs where resources will be deployed."
}

variable "target_group_arns" {
  type        = list(string)
  default     = []
  description = "List of target group ARNs to register instances with (for ALB/NLB)."
}

variable "key_pair_name" {
  type    = string
  default = null
}

variable "vpc_id" {
  type        = string
  description = "ID of the VPC where resources will be deployed."
}
