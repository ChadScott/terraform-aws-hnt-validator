variable "output_keys" {
  type = bool

  default = false
}

variable "ssh_allowlist" {
  type = list(string)

  default = []
}

variable "validator_ami" {
  type = string

  default = ""
}

variable "validator_autorecover" {
  type = bool

  default = true
}

variable "validator_ebs_snapshot" {
  type = string

  default = ""
}

variable "validator_instance_type" {
  default = "t3.large"
}

variable "validator_monitoring" {
  type = bool

  default = false
}

variable "validator_snapshot_retention" {
  type = number

  default = 7
}

variable "validator_subnet" {
  type = string
}

variable "validator_tags" {
  type = map(any)

  default = {}
}

variable "validator_volume_size" {
  type = number

  default = 256
}
