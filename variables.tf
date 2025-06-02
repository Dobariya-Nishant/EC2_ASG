data "http" "my_ip" {
  url = "https://api.ipify.org"
}

locals {
  pre_fix                     = "${var.name}-${var.environment}"                                                                              # Common prefix for naming resources
  visibility                  = var.enable_public_https || var.enable_public_https ? "public" : "private"        
  my_ip_cidr = "${chomp(data.http.my_ip.body)}/32"
  enable_ssh =  var.enable_public_ssh || local.enable_ssh_from_current_ip                                                       # Indicates visibility of the setup                                                                              # EC2 launch template name                                       
  
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

variable "name" {
  type        = string
  description = "Base resource name used to uniquely identify all created resources."
}

variable "enable_protect_from_scale_in" {
  type = bool
  default = false
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

variable "enable_auto_scaling_alarms" {
  type        = bool
  default     = false
  description = "Whether to enable CloudWatch alarms for scaling EC2 instances in/out."
}

variable "enable_public_http" {
  type        = bool
  default     = false
  description = "Enable ingress on port 80 for HTTP traffic."
  validation {
    condition     = !(var.enable_public_http == true && length(var.public_subnet_ids) == 0)
    error_message = "To enable public access, at least one public subnet is needed."
  }
}

variable "enable_public_https" {
  type        = bool
  default     = false
  description = "Enable ingress on port 443 for HTTPS traffic."
  validation {
    condition     = !(var.enable_public_https == true && length(var.public_subnet_ids) == 0)
    error_message = "To enable public access, at least one public subnet is needed."
  }
}

variable "enable_public_ssh" {
  type        = bool
  default     = false
  description = "Enable ingress on port 22 for SSH access to EC2 instances."
}

variable "enable_ssh_from_current_ip" {
  description = "Enable SSH access from the IP of the machine running Terraform"
  type        = bool
  default     = false
}

variable "load_balancer_config"  {
  type = optional(list(object({
    sg_id = string
    port  = number
    protocol = optional(string)
  })))
  default = []
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