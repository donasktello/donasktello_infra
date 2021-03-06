variable zone {
  description = "Zone"
  default     = "europe-west1-b"
}

variable "count" {
  description = "Number of instances"
  default     = 1
}

variable public_key_path {
  description = "Path to the public key used for ssh access"
}

variable private_key_path {
  description = "Path to the private key used for ssh access"
}

variable db_disk_image {
  description = "Disk image for reddit app"
  default     = "reddit-db-base"
}

//variable "mongod_addr" {
//  description = "MongoDB address"
//  default     = "0.0.0.0"
//}
//
//variable "mongod_port" {
//  description = "MongoDB port"
//  default     = "27017"
//}
#TODO uncomment this block to return terraform with provisioners