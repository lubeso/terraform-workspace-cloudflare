# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

Single-workspace Terraform configuration that manages one Cloudflare account, one zone, and its DNS records via the `cloudflare/cloudflare` provider (~> 5.16.0). This is not a reusable module — `main.tf` declares concrete resources directly (no module blocks, no multi-environment structure).

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
- `ip_address` — target A-record IP for the apex and all subdomains
- `subdomains` — list of subdomain names, each gets an A record pointed at `ip_address`
- `icloud_mail_personal_domain` — used in the iCloud custom-domain TXT verification record
- `ghost_domain` — CNAME target for the `blog` subdomain (Ghost(Pro) hosting)

Cloudflare API credentials are not passed as variables — the `cloudflare` provider block in `providers.tf` is intentionally empty and picks up auth from the provider's standard environment variables (e.g. `CLOUDFLARE_API_TOKEN`).

## Architecture notes

- `main.tf` provisions, in order: the account, the zone, an apex A record, a `for_each`-generated set of subdomain A records (all sharing `var.ip_address`), then a fixed set of DNS records for two external services layered onto the same zone:
  - **iCloud Mail custom domain**: DKIM CNAME, two MX records (`for_each` over a `range(2)` to produce `mx01`/`mx02`), a TXT apple-domain verification record, and an SPF TXT record.
  - **Ghost blog**: a `blog` CNAME pointing at `var.ghost_domain`.
- All DNS records use `proxied = false` (Cloudflare orange-cloud proxying is off everywhere) and record-specific TTLs (`1` = "auto" for the apex/subdomain A records, `3600` for the service records).
- When adding a new externally-hosted service (mail provider, blog platform, etc.), follow the existing pattern: add any new required values to `variables.tf`, then add the DNS record resource(s) to `main.tf` near the other service's records, keeping `proxied = false` unless there's a specific reason to enable proxying.
- `outputs.tf` is intentionally empty; add outputs there only when a value is actually needed downstream.
