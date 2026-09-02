# terraform-workspace-cloudflare

Single-workspace Terraform configuration that manages one Cloudflare account, one zone, and its DNS records via the `cloudflare/cloudflare` provider (~> 5.24.0). This is not a reusable module — `main.tf` declares concrete resources directly.

## What it manages

- The Cloudflare account and zone
- Zone-wide `ssl` (Full strict) and `always_use_https` settings
- Zone-wide (global) authenticated origin pulls, so Cloudflare presents its shared client certificate to the origin on every request
- An apex `A` record and a wildcard `A` record (`*`) covering all subdomains, both pointing at the same IP address (a GCP global external Application Load Balancer, HTTPS-only, that routes each hostname to its backend)
- DNS records for iCloud Mail custom domain (DKIM CNAME, two MX records, apple-domain TXT verification, SPF TXT)
- A CNAME proving domain control for a Google Cloud Certificate Manager DNS authorization (covers the apex and its wildcard certificate map entry)

The apex and wildcard `A` records are proxied (`proxied = true`), so Cloudflare's edge enforces the `ssl`/`always_use_https` settings for them. Every other record is unproxied (`proxied = false`) — mail and domain-validation records need to resolve directly, not through Cloudflare.

## Requirements

- Terraform ~> 1.16.0 (see `.terraform-version`)
- A Cloudflare API token, provided via the provider's standard environment variables (e.g. `CLOUDFLARE_API_TOKEN`) — not as a Terraform variable

## Usage

```bash
terraform init
terraform fmt -recursive
terraform validate
terraform plan
terraform apply
```

Pre-commit hooks (`.pre-commit-config.yaml`) run `terraform_fmt`, `terraform_providers_lock`, and `terraform_validate` automatically, plus generic hygiene checks. Install with `pre-commit install`, or run on demand with `pre-commit run --all-files`.

## Required variables

Supply these via a gitignored `.tfvars` file or environment variables:

| Variable | Description |
| --- | --- |
| `account_name` | Cloudflare account name |
| `zone_name` | Cloudflare zone name |
| `ip_address` | Target A-record IP for the apex and wildcard |
| `icloud_mail_personal_domain` | Used in the iCloud custom-domain TXT verification record |
| `gcp_dns_authorization_record_name` | CNAME name for GCP Certificate Manager's DNS authorization |
| `gcp_dns_authorization_record_data` | CNAME target for GCP Certificate Manager's DNS authorization |

`gcp_dns_authorization_record_name`/`_data` come from a GCP-side `google_certificate_manager_dns_authorization` resource's `dns_resource_record[0].name` / `[0].data` outputs (managed outside this repo). Those outputs include a trailing period; strip it before assigning — both variables reject a trailing period since Cloudflare's API doesn't store one. One authorization on the apex domain covers both the apex and its wildcard certificate map entry, so only one record is needed.

See `CLAUDE.md` for more detailed architecture notes.
