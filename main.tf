resource "cloudflare_account" "main" {
  name = var.account_name
  type = "standard"
}
