terraform {
  required_providers {
    ansible = {
      source  = "ansible/ansible"
      version = ">= 1.5.1, < 2.0.0"
    }
  }
}