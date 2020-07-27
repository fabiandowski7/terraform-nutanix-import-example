## VM resource definition
resource "nutanix_virtual_machine" "myImportedVM" {
  name                 =  "yst-manual-deployment"
  cluster_uuid         = data.nutanix_cluster.myCluster.id
  num_vcpus_per_socket = "2"
  num_sockets          = "1"
  memory_size_mib      = 2048
  disk_list {
    data_source_reference = {
      kind = "image"
      uuid = data.nutanix_image.myImage.id
    }
    disk_size_bytes = 81 * 1024 * 1024 * 1024
  }

  nic_list {
    subnet_uuid = data.nutanix_subnet.mySubnet.id
  }

  disk_list {
    disk_size_bytes = 40 * 1024 * 1024 * 1024
  }
}
