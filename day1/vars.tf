variable "projectname" {
  default = "my-labs-task"
}
variable "region" {
  default = "us-central1"
}
variable "zone" {
  default = "us-central1-c"
}
variable "createway" {
  default = "terraform"
}
variable "machinetype" {
  default = "e2-custom-6-8192"
}
variable "image" {
  default = "centos-cloud/centos-7"
}
variable "hdd-size" {
  default = "20"
}
variable "hdd-type" {
  default = "pd-ssd"
}
variable "network-name" {
  default = "prometheus-vpv"
}
variable "prometheus-sub-net-name" {
  default = "prometheus-sub-net"
}
variable "prometheus-sub-net-ip-range" {
  default = "10.109.1.0/24"
}
variable "web-port" {
  type    = list
  default = ["0-65535"]
}
