#!/usr/bin/env bash
set -euo pipefail
echo "[occ] checking capacity..."
REGION="${OCI_REGION:-ap-singapore-1}"
TENANCY="${OCI_TENANCY:-}"
if [ -z "$TENANCY" ]; then
  echo "[occ] ERROR: OCI_TENANCY not set"; exit 1
fi
# placeholder for OCI CLI or SDK call
echo "[occ] region=$REGION tenancy=$TENANCY"
echo "[occ] next: integrate oci-java-sdk or oci-cli here"
