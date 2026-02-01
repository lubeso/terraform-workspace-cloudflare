variable "account_name" {
  type = string
}

variable "dns_record_ids" {
  type = map(string)
}

variable "zone_name" {
  type = string
}

variable "ip_address" {
  type = string
}

variable "subdomains" {
  type = list(string)
}
