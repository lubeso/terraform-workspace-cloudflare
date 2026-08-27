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

resource "cloudflare_dns_record" "wildcard" {
  # Temporary: coexists with cloudflare_dns_record.subdomains until wildcard
  # resolution is validated in production, then the per-subdomain resource
  # (and var.subdomains) will be removed in a follow-up change.
  zone_id = cloudflare_zone.main.id
  name    = "*"
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

resource "cloudflare_dns_record" "icloud_mail_personal_domain" {
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

resource "cloudflare_dns_record" "ghost_blog" {
  zone_id = cloudflare_zone.main.id
  name    = "blog"
  ttl     = 3600
  type    = "CNAME"
  proxied = false
  content = var.ghost_domain
}

resource "cloudflare_dns_record" "gcp_certificate_manager_dns_authorization" {
  zone_id = cloudflare_zone.main.id
  name    = var.gcp_dns_authorization_record_name
  ttl     = 3600
  type    = "CNAME"
  proxied = false
  content = var.gcp_dns_authorization_record_data
}
