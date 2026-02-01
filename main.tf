resource "cloudflare_account" "main" {
  name = var.account_name
  type = "standard"
}

import {
  to = cloudflare_account.main
  id = var.account_id
}
