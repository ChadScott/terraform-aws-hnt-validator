variable "output_keys" {
  type    = bool
  default = false
}

variable "validator_count" {
  default = 1
}

variable "validator_instance_type" {
  default = "m5.large"
}

variable "validator_subnets" {
  type = list(string)
}

variable "validator_tags" {
  type    = map(any)
  default = {}
}

variable "validator_volume_size" {
  type    = number
  default = 64
}
