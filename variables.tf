## Optional
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
  description = "The geographic location where the bucket be located (for the main project)"
  type        = string
}

variable "class" {
  description = "The Storage Class of the bucket. Can be set one of STANDARD, MULTI_REGIONAL, REGIONAL, NEARLINE, COLDLINE, ARCHIVE"
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
  default     = {}
}

variable "bastion_roles" {
  description = "The role that should be applied for Bastion service account."
  type        = set(string)
  default     = []
}

variable "sql_service_acc" {
  description = "The service account email address assigned to the sql instance."
  type        = string
  default     = ""
}

variable "sqlsa_roles" {
  description = "The role that should be applied for SQL service account."
  type        = set(string)
  default     = []
}

variable "scripts" {
  description = "Names of the template files of the scripts (location for templates should be: ./templates/ )."
  type        = set(string)
  default     = []
}

variable "scripts_vars" {
  description = "Variables (key-value pairs) for script template files."
  type        = map(string)
  default     = {}
}

variable "machine_type" {
  description = "The machine type to create."
  type        = string
  default     = "e2-small"
}

variable "ip_forward" {
  description = "Whether to allow sending and receiving of packets with non-matching source or destination IPs."
  type        = bool
  default     = false
}

variable "scopes" {
  description = "A list of service scopes for VM."
  type        = set(string)
  default     = ["https://www.googleapis.com/auth/cloud-platform"]
}

variable "labels" {
  description = "The labels associated with this module."
  type        = map(string)
  default     = {}
}

variable "remote_from" {
  description = "Allow remote connection to bastion instace from provided subnet CIDR range. For GCP consol provide 35.235.240.0/20."
  type        = set(string)
  default     = ["35.235.240.0/20"]
}

variable "rem_conn_port" {
  description = "Allow remote connection to bastion instace through provided port."
  type        = set(string)
  default     = ["22"]
}
