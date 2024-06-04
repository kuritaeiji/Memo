variable "name" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "lister_ports" {
  type = list(number)
  default = [ 80, 443 ]
}

variable "server_port" {
  type = number
}

variable "server_vpc_id" {
  type = number
}