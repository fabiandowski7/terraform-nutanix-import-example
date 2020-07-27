
### find image
data "nutanix_image" "myImage" {
   image_name = var.image_name
}
### find subnet
data "nutanix_subnet" "mySubnet" {
  subnet_name = var.subnet_name
}
###find cluster
data "nutanix_cluster" "myCluster" {
  name = var.cluster_name
}
