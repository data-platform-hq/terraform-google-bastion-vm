# Google bastion VM instance Terraform module
Terraform module for creation of Google bastion VM instance resources 

## Usage

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name                                                                      | Version   |
| ------------------------------------------------------------------------- | --------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0  |
| <a name="requirement_google"></a> [google](#requirement\_google)          | >= 4.24.0 |

## Providers

| Name                                                             | Version   |
| ---------------------------------------------------------------- | --------- |
| <a name="requirement_google"></a> [google](#requirement\_google) | >= 4.24.0 |

## Modules

No modules.

## Resources

| Name                                                                                                                                                             | Type     |
| ---------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------- |
| [google_service_account.bastion_sa](https://registry.terraform.io/providers/DrFaust92/google/latest/docs/resources/google_service_account)                       | resource |
| [google_project_iam_member.bastion](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_project_iam#google_project_iam_member) | resource |
| [google_storage_bucket_object.startup_scripts](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket_object)             | resource |
| [google_compute_instance.bastion](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance)                               | data     |
| [google_compute_firewall.ssh_rule](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall)                              | resource |

## Inputs

| Name                                                                                         | Description                                                                                                         | Type          | Default                                            | Required |
| -------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------- | ------------- | -------------------------------------------------- | :------: |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id)                           | The ID of the project in which the resource belongs.                                                                | `string`      | n/a                                                |   yes    |
| <a name="input_product_base_name"></a> [product\_base\_name](#input\_product\_base\_name)    | Cloud resources base name (used to create services).                                                                | `string`      | n/a                                                |   yes    |
| <a name="input_env"></a> [env](#input\_env)                                                  | Variable to mark the environment of the resource (used to create services).                                         | `string`      | n/a                                                |   yes    |
| <a name="input_disk_size"></a> [disk\_size](#input\_disk\_size)                              | The size of the image (in gigabytes) for the boot disk.                                                             | `string`      | "10"                                               |    no    |
| <a name="input_image"></a> [image](#input\_image)                                            | The image from which to initialize the boot disk for the instance.                                                  | `string`      | "ubuntu-2004-focal-v20220927"                      |    no    |
| <a name="input_network"></a> [rnetwork](#input\_network)                                     | Networks to attach to the instance.                                                                                 | `string`      | n/a                                                |   yes    |
| <a name="input_subnet"></a> [subnet](#input\_subnet)                                         | The location or cloud resources region for the environment.                                                         | `string`      | n/a                                                |   yes    |
| <a name="input_bastion_roles"></a> [bastion\_roles](#input\_bastion\_roles)                  | Roles that should be applied for Bastion service account.                                                           | `set(string)` | n/a                                                |   yes    |
| <a name="input_source_bucket"></a> [source\_bucket](#input\_source\_bucket)                  | GCP Storage Bucket for storing scripts and temporary data.                                                          | `string`      | ""                                                 |    no    |
| <a name="input_startup_script_url"></a> [startup\_script\_url](#input\_startup\_script\_url) | The URL of the startup script located on the GCP Cloud Storage Bucket.                                              | `string`      | ""                                                 |    no    |
| <a name="input_scripts"></a> [scripts](#input\_scripts)                                      | Names of the template files of the scripts (location for templates should be: ./templates/                          | `set(string)` | []                                                 |    no    |
| <a name="input_scripts_vars"></a> [scripts\_vars](#input\_scripts\_vars)                     | Variables (key-value pair) for script template files.                                                               | `map(string)` | {}                                                 |    no    |
| <a name="input_machine_type"></a> [machine\_type](#input\_machine\_type)                     | The machine type to create.                                                                                         | `string`      | "e2-small"                                         |    no    |
| <a name="input_ip_forwarding"></a> [ip\_forwarding](#input\_ip\_forwarding)                  | Whether to allow sending and receiving of packets with non-matching source or destination IPs.                      | bool`         | false                                              |    no    |
| <a name="input_scopes"></a> [scopes](#input\_scopes)                                         | A list of service scopes for VM                                                                                     | `set(string)` | ["https://www.googleapis.com/auth/cloud-platform"] |    no    |
| <a name="input_labels"></a> [labels](#input\_labels)                                         | The labels associated with this module.                                                                             | `map(string)` | {}                                                 |    no    |
| <a name="input_remote_from"></a> [remote\_from](#input\_remote\_from)                        | Allow remote connection to bastion instace from provided subnet CIDR range. For GCP consol provide 35.235.240.0/20. | `set(string)` | ["35.235.240.0/20"]                                |    no    |
| <a name="input_rem_conn_port"></a> [rem\_conn\_port](#input\_rem\_conn\_port)                | Allow remote connection to bastion instace through provided port                                                    | `set(string)` | ["22"]                                             |    no    |
## Outputs

No outputs
<!-- END_TF_DOCS -->

## License

Apache 2 Licensed. For more information please see [LICENSE](https://github.com/data-platform-hq/terraform-google-bastion-vm/blob/main/LICENSE)
