variable "account_name" {
  type = string
}

variable "icloud_mail_dkim_dns_record_id" {
  type = string
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

variable "icloud_mail_personal_domain" {
  type      = string
  sensitive = true
}
