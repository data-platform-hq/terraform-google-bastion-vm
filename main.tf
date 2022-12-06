## Bucket section
resource "google_storage_bucket" "source" {
  name          = "${var.env}-${var.product_base_name}-source-${var.project_id}-bucket"
  location      = var.location
  storage_class = var.class
  force_destroy = var.delete_data
  versioning {
    enabled = var.versioning
  }
  dynamic "lifecycle_rule" {
    for_each = var.lifecycle_rules
    content {
      condition {
        with_state                 = lifecycle_rule.value.with_state
        num_newer_versions         = lifecycle_rule.value.num_newer_versions
        days_since_noncurrent_time = lifecycle_rule.value.days_since_noncurrent_time
      }
      action {
        type          = lifecycle_rule.value.type
        storage_class = lifecycle_rule.value.storage_class
      }
    }
  }
  labels = var.labels
}

## VM Service account section
resource "google_service_account" "bastion_sa" {
  account_id   = "${var.env}-${var.product_base_name}-bastion-sa"
  display_name = "${var.env}-${var.product_base_name}-bastion-sa"
}

resource "google_project_iam_member" "bastion" {
  project  = var.project_id
  for_each = var.bastion_roles
  role     = each.key
  member   = "serviceAccount:${google_service_account.bastion_sa.email}"
}

resource "google_project_iam_member" "sql" {
  project  = var.project_id
  count    = length(var.ql_service_acc) == 0 ? 0 : 1
  for_each = var.sqlsa_roles
  role     = each.key
  member   = "serviceAccount:${var.sql_service_acc}"
}


## VM instace section
resource "google_storage_bucket_object" "startup_scripts" {
  for_each = toset(var.scripts)
  name     = "templates/${each.key}"
  bucket   = google_storage_bucket.source.name
  content  = templatefile("${path.module}/templates/${each.key}", merge(var.scripts_vars, { BUCKET_NAME = google_storage_bucket.source.url }))
}

resource "google_compute_instance" "bastion" {
  name           = "${var.env}-${var.product_base_name}-vm-instance"
  machine_type   = var.machine_type
  can_ip_forward = var.ip_forward
  metadata = {
    startup-script-url = "${google_storage_bucket.source.url}/templates/vm_configuration.sh"
  }
  boot_disk {
    initialize_params {
      type  = "pd-ssd"
      size  = var.disk_size
      image = var.image
    }
  }
  network_interface {
    network = var.network
    access_config {
      #    Ephemeral public IP
    }
    subnetwork = var.subnet
  }
  service_account {
    email  = google_service_account.bastion_sa.email
    scopes = var.scopes
  }
  allow_stopping_for_update = true

  labels = var.labels

  depends_on = [google_storage_bucket_object.startup_scripts]
}

## Firewall (SSH) section
resource "google_compute_firewall" "gcp_consol_rule" {
  project  = var.project_id
  name     = "${var.env}-${var.product_base_name}-gcpconsol-ingress-allow"
  network  = var.network
  priority = "100"
  allow {
    protocol = "tcp"
    ports    = var.rem_conn_port
  }
  direction     = "INGRESS"
  source_ranges = var.remote_from

  description = "Allow ssh connection from GCP consol to the bastion instace"
}
