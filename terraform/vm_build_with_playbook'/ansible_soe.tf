# The following code runs an ansible playbook to finish configuring a VM.

variable "launch_ansible_playbook" {
  type        = bool
  description = "Whether to launch the ansible playbook"
  default     = true
}

variable "rerun_playbook" {
  type        = bool
  description = "Whether to rerun the playbook"
  default     = false
}

variable "aap_host" {
  type        = string
  description = "The Ansible Controller specified as https://fqdn"
  default     = "https://aap.fqdn.tld"
}

variable "aap_username" {
  type        = string
  description = "AAP username"
  default     = "service_account"
}

variable "aap_password" {
  type        = string
  description = "AAP password for the service account"
  sensitive   = true
}

variable "job_template" {
  type        = string
  description = "The job template name to use"
}

variable "inventory" {
  type        = string
  description = "The inventory name"
  default     = "VMWareDynamic"
}

variable "job_timeout" {
  type        = number
  description = "The job timeout value in seconds"
  default     = 3600
}

output "playbook_output" {
  value       = var.launch_ansible_playbook ? ansible_playbook.main[0].ansible_playbook_stdout : null
  description = "The stdout of the ansible playbook"
}

resource "ansible_playbook" "main" {
  count = var.launch_ansible_playbook ? 1 : 0
  # depends_on = [
  #   vsphere_virtual_machine.main
  # ]
  ansible_playbook_binary = "/Users/phwhite/python-venv/ansible-14.4/bin/ansible-playbook"
  playbook   = "${path.module}/launch_job.yml"
  name       = "localhost"
  replayable = var.rerun_playbook

  extra_vars = {
    aap_host          = var.aap_host
    aap_username      = var.aap_username
    aap_password      = var.aap_password
    job_template      = var.job_template
    inventory         = var.inventory
    job_timeout       = var.job_timeout
    limit             = "${vsphere_virtual_machine.main.name}.fqdn.tld"
  }
}
