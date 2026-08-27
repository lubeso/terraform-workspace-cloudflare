variable "account_name" {
  type = string
}

variable "zone_name" {
  type = string
}

variable "ip_address" {
  type = string
}

variable "icloud_mail_personal_domain" {
  type = string
}

variable "ghost_domain" {
  type = string
}

variable "gcp_dns_authorization_record_name" {
  type = string
  validation {
    condition     = !endswith(var.gcp_dns_authorization_record_name, ".")
    error_message = "must not have a trailing period; strip it from the GCP dns_resource_record output before assigning."
  }
}

variable "gcp_dns_authorization_record_data" {
  type = string
  validation {
    condition     = !endswith(var.gcp_dns_authorization_record_data, ".")
    error_message = "must not have a trailing period; strip it from the GCP dns_resource_record output before assigning."
  }
}
