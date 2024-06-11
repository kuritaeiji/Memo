variable "name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "ingress_port" {
  type = number
}

variable "ingress_protocol" {
  type = string
  default = "-1"
}

variable "ingress_cidr_blocks" {
  type = list(string)
  default = [ "0.0.0.0/0" ]
}