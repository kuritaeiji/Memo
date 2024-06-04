variable "cluster_name" {
  type = string
}

variable "ami" {
  type = string
}

variable "instance_type" {
  type = string
  default = "t2.micro"
}

variable "server_port" {
  type = number
  default = 8080
}

variable "user_data" {
  type = string
  default = null
}

variable "subnet_ids" {
  type = list(string)
}

variable "associate_public_ip_address" {
  type = bool
  default = false
}

variable "target_group_arns" {
  type = list(string)
  default = []
}

variable "health_chek_type" {
  type = string
  default = "ELB"
}

variable "min_size" {
  type = number
  default = 1
}

variable "max_size" {
  type = number
  default = 1
}

variable "custom_tags" {
  type = map(string)
  default = {}
}
