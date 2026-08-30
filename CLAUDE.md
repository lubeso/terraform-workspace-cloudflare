# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

Single-workspace Terraform configuration that manages one Cloudflare account, one zone, and its DNS records via the `cloudflare/cloudflare` provider (~> 5.24.0). This is not a reusable module — `main.tf` declares concrete resources directly (no module blocks, no multi-environment structure).

## Commands

```bash
terraform init      # also runs via pre-commit's terraform_providers_lock hook
terraform fmt        -recursive
terraform validate
terraform plan
terraform apply
```

Pre-commit hooks (`.pre-commit-config.yaml`) run `terraform_fmt`, `terraform_providers_lock`, and `terraform_validate` automatically, plus generic hygiene hooks (large-file check, YAML check, end-of-file-fixer, trailing-whitespace). Install with `pre-commit install` if not already active; run all hooks on demand with `pre-commit run --all-files`.

There is no test suite — `terraform validate` and `terraform plan` are the correctness checks.

## Required input variables

Defined in `variables.tf` with no defaults; must be supplied via `.tfvars` (gitignored) or environment when planning/applying:

- `account_name`, `zone_name` — Cloudflare account/zone identity
- `ip_address` — target A-record IP for the apex and wildcard
- `icloud_mail_personal_domain` — used in the iCloud custom-domain TXT verification record
- `gcp_dns_authorization_record_name`, `gcp_dns_authorization_record_data` — CNAME name/target for GCP Certificate Manager's DNS authorization, sourced from a GCP-side `google_certificate_manager_dns_authorization` resource's `dns_resource_record[0].name` / `[0].data` outputs (managed outside this repo). Those GCP outputs include a trailing period; strip it before assigning — both variables have a validation block that rejects a trailing period, since Cloudflare's API doesn't store one and would otherwise cause a perpetual plan diff. One authorization on the apex domain covers both the apex and its wildcard certificate map entry, so only one record is needed here — don't add a second one for the wildcard.

Cloudflare API credentials are not passed as variables — the `cloudflare` provider block in `providers.tf` is intentionally empty and picks up auth from the provider's standard environment variables (e.g. `CLOUDFLARE_API_TOKEN`).

## Architecture notes

- `main.tf` provisions, in order: the account, the zone, an apex A record, a wildcard A record covering all subdomains (both sharing `var.ip_address`), then a fixed set of DNS records for two external services layered onto the same zone:
  - **iCloud Mail custom domain**: DKIM CNAME, two MX records (`for_each` over a `range(2)` to produce `mx01`/`mx02`), a TXT apple-domain verification record, and an SPF TXT record.
  - **GCP Certificate Manager DNS authorization**: a single CNAME (name/target supplied via variables) proving domain control for a Google-managed certificate map covering the apex and its wildcard.
- All DNS records use `proxied = false` (Cloudflare orange-cloud proxying is off everywhere) and record-specific TTLs (`1` = "auto" for the apex/wildcard A records, `3600` for the service records).
- When adding a new externally-hosted service (mail provider, blog platform, etc.), follow the existing pattern: add any new required values to `variables.tf`, then add the DNS record resource(s) to `main.tf` near the other service's records, keeping `proxied = false` unless there's a specific reason to enable proxying.
- `outputs.tf` is intentionally empty; add outputs there only when a value is actually needed downstream.
