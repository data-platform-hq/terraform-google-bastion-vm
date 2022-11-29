variable "project_id" {
  description = "The ID of the project in which the resource belongs."
  type        = string
}

variable "product_base_name" {
  description = "Cloud resources base name (used to create services)"
  type        = string
}

variable "env" {
  description = "Variable to mark the environment of the resource (used to create services)."
  type        = string
  default     = "dev"
}

variable "disk_size" {
  description = "The size of the image (in gigabytes) for the boot disk."
  type        = string
  default     = "10"
}

variable "image" {
  description = "The image from which to initialize the boot disk for the instance."
  type        = string
  default     = "ubuntu-2004-focal-v20220927"
}

variable "network" {
  description = "Networks to attach to the instance."
  type        = string
}

variable "subnet" {
  description = "The Compute Engine subnetwork to be used for machine communications"
  type        = string
}

variable "location" {
  description = "The geographic location where the bucket be located"
  type        = string
}

variable "class" {
  description = "The Storage Class of the bucket"
  type        = string
  default     = "STANDARD"
}

variable "delete_data" {
  description = "If set to true, delete all data in the buckets when the resource is destroying"
  type        = bool
  default     = true
}

variable "versioning" {
  description = "Assign versioning for Storage"
  type        = bool
  default     = true
}

variable "lifecycle_rules" {
  description = "Assign lifecycle rule for Storage"
  type        = map(any)
  default = {
    lifecycle_rule_01 = {
      with_state                 = "ARCHIVED"
      num_newer_versions         = 2
      days_since_noncurrent_time = null
      storage_class              = ""
      type                       = "Delete"
    }
    lifecycle_rule_02 = {
      with_state                 = ""
      num_newer_versions         = null
      days_since_noncurrent_time = 7
      storage_class              = ""
      type                       = "Delete"
    }
  }
}

variable "sql_service_acc" {
  description = "The service account email address assigned to the sql instance."
  type        = string
}

variable "scripts_vars" {
  description = "Variables (key-value pairs) for script template files"
  type        = map(string)
  default     = {}
}

variable "scripts" {
  description = "Names of the template files of the scripts"
  type        = set(string)
  default     = []
}

variable "bastion_roles" {
  description = "The role that should be applied for Bastion service account."
  type        = set(string)
  default     = ["roles/cloudsql.admin", "roles/iam.serviceAccountUser", "roles/storage.admin"]
}

variable "scopes" {
  description = "A list of service scopes for VM."
  type        = set(string)
  default     = ["https://www.googleapis.com/auth/cloud-platform"]
}

variable "sqlsa_roles" {
  description = "The role that should be applied for SQL service account."
  type        = set(string)
  default     = ["roles/backupdr.cloudStorageOperator", "roles/storage.admin"]
}
