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

resource "cloudflare_dns_record" "icloud_mail_dkim" {
  zone_id = cloudflare_zone.main.id
  name    = "sig1._domainkey"
  ttl     = 3600
  type    = "CNAME"
  proxied = false
  content = "sig1.dkim.${cloudflare_zone.main.name}.at.icloudmailadmin.com"
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
  proxied  = false
  priority = 10
  content  = "mx${each.key}.mail.icloud.com"
}

resource "cloudflare_dns_record" "icloud_mail_personal" {
  zone_id = cloudflare_zone.main.id
  name    = "@"
  ttl     = 3600
  type    = "TXT"
  content = "\"apple-domain=${var.icloud_mail_personal_domain}\""
}

resource "cloudflare_dns_record" "icloud_mail_spoof_protection" {
  zone_id = cloudflare_zone.main.id
  name    = "@"
  ttl     = 3600
  type    = "TXT"
  content = "\"v=spf1 include:icloud.com ~all\""
}
