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

import {
  to = cloudflare_zone.main
  id = var.zone_id
}
