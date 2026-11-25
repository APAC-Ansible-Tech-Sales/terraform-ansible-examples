# VM build with Ansible playbook

These files finish a VM build by running `launch_job.yml` against localhost. The playbook syncs the matching Ansible Automation Platform (AAP) inventory sources, then launches a job template limited to the new VM.

Place `ansible_soe.tf` and `launch_job.yml` in the **same** Terraform configuration as `resource "vsphere_virtual_machine" "main"`. The playbook resource depends on that VM and builds the job limit from its name (`<name>.fqdn.tld`). It is not a standalone child module.

## Prerequisites

- Terraform provider [`ansible/ansible`](https://registry.terraform.io/providers/ansible/ansible/latest), which supplies `ansible_playbook`.
- `ansible-core` on the machine running Terraform, plus the `awx.awx` and `community.general` collections (used by `launch_job.yml`).
- The `jmespath` Python package, installed in the same Python environment as Ansible (`pip install jmespath`). The `community.general.json_query` filter needs it.
- An AAP inventory whose name matches `inventory`, with inventory sources Terraform can sync.
- A job template whose name matches `job_template`. In AAP, enable **Prompt on launch** for Inventory and Limit. The playbook supplies both when it launches the template, and the controller rejects the launch when those prompts are disabled.

## Usage

Pass the two required variables. Everything else can be left at its default.

```hcl
terraform {
  required_providers {
    ansible = {
      source = "ansible/ansible"
    }
  }
}

# ansible_soe.tf and launch_job.yml live beside vsphere_virtual_machine.main
```

```hcl
# terraform.tfvars
aap_password = "replace-me"
job_template = "linux-config
```

Set `launch_ansible_playbook = false` to create the VM without launching the playbook. Set `rerun_playbook = true` when a later apply should run the playbook again; the default is to run it once.

Stdout is available as the `playbook_output` output when the playbook runs. It is `null` when `launch_ansible_playbook` is false.

Run `launch_job.yml` on its own from this directory:

```bash
ansible-playbook launch_job.yml \
  -e aap_host='https://controller-fqzqj.apps.ocpv01.rhdp.net' \
  -e aap_username='service_account' \
  -e aap_password='aap_password' \
  -e "job_template='Demo Job Template'" \
  -e "inventory='Demo Inventory'" \
  -e job_timeout='3600' \
  -e limit='localhost'
```

Values that contain spaces need quotes that Ansible itself sees. The shell removes the quotes in `-e inventory='Demo Inventory'`, and Ansible then keeps only `Demo`.

## Variables

| Variable | Type | Default | Required | Description |
| --- | --- | --- | --- | --- |
| `aap_password` | `string` (sensitive) | none | yes | AAP password for the service account. |
| `job_template` | `string` | none | yes | Job template name to launch. |
| `launch_ansible_playbook` | `bool` | `true` | no | Whether to launch the Ansible playbook. |
| `rerun_playbook` | `bool` | `false` | no | Whether a later apply should run the playbook again. |
| `aap_host` | `string` | `https://aap.fqdn.tld` | no | Ansible controller URL, including `https://`. |
| `aap_username` | `string` | `service_account` | no | AAP username. |
| `inventory` | `string` | `VMWareDynamic` | no | AAP inventory name to sync and target. |
| `job_timeout` | `number` | `3600` | no | Job timeout in seconds. |

`aap_password` and `job_template` have no default, so Terraform will prompt for them (or fail in non-interactive runs) unless you set them in `terraform.tfvars`, `TF_VAR_*` environment variables, or `-var`.
