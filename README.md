# Manage existing Nutanix AHV virtual machines using Terraform

Deploying and managing resources via Terraform has many of benefits. It is easy, you can version control your different configurations and you can make sure that the state of virtual machines remains consistent with your declaration.
In most use-cases you will define your resources via Terraform code and deploy those workloads using Terraform. In some cases you may want to manage existing workloads (already provisioned manually?) running on top of Nutanix with Terraform. 
Since Terraform will only manage resources that are part of its statefile, it will not manage existing/already deployed workloads. Luckily there is a way to get existing workloads into your statefile. 

We will show the steps how to import an existing VM into your statefile and manage it via Terraform.
The code can be found in this repository:
https://github.com/yannickstruyf3/terraform-nutanix-import-example

## Identify your existing workloads
First you need to identify which workload/vm you want to manage via Terraform. 
For this example I will use Prism Element (PE) to find my virtual machine. Search for the virtual machine and note down the ID. This will be used later.
![alt_text](https://github.com/yannickstruyf3/terraform-nutanix-import-example/raw/master/images/1_identify_vm.png )
Also analyse the current virtual machine layout:
- On which Nutanix Cluster is it running?
- How many vCPUs/sockets?
- How much memory?
- Amount of disks? Image used?
- Amount of nics?

Based on this information we will model our virtual machine using Terraform resources.

## Model the virtual machine
The next step is to model the virtual machine in code. The code repository contains example Terraform code. It contains following files:
- `provider.tf`: Initialize the provider and set required provider version
- `datasources.tf`: Perform lookups for required linked entities (image, cluster, subnet)
- `variables.tf`: Variable declarations (optional and mandatory)
- `main.tf`: Virtual machine definition

The most important code for the import is located in the `main.tf` file. Here we will define the properties of the virtual machine that we want to manage. 
**Note:**Keep this definition as close as possible to the original virtual machine, otherwise Terraform will update the virtual machine when performing a new `terraform apply`

## Importing the virtual machine
First we need to make sure terraform was initialised:
```
terraform init
```
Output:
```
Initializing the backend...

Initializing provider plugins...
- Checking for available provider plugins...
- Downloading plugin for provider "nutanix" (terraform-providers/nutanix) 1.1.0...

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.
```

Next we will import the virtual machine. To do this we will use the `terraform import` command. In order to import a resource, we need to inform Terraform which resource we will import followed by the ID of that resource. In this case we want to import the `nutanix_virtual_machine.myImportedVM` resource that is identified by the virtual machine UUID we found in Prism Element.
Run the command:
```
terraform import nutanix_virtual_machine.myImportedVM fcb451ed-509e-480d-80b3-2d09eef6e1a0
```
Output:
```
nutanix_virtual_machine.myImportedVM: Importing from ID "fcb451ed-509e-480d-80b3-2d09eef6e1a0"...
nutanix_virtual_machine.myImportedVM: Import prepared!
  Prepared nutanix_virtual_machine for import
nutanix_virtual_machine.myImportedVM: Refreshing state... [id=fcb451ed-509e-480d-80b3-2d09eef6e1a0]

Import successful!

The resources that were imported are shown above. These resources are now in
your Terraform state and will henceforth be managed by Terraform.

```
You will notice that a new `terraform.tf` state file has been created. Terraform now has enough information to manage the resource.
Run a `terraform plan` to verify if the import was successful.
```
terraform plan
```
Output:
```
Refreshing Terraform state in-memory prior to plan...
The refreshed state will be used to calculate this plan, but will not be
persisted to local or remote state storage.

data.nutanix_subnet.mySubnet: Refreshing state...
data.nutanix_image.myImage: Refreshing state...
data.nutanix_cluster.myCluster: Refreshing state...
nutanix_virtual_machine.vm: Refreshing state... [id=58981fb6-ec5b-4ac4-8944-8822342c34ee]
nutanix_virtual_machine.myImportedVM: Refreshing state... [id=fcb451ed-509e-480d-80b3-2d09eef6e1a0]
###
# Removed output
###
        api_version                                      = "3.1"
        id                                               = "fcb451ed-509e-480d-80b3-2d09eef6e1a0"
      ~ memory_size_mib                                  = 1024 -> 2048

        name                                             = "yst-manual-deployment"
        num_sockets                                      = 1
        num_vcpus_per_socket                             = 2
###
# Removed output
###

Plan: 0 to add, 1 to change, 0 to destroy.

------------------------------------------------------------------------

Note: You didn't specify an "-out" parameter to save this plan, so Terraform
can't guarantee that exactly these actions will be performed if
"terraform apply" is subsequently run.
```

In my case above I did not model my resource identical to the running virtual machine. Terraform will detect this and will update the virtual machine so it is compliant to the desired state. When I now run `terraform apply` it will increase the amount of memory from 1GB to 2GB. 

```
terraform apply
```
Output:
```
data.nutanix_image.myImage: Refreshing state...
data.nutanix_subnet.mySubnet: Refreshing state...
data.nutanix_cluster.myCluster: Refreshing state...
nutanix_virtual_machine.vm: Refreshing state... [id=58981fb6-ec5b-4ac4-8944-8822342c34ee]
nutanix_virtual_machine.myImportedVM: Refreshing state... [id=fcb451ed-509e-480d-80b3-2d09eef6e1a0]
###
# Removed output
###
nutanix_virtual_machine.myImportedVM: Modifying... [id=fcb451ed-509e-480d-80b3-2d09eef6e1a0]
nutanix_virtual_machine.myImportedVM: Still modifying... [id=fcb451ed-509e-480d-80b3-2d09eef6e1a0, 10s elapsed]
nutanix_virtual_machine.myImportedVM: Still modifying... [id=fcb451ed-509e-480d-80b3-2d09eef6e1a0, 20s elapsed]
nutanix_virtual_machine.myImportedVM: Still modifying... [id=fcb451ed-509e-480d-80b3-2d09eef6e1a0, 30s elapsed]
nutanix_virtual_machine.myImportedVM: Still modifying... [id=fcb451ed-509e-480d-80b3-2d09eef6e1a0, 40s elapsed]
nutanix_virtual_machine.myImportedVM: Modifications complete after 47s [id=fcb451ed-509e-480d-80b3-2d09eef6e1a0]

Apply complete! Resources: 0 added, 1 changed, 0 destroyed.
```

## Modifying a resource
Modifying the virtual machine (or deleting) can now be performed via Terraform. You can add a disk (40 GB) by modifying the `myImportedVM` resource definition:

```
##main.tf##
## VM resource definition
resource "nutanix_virtual_machine" "myImportedVM" {
  name                 =  "yst-manual-deployment"
###
# Code
###
  disk_list {
    disk_size_bytes = 40 * 1024 * 1024 * 1024
  }
###
# Code
###
}
```

```
terraform apply
```
Output:
```
data.nutanix_image.myImage: Refreshing state...
data.nutanix_subnet.mySubnet: Refreshing state...
data.nutanix_cluster.myCluster: Refreshing state...
nutanix_virtual_machine.myImportedVM: Refreshing state... [id=fcb451ed-509e-480d-80b3-2d09eef6e1a0]

An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  ~ update in-place

Terraform will perform the following actions:
###
# Removed output
###
      + disk_list {
          + data_source_reference  = (known after apply)
          + disk_size_bytes        = 42949672960
          + volume_group_reference = (known after apply)

          + device_properties {
              + device_type  = (known after apply)
              + disk_address = (known after apply)
            }

          + storage_config {
              + flash_mode = (known after apply)

              + storage_container_reference {
                  + kind = (known after apply)
                  + name = (known after apply)
                  + url  = (known after apply)
                  + uuid = (known after apply)
                }
            }
        }
###
# Removed output
###
nutanix_virtual_machine.myImportedVM: Still modifying... [id=fcb451ed-509e-480d-80b3-2d09eef6e1a0, 1m0s elapsed]
nutanix_virtual_machine.myImportedVM: Still modifying... [id=fcb451ed-509e-480d-80b3-2d09eef6e1a0, 1m10s elapsed]
nutanix_virtual_machine.myImportedVM: Modifications complete after 1m15s [id=fcb451ed-509e-480d-80b3-2d09eef6e1a0]

Apply complete! Resources: 0 added, 1 changed, 0 destroyed.
```

Now we have a virtual machine running on Nutanix managed by Terraform that has 2GB of memory and an additional disk of 40GB.

![alt_text](https://github.com/yannickstruyf3/terraform-nutanix-import-example/raw/master/images/2_updated_vm.png )
