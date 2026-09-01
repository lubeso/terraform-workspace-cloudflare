terraform {
  required_version = "~> 1.16.0"

  required_providers {
    cloudflare = {
      source = "cloudflare/cloudflare"
      # Re-verification of the 5.19.0+ state-upgrade bug that previously forced
      # a cap at ~> 5.18.0 (see PR #1). If this speculative plan fails again with
      # "Failed to unmarshal v4 zone state: unsupported attribute \"account\"",
      # revert this constraint back to ~> 5.18.0.
      version = "~> 5.24.0"
    }
  }
}

provider "cloudflare" {
  # This block is purposely empty
}
