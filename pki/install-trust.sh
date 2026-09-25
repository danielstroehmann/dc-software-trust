#!/bin/bash
# Install all Root and Intermediate CA certificates from pki/root and pki/ica into the OS and Java trust stores on Ubuntu 24.04.
# On Ubuntu, ca-certificates-java automatically syncs the Java trust store
# during update-ca-certificates — no separate keytool step needed.
# Run as root: sudo ./install-trust.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OS_CERT_DIR="/usr/local/share/ca-certificates"

die() { echo "ERROR: $*" >&2; exit 1; }

[[ $EUID -eq 0 ]] || die "Run as root: sudo $0"

echo "==> Installing into OS trust store ($OS_CERT_DIR)..."

for pem in "$SCRIPT_DIR"/root/*.pem "$SCRIPT_DIR"/ica/*.pem; do
    name=$(basename "$pem" .pem)
    name=${name// /_}
    cp "$pem" "$OS_CERT_DIR/${name}.crt"
    echo "    + ${name}.crt"
done

update-ca-certificates
echo "Done."
