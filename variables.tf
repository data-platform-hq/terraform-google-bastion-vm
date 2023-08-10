variable "project_id" {
  description = "The ID of the project in which to create the instance."
  type        = string
}

variable "region" {
  description = "The region in which to create the instance."
  type        = string
  default     = null
}

variable "zone" {
  description = "The zone in which to create the instance."
  type        = string
  default     = null
}

variable "env" {
  description = "Variable to mark the environment of the resources (used to create resources names)"
  type        = string
  default     = null
}

variable "prefix" {
  description = "Prefix for resource name"
  type        = string
  default     = null
}

variable "suffix" {
  description = "Suffix for resource name"
  default     = null
}


# variable "instance_name" {
#   description = "The name to assign to the instance."
#   type        = string
# }

variable "machine_type" {
  description = "The machine type to use for the instance (e.g. 'n1-standard-1')."
  type        = string
  default     = "e2-small"
}

variable "boot_disk" {
  description = "The configuration for the boot disk."
  type = object({
    auto_delete             = optional(bool)
    device_name             = optional(string)
    mode                    = optional(string)
    disk_encryption_key_raw = optional(string)
    kms_key_self_link       = optional(string)
    source                  = optional(string)
    initialize_params = optional(object({
      size                  = optional(number)
      type                  = optional(string)
      image                 = optional(string)
      labels                = optional(map(string))
      resource_manager_tags = optional(map(string))
    }))
  })
  default = {
    auto_delete = true
    initialize_params = {
      size  = 10
      type  = "pd-ssd"
      image = "ubuntu-2204-jammy-v20230727"
    }
  }
}

variable "network_interfaces" {
  description = "The list of network interfaces to attach to the instance."
  type = list(object({
    network            = optional(string)
    subnetwork         = optional(string)
    subnetwork_project = optional(string)
    network_ip         = optional(string)

    access_config = optional(object({
      external_ip            = optional(bool, false)
      nat_ip                 = optional(string, null)
      public_ptr_domain_name = optional(string, null)
      network_tier           = optional(string, null)
    }))

    alias_ip_range = optional(list(object({
      ip_cidr_range         = optional(string)
      subnetwork_range_name = optional(string)
    })))

    nic_type   = optional(string)
    stack_type = optional(string)

    ipv6_access_config = optional(list(object({
      enabled                = optional(bool, false)
      public_ptr_domain_name = optional(string, null)
      network_tier           = optional(string, null)
    })))

    queue_count = optional(number)
  }))

  default = null
}

variable "allow_stopping_for_update" {
  description = "Whether to allow the instance to be stopped temporarily during updates."
  type        = bool
  default     = true
}

variable "attached_disk" {
  description = "Additional disks to attach to the instance. Can be repeated multiple times for multiple disks"
  type = object({
    source                  = string
    device_name             = optional(string)
    mode                    = optional(string)
    disk_encryption_key_raw = optional(string)
    kms_key_self_link       = optional(string)
  })
  default = null
}

variable "can_ip_forward" {
  description = "Whether to allow sending and receiving of packets with non-matching source or destination IPs"
}

variable "description" {
  description = "A brief description of this resource"
  type        = string
  default     = null
}

variable "desired_status" {
  description = "Desired status of the instance. Either RUNNING or TERMINATED."
  type        = string
  default     = null
}

variable "deletion_protection" {
  description = "Enable deletion protection on this instance."
  type        = bool
  default     = false
}

variable "hostname" {
  description = "A custom hostname for the instance."
  type        = string
  default     = null
}

variable "guest_accelerator" {
  description = "List of the type and count of accelerator cards attached to the instance."
  type = object({
    type  = string
    count = number
  })
  default = null
}

variable "labels" {
  description = "A map of key/value label pairs to assign to the instance."
  type        = map(string)
  default     = null
}

variable "metadata" {
  description = "Additional metadata to pass to the instance."
  type        = map(string)
  default     = null
}

variable "metadata_startup_script" {
  description = <<-EOT
An alternative to using the startup-script metadata key, except this one forces the instance to be recreated (thus re-running the script) if it is changed. This replaces the startup-script metadata key on the created instance and thus the two mechanisms are not allowed to be used simultaneously.
EOT
  type        = string
  default     = null
}

variable "scripts" {
  description = "Names of the template files of the scripts (location for templates should be: ../scripts/ )"
  type        = set(string)
  default     = []
}


variable "min_cpu_platform" {
  description = "Specifies a minimum CPU platform for the VM instance."
  type        = string
  default     = null
}

variable "resource_manager_tags" {
  description = "Additional instance parameters."
  type        = object({})
  default     = null
}

variable "service_account" {
  description = "The email address of the service account to grant access to the instance."
  type = object({
    email  = optional(string)
    roles  = optional(set(string), [])
    scopes = optional(list(string), ["https://www.googleapis.com/auth/cloud-platform"])
  })
  default = {}
}

variable "tags" {
  description = "The list of tags to apply to the instance."
  type        = list(string)
  default     = []
}

variable "source_bucket" {
  description = "GCP Storage Bucket for storing scripts and temporary data."
  type        = string
  default     = null
}

variable "scripts_vars" {
  description = "Variables (key-value pairs) for script template files"
  type        = map(string)
  default     = {}
}

variable "startup_script" {
  description = "The URL of the startup script located on the GCP Cloud Storage Bucket."
  type        = string
  default     = null
}


# variable "scheduling" {
#   description = "The scheduling strategy to use."
#   type = object({
#     preemptible=optional(bool)
# on_host_maintenance=optional(string)
# automatic_restart=
# node_affinities=
# min_node_cpus=
# provisioning_model=
# instance_termination_action=
# max_run_duration=
# nanos=
# seconds=
# maintenance_interval=
# type=
# count=
#   })
# }

# variable "scratch_disk" {
#   description = "Scratch disks to attach to the instance."
#   # type=
# }
