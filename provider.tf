terraform {
  required_version = ">= 0.13"
  ## Define the required version of the provider
  required_providers {
    nutanix = {
      source  = "terraform-providers/nutanix"
      version = "~> 1.1"
    }
  }
}

## Define the connection to the Prism Central
## Variables can be defined in a terraform.tfvars file
provider "nutanix" {
  username = var.username
  password = var.password
  endpoint = var.prism_central
  insecure = true
  port     = 9440
}
