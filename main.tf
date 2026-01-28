data "cloudflare_account" "main" {
  account_id = var.account_id
}

data "cloudflare_zone" "main" {
  zone_id = var.zone_id
}

data "cloudflare_dns_record" "main" {
  zone_id       = data.cloudflare_zone.main.id
  dns_record_id = var.dns_record_id
}
