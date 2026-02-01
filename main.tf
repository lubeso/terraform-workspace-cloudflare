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

resource "cloudflare_dns_record" "main" {
  zone_id = cloudflare_zone.main.id
  name    = "@"
  ttl     = 1
  type    = "A"
  proxied = false
  content = var.ip_address
}

import {
  to = cloudflare_dns_record.main
  id = var.dns_record_id
}
