locals {
  pre_fix                     = "${var.resource_name}-${var.environment}"                                                                              # Common prefix for naming resources
  visibility                  = var.enable_public_access ? "public" : "private"                                                                        # Indicates visibility of the setup
  launch_template_name        = "${local.pre_fix}-lt"                                                                                                  # EC2 launch template name
  sg_name                     = "${local.pre_fix}-${local.visibility}-sg"                                                                              # Security group name based on visibility
  auto_scaling_group_name     = "${local.pre_fix}-${local.visibility}-asg"                                                                             # Auto Scaling Group name
  placement_group_name        = "${local.pre_fix}-${local.visibility}-plg"                                                                             # Placement group name for EC2 instances
  scale_out_metric_alarm_name = "${local.pre_fix}-scale-out-${local.visibility}-ec2"                                                                   # CloudWatch alarm name for scaling out
  scale_in_metric_alarm_name  = "${local.pre_fix}-scale-in-${local.visibility}-ec2"                                                                    # CloudWatch alarm name for scaling in
  subnet_ids                  = concat(var.public_subnet_ids, var.private_subnet_ids)                                                                  # Combined subnet list for resource placement
  key_name                    = "${local.pre_fix}-key"                                                                                                 # Key name used when generating EC2 key pair
  key_pair_name               = var.key_pair_name == null && var.enable_ssh == true ? aws_key_pair.generated_key[0].key_name : var.key_pair_name       # Final key pair name
  image_id                    = var.ecs_cluster_name != null ? data.aws_ami.al2023_ecs_kernel6plus.image_id : data.aws_ami.al2023_kernel6plus.image_id # Choose ECS-ready AMI or regular based on cluster
  user_data                   = var.ecs_cluster_name != null ? data.template_file.ecs_user_data.rendered : data.template_file.init_user_data.rendered  # User data script based on ECS usage
  ecs_instance_role_name      = "${local.pre_fix}-ecsInstanceRole"                                                                                     # IAM role name for ECS EC2 instances
  ecs_instance_profile_name   = "${local.pre_fix}-ecsInstanceProfile"                                                                                  # IAM instance profile name for ECS EC2 instances
  common_tags = {
    Project     = var.project_name # Project name tag
    Environment = var.environment  # Environment tag (dev/staging/prod)
    Visibility  = local.visibility # Visibility tag (public/private)
  }
}

variable "project_name" {
  type        = string
  description = "Name of the overall project. Used for consistent tagging and naming."
}

variable "resource_name" {
  type        = string
  description = "Base resource name used to uniquely identify all created resources."
}

variable "use_spot" {
  type        = bool
  default     = false
  description = "Set to true to use EC2 Spot Instances instead of On-Demand."
}

variable "ecs_cluster_name" {
  type        = string
  default     = null
  description = "ECS cluster name. Used to determine whether to use ECS-specific AMI and user data."
}

variable "health_check_type" {
  type        = string
  default     = "EC2"
  description = "Type of health check for Auto Scaling Group (EC2 or ELB)."
}

variable "instance_placement_strategy" {
  type        = string
  default     = "spread"
  description = "Placement strategy for EC2 instances. (e.g., spread, cluster)"
}

variable "loadbalancer_sg_id" {
  type        = string
  default     = null
  description = "Security group ID of the ALB or NLB used with instances."
}

variable "environment" {
  type        = string
  description = "Deployment environment (e.g., dev, staging, prod)."
}

variable "public_subnet_ids" {
  type        = list(string)
  default     = []
  description = "List of subnet IDs that are public and support internet access."
}

variable "instance_type" {
  type        = string
  default     = "t2.micro"
  description = "EC2 instance type (e.g., t3.medium, m5.large)."
}

variable "ebs_type" {
  type        = string
  default     = "gp2"
  description = "EBS volume type attached to EC2 instances (e.g., gp2, gp3, io1)."
}

variable "ebs_size" {
  type        = string
  default     = 30
  description = "Size of the EBS volume (in GB) attached to the EC2 instance."
}

variable "enable_public_access" {
  type        = bool
  default     = false
  description = "Set to true to enable EC2 instance access from public internet via public subnet."
  validation {
    condition     = !(var.enable_public_access == true && length(var.public_subnet_ids) == 0)
    error_message = "To enable public access, at least one public subnet is needed."
  }
}

variable "enable_auto_scaling_alarms" {
  type        = bool
  default     = false
  description = "Whether to enable CloudWatch alarms for scaling EC2 instances in/out."
}

variable "enable_http" {
  type        = bool
  default     = false
  description = "Enable ingress on port 80 for HTTP traffic."
}

variable "enable_https" {
  type        = bool
  default     = false
  description = "Enable ingress on port 443 for HTTPS traffic."
}

variable "enable_ssh" {
  type        = bool
  default     = false
  description = "Enable ingress on port 22 for SSH access to EC2 instances."
}

variable "private_subnet_ids" {
  type        = list(string)
  default     = []
  description = "List of private subnet IDs to launch EC2 instances without public exposure."
}

variable "availability_zone_ids" {
  type        = list(string)
  description = "List of availability zone IDs (AZs) for launching EC2 resources across zones."
}

variable "target_group_arns" {
  type        = list(string)
  default     = []
  description = "List of target group ARNs for registering EC2 instances (used with ALB/NLB)."
}

variable "key_pair_name" {
  type        = string
  default     = null
  description = "Optional: Name of an existing EC2 key pair to use. If not provided, a new one will be created."
}

variable "vpc_id" {
  type        = string
  description = "ID of the VPC where all resources will be deployed."
}

variable "desired_capacity" {
  type        = number
  default     = 1
  description = "The initial number of EC2 instances to launch in the Auto Scaling Group."
}

variable "min_size" {
  type        = number
  default     = 1
  description = "The minimum number of EC2 instances the Auto Scaling Group can scale down to."
}

variable "max_size" {
  type        = number
  default     = 10
  description = "The maximum number of EC2 instances the Auto Scaling Group can scale up to."
}