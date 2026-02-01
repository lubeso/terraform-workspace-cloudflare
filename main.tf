resource "cloudflare_account" "main" {
  name = var.account_name
  type = "standard"
}

resource "cloudflare_zone" "main" {
  account = {
    id = cloudflare_account.main.id
  }
  name = var.zone_name
  type = "full"
}

resource "cloudflare_dns_record" "apex" {
  zone_id = cloudflare_zone.main.id
  name    = "@"
  ttl     = 1
  type    = "A"
  proxied = false
  content = var.ip_address
}

resource "cloudflare_dns_record" "subdomains" {
  for_each = {
    for subdomain in var.subdomains
    : subdomain => true
  }
  zone_id = cloudflare_zone.main.id
  name    = each.key
  ttl     = 1
  type    = "A"
  proxied = false
  content = var.ip_address
}

resource "cloudflare_dns_record" "icloud_mail_servers" {
  for_each = {
    for i in range(2)
    : format("%02d", i + 1) => true
  }
  zone_id  = cloudflare_zone.main.id
  name     = "@"
  ttl      = 3600
  type     = "MX"
  priority = 10
  content  = "mx${each.key}.mail.icloud.com"
}

import {
  to = cloudflare_dns_record.icloud_mail_servers["02"]
  id = "${cloudflare_zone.main.id}/${var.icloud_mail_server_dns_record_ids["02"]}"
}
