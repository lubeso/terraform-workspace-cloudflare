terraform {
  required_version = "~> 1.16.0"

  required_providers {
    cloudflare = {
      source = "cloudflare/cloudflare"
      # Capped below 5.19.0: that release changed the SDKv2->Plugin
      # Framework state-upgrade handlers for cloudflare_zone/cloudflare_dns_record,
      # and every 5.19.0+ release (through 5.24.0, the latest as of writing)
      # fails to plan against this workspace's existing state with
      # "Failed to unmarshal v4 zone state: unsupported attribute \"account\"".
      # Confirmed via bisection across speculative plans; see
      # https://github.com/cloudflare/terraform-provider-cloudflare/issues/5169
      # and https://github.com/cloudflare/terraform-provider-cloudflare/issues/4982.
      # Re-test before raising this constraint.
      version = "~> 5.18.0"
    }
  }
}

provider "cloudflare" {
  # This block is purposely empty
}
