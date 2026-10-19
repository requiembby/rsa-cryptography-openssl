#!/usr/bin/env bash
set -euo pipefail

# Reproducible educational demo: generate temporary RSA keys, encrypt and
# decrypt a short message, sign it, and check that tampering is detected.
# No private key, ciphertext, or signature is stored in the repository.

if ! command -v openssl >/dev/null 2>&1; then
  echo "OpenSSL is required. Install OpenSSL 3.x and try again." >&2
  exit 1
fi

umask 077
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd -- "$SCRIPT_DIR/.." && pwd)"
WORKDIR="$(mktemp -d "${TMPDIR:-/tmp}/rsa-portfolio.XXXXXX")"
trap 'rm -rf -- "$WORKDIR"' EXIT

printf '\n[1/5] Generate a temporary 3072-bit RSA key pair\n'
openssl genpkey -algorithm RSA -pkeyopt rsa_keygen_bits:3072 \
  -out "$WORKDIR/private.pem" >/dev/null 2>&1
openssl pkey -in "$WORKDIR/private.pem" -pubout \
  -out "$WORKDIR/public.pem" >/dev/null

cp -- "$PROJECT_DIR/examples/message.txt" "$WORKDIR/message.txt"
printf '[2/5] Encrypt the sample text using RSA-OAEP (SHA-256)\n'
openssl pkeyutl -encrypt -pubin -inkey "$WORKDIR/public.pem" \
  -in "$WORKDIR/message.txt" -out "$WORKDIR/encrypted.bin" \
  -pkeyopt rsa_padding_mode:oaep \
  -pkeyopt rsa_oaep_md:sha256 \
  -pkeyopt rsa_mgf1_md:sha256

printf '[3/5] Decrypt using the private key and compare plaintexts\n'
openssl pkeyutl -decrypt -inkey "$WORKDIR/private.pem" \
  -in "$WORKDIR/encrypted.bin" -out "$WORKDIR/decrypted.txt" \
  -pkeyopt rsa_padding_mode:oaep \
  -pkeyopt rsa_oaep_md:sha256 \
  -pkeyopt rsa_mgf1_md:sha256
cmp -- "$WORKDIR/message.txt" "$WORKDIR/decrypted.txt"
echo 'PASS: decrypted text matches the original.'

printf '[4/5] Sign with RSA-PSS / SHA-256 and verify with public key\n'
openssl dgst -sha256 -sign "$WORKDIR/private.pem" \
  -sigopt rsa_padding_mode:pss -sigopt rsa_pss_saltlen:-1 \
  -out "$WORKDIR/signature.bin" "$WORKDIR/message.txt"
openssl dgst -sha256 -verify "$WORKDIR/public.pem" \
  -sigopt rsa_padding_mode:pss -sigopt rsa_pss_saltlen:-1 \
  -signature "$WORKDIR/signature.bin" "$WORKDIR/message.txt"

printf '[5/5] Verify that changing the message invalidates the signature\n'
printf '\nCHANGED BY AN ATTACKER\n' >> "$WORKDIR/message.txt"
if openssl dgst -sha256 -verify "$WORKDIR/public.pem" \
  -sigopt rsa_padding_mode:pss -sigopt rsa_pss_saltlen:-1 \
  -signature "$WORKDIR/signature.bin" "$WORKDIR/message.txt" >/dev/null 2>&1; then
  echo 'FAIL: unexpectedly accepted a modified message.' >&2
  exit 1
fi
echo 'PASS: signature verification rejects the modified message.'
printf '\nDemo complete. Temporary key material will be deleted on exit.\n'
