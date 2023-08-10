locals {
  prefix = length(var.prefix) == 0 ? "" : "${var.prefix}-"
  suffix = length(var.suffix) == 0 ? "" : "-${var.suffix}"
  env    = length(var.env) == 0 ? "" : "${var.env}-"
  name   = lower("${local.prefix}${local.env}vm${local.suffix}")
}

resource "google_service_account" "compute_vm" {
  count = alltrue([var.service_account.email != null, length(var.service_account.roles) == 0]) ? 1 : 0

  account_id   = "${local.name}-sa"
  display_name = "${local.name}-sa"
}

resource "google_project_iam_member" "compute_vm" {
  for_each = length(var.service_account.roles) != 0 ? var.service_account.roles : []

  project = var.project_id
  role    = each.key
  member  = "serviceAccount:${google_service_account.compute_vm[0].email}"
}

resource "google_storage_bucket_object" "startup_scripts" {
  for_each = var.source_bucket != null ? toset(var.scripts) : []
  name     = "compute_vm_scripts/${each.key}"
  bucket   = var.source_bucket
  content  = templatefile("../scripts/${each.key}", var.scripts_vars)
}

resource "google_compute_instance" "vm" {
  name                      = local.name
  machine_type              = var.machine_type
  zone                      = var.zone
  allow_stopping_for_update = var.allow_stopping_for_update
  can_ip_forward            = var.can_ip_forward
  description               = var.description
  desired_status            = var.desired_status
  deletion_protection       = var.deletion_protection
  hostname                  = var.hostname
  metadata = merge(var.metadata, var.startup_script != null ? {
    "startup-script-url" = try(regex("^((gs|http)://).+", var.startup_script) != null ? var.startup_script : google_storage_bucket_object.startup_scripts[var.startup_script] != null ? google_storage_bucket_object.startup_scripts[var.startup_script].self_link : null, null)
  } : {})
  metadata_startup_script = var.metadata_startup_script
  min_cpu_platform        = var.min_cpu_platform

  dynamic "boot_disk" {
    for_each = var.boot_disk != null ? [var.boot_disk] : []
    content {
      auto_delete             = lookup(boot_disk.value, "auto_delete", true) # Set the default value for auto_delete to true
      device_name             = lookup(boot_disk.value, "device_name", null)
      mode                    = lookup(boot_disk.value, "mode", null)
      disk_encryption_key_raw = lookup(boot_disk.value, "disk_encryption_key_raw", null)
      kms_key_self_link       = lookup(boot_disk.value, "kms_key_self_link", null)
      source                  = lookup(boot_disk.value, "source", null)
      dynamic "initialize_params" {
        for_each = boot_disk.value.initialize_params != null ? [boot_disk.value.initialize_params] : []
        content {
          size                  = lookup(initialize_params.value, "size", null)
          type                  = lookup(initialize_params.value, "type", null)
          image                 = lookup(initialize_params.value, "image", null)
          labels                = lookup(initialize_params.value, "labels", null)
          resource_manager_tags = lookup(initialize_params.value, "resource_manager_tags", null)
        }
      }
    }
  }

  dynamic "network_interface" {
    for_each = var.network_interfaces
    content {
      network            = lookup(network_interface.value, "network", null)
      subnetwork         = lookup(network_interface.value, "subnetwork", null)
      subnetwork_project = lookup(network_interface.value, "subnetwork_project", null)
      network_ip         = lookup(network_interface.value, "network_ip", null)

      dynamic "access_config" {
        for_each = network_interface.value.access_config != null ? [network_interface.value.access_config.external_ip ? {
        } : network_interface.value.access_config] : []

        content {
          nat_ip                 = lookup(access_config.value, "nat_ip", null)
          public_ptr_domain_name = lookup(access_config.value, "public_ptr_domain_name", null)
          network_tier           = lookup(access_config.value, "network_tier", null)
        }
      }
      dynamic "alias_ip_range" {
        for_each = network_interface.value.alias_ip_range != null ? [network_interface.value.alias_ip_range] : []
        content {
          ip_cidr_range         = lookup(alias_ip_range.value, "", null)
          subnetwork_range_name = lookup(alias_ip_range.value, "", null)
        }
      }

      nic_type   = lookup(network_interface.value, "nic_type", null)
      stack_type = lookup(network_interface.value, "stack_type", null)
      dynamic "ipv6_access_config" {
        for_each = network_interface.value.ipv6_access_config != null ? [network_interface.value.ipv6_access_config.external_ip ? {
        } : network_interface.value.ipv6_access_config] : []
        content {
          public_ptr_domain_name = lookup(ipv6_access_config.value, "public_ptr_domain_name", null)
          network_tier           = lookup(ipv6_access_config.value, "network_tier", null)
        }
      }

      queue_count = lookup(network_interface.value, "queue_count", null)
    }
  }

  dynamic "attached_disk" {
    for_each = var.attached_disk != null ? [var.attached_disk] : []
    content {
      source                  = lookup(attached_disk.value, "source", null)
      device_name             = lookup(attached_disk.value, "device_name", null)
      mode                    = lookup(attached_disk.value, "mode", null)
      disk_encryption_key_raw = lookup(attached_disk.value, "disk_encryption_key_raw", null)
      kms_key_self_link       = lookup(attached_disk.value, "kms_key_self_link", null)
    }
  }

  dynamic "guest_accelerator" {
    for_each = var.guest_accelerator != null ? [var.guest_accelerator] : []
    content {
      type  = lookup(guest_accelerator.value, "source", null)
      count = lookup(guest_accelerator.value, "source", null)
    }
  }

  dynamic "params" {
    for_each = var.resource_manager_tags != null ? [var.resource_manager_tags] : []
    content {
      resource_manager_tags = params.value
    }
  }

  dynamic "service_account" {
    for_each = var.service_account != null ? [var.service_account] : []
    content {
      email  = length(var.service_account.roles) != 0 ? google_service_account.compute_vm[0].email : lookup(service_account.value, "email", null)
      scopes = lookup(service_account.value, "scopes", null)
    }
  }

  tags   = var.tags
  labels = var.labels

  # scheduling=
  # scratch_disk=
  # shielded_instance_config=
  # enable_display=
  # resource_policies=
  # reservation_affinity=
  # confidential_instance_config=
  # advanced_machine_features=
  # network_performance_config=
}
# output "access_config" {
#   value = [for test in var.network_interfaces : test.access_config]
# }
