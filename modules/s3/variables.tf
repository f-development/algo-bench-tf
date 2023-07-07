variable "prefix" {

}

variable "bucket_name" {

}

variable "versioning" {
  default = false
}

variable "use_replication" {
  default = false
}

variable "replication_arns" {
  default = []
}

variable "enable_acl" {
  default = false
}