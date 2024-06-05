variable "name" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "min_size" {
  type = number
  default = 1
}

variable "max_size" {
  type = number
  default = 1
}

variable "desired_size" {
  type = number
  default = 1
}

variable "instance_types" {
  type = list(string)
}