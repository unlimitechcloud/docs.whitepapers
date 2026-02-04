#!/bin/bash
# Sign a PDF using pyHanko with timestamp and update checksums (PUBLIC REPOSITORY)
# Usage: ./sign-pdf.sh <input.pdf> <output.pdf>
#
# This script is for the PUBLIC repository only.
# Always uses PUBLIC certificate (no confidentiality metadata).
#
# This script:
# 1. Signs the PDF with PUBLIC certificate
# 2. Uses timestamp server (CRITICAL for long-term validity)
# 3. Deletes the unsigned PDF after successful signing
# 4. Updates SHA256SUMS.txt in the releases folder
#
# Private keys are expected at: ~/.ssh/unlimitech-cloud/whitepapers/
# Timestamp server: http://freetsa.org/tsr (always used - CRITICAL)

set -e

INPUT="$1"
OUTPUT="$2"

if [ -z "$INPUT" ] || [ -z "$OUTPUT" ]; then
    echo "Usage: ./sign-pdf.sh <input.pdf> <output.pdf>"
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PUBLISH_DIR="$(dirname "$SCRIPT_DIR")"
PYHANKO_VENV="$HOME/.venv/pyhanko"
TIMESTAMP_URL="http://freetsa.org/tsr"

# Determine releases directory from output path
RELEASES_DIR="$(dirname "$OUTPUT")"

# Always use PUBLIC certificate
CERT_PATTERN="$PUBLISH_DIR/certificates/*-PUBLIC-*.crt"
KEY_DIR="$HOME/.ssh/unlimitech-cloud/whitepapers"

# Find the most recent certificate
CERT_FILE=$(ls -t $CERT_PATTERN 2>/dev/null | head -1)
if [ -z "$CERT_FILE" ]; then
    echo "Error: No PUBLIC certificate found matching pattern: $CERT_PATTERN"
    exit 1
fi

# Derive key filename from certificate
CERT_BASENAME=$(basename "$CERT_FILE" .crt)
KEY_FILE="$KEY_DIR/$CERT_BASENAME.key"

if [ ! -f "$KEY_FILE" ]; then
    echo "Error: Key file not found: $KEY_FILE"
    exit 1
fi

echo "Signing: $INPUT"
echo "  Certificate: $CERT_FILE"
echo "  Key: $KEY_FILE"
echo "  Scope: public"

# Sign the PDF (always public scope)
"$PYHANKO_VENV/bin/python" "$SCRIPT_DIR/sign-pdf.py" \
    "$INPUT" "$OUTPUT" "$CERT_FILE" "$KEY_FILE" "public" "$TIMESTAMP_URL"

# Delete unsigned PDF after successful signing
if [ -f "$OUTPUT" ]; then
    echo "Removing unsigned PDF: $INPUT"
    rm "$INPUT"
fi

# Update SHA256SUMS.txt in releases directory
CHECKSUMS_FILE="$RELEASES_DIR/SHA256SUMS.txt"
echo "Updating checksums: $CHECKSUMS_FILE"

# Generate checksums for all signed PDFs in releases
(
    for pdf in "$RELEASES_DIR"/*-signed.pdf; do
        if [ -f "$pdf" ]; then
            sha256sum "$pdf" | sed "s|$RELEASES_DIR/||"
        fi
    done
) | sort > "$CHECKSUMS_FILE"

echo "Done: $OUTPUT"
echo "Checksums updated: $CHECKSUMS_FILE"
