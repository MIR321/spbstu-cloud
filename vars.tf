variable "AWS_ACCESS_KEY" {
}

variable "AWS_SECRET_KEY" {
}

variable "AWS_REGION" {
  default = "eu-west-1"
}

variable "AMI" {
  default = "ami-0943382e114f188e8"
}

variable "PATH_TO_PRIVATE_KEY" {
  default = "sshkey"
}

variable "PATH_TO_PUBLIC_KEY" {
  default = "sshkey.pub"
}

variable "INSTANCE_USERNAME" {
  default = "ubuntu"
}

variable "RDS_PASSWORD" {
}

