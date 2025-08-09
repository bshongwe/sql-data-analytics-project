variable "location" {
  description = "Azure region"
  type        = string
  default     = "East US"
}

variable "sql_admin_login" {
  description = "SQL Server administrator login"
  type        = string
  default     = "sqladmin"
}

variable "sql_admin_password" {
  description = "SQL Server administrator password"
  type        = string
  sensitive   = true
}

variable "target_environment" {
  description = "Target environment (blue/green)"
  type        = string
  default     = "blue"
  validation {
    condition     = contains(["blue", "green"], var.target_environment)
    error_message = "Environment must be either 'blue' or 'green'."
  }
}

variable "trigger_deployment" {
  description = "Trigger GitHub Actions deployment"
  type        = bool
  default     = false
}

variable "switch_traffic" {
  description = "Switch traffic after deployment"
  type        = bool
  default     = false
}

variable "github_token" {
  description = "GitHub personal access token"
  type        = string
  sensitive   = true
}

variable "github_repo" {
  description = "GitHub repository (owner/repo)"
  type        = string
}