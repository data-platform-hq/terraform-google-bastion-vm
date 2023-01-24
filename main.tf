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


## VM instace section
resource "google_storage_bucket_object" "startup_scripts" {
  for_each = toset(var.scripts)
  name     = "vm_templates/${each.key}"
  bucket   = var.source_bucket
  content  = templatefile("../scripts/${each.key}", var.scripts_vars)

  depends_on = [google_project_iam_member.bastion]
}

resource "google_compute_instance" "bastion" {
  name           = "${var.env}-${var.product_base_name}-vm-instance"
  machine_type   = var.machine_type
  can_ip_forward = var.ip_forward
  metadata = {
    startup-script-url = var.startup_script_url
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
resource "google_compute_firewall" "ssh_rule" {
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
  description   = "Allow remote connection from GCP consol to the bastion instace"
}
