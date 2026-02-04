#!/usr/bin/env python3
"""Sign a PDF with pyHanko using PEM certificate and key.

Usage:
    sign-pdf.py <input.pdf> <output.pdf> <cert.crt> <key.key> <scope> [timestamp_url]
    
Arguments:
    input.pdf     - PDF file to sign
    output.pdf    - Output signed PDF file
    cert.crt      - Certificate file (PEM format)
    key.key       - Private key file (PEM format)
    scope         - 'private' or 'public' (affects signature metadata)
    timestamp_url - Timestamp server URL (default: http://freetsa.org/tsr)
    
Example:
    sign-pdf.py doc.pdf doc-signed.pdf cert.crt key.key public
"""

import sys
from pyhanko.sign import signers
from pyhanko.sign.timestamps import HTTPTimeStamper
from pyhanko.pdf_utils.incremental_writer import IncrementalPdfFileWriter

DEFAULT_TIMESTAMP_URL = "http://freetsa.org/tsr"
ALTERNATIVE_TIMESTAMP_URLS = [
    "http://timestamp.digicert.com",
    "http://time.certum.pl"
]

def sign_pdf(input_path: str, output_path: str, cert_path: str, key_path: str, 
             scope: str = "public", timestamp_url: str = None):
    """Sign a PDF file with timestamp (CRITICAL for long-term validity)."""
    
    # Timestamp is CRITICAL - always use it
    ts_url = timestamp_url or DEFAULT_TIMESTAMP_URL
    
    # Load the signer
    signer = signers.SimpleSigner.load(
        key_file=key_path,
        cert_file=cert_path,
        key_passphrase=None
    )
    
    # Setup timestamper (NEVER omit - ensures signature validity after cert expiration)
    timestamper = HTTPTimeStamper(ts_url)
    
    # Signature metadata based on scope
    if scope == "private":
        sig_metadata = signers.PdfSignatureMetadata(
            field_name='Sig1',
            md_algorithm='sha256',
            reason="CONFIDENTIAL DOCUMENT - Unauthorized distribution prohibited. Report breaches to admin@unlimitech.cloud",
            location="Internal Repository"
        )
    else:
        sig_metadata = signers.PdfSignatureMetadata(
            field_name='Sig1',
            md_algorithm='sha256',
        )
    
    # Open the PDF and sign
    with open(input_path, 'rb') as inf:
        w = IncrementalPdfFileWriter(inf)
        
        out = signers.sign_pdf(
            w,
            sig_metadata,
            signer=signer,
            timestamper=timestamper,
        )
        
        # Write output
        with open(output_path, 'wb') as outf:
            outf.write(out.getbuffer())
    
    print(f"Signed: {output_path}")
    print(f"  Timestamp: {ts_url}")
    print(f"  Scope: {scope}")

if __name__ == "__main__":
    if len(sys.argv) < 6:
        print(__doc__)
        sys.exit(1)
    
    input_pdf = sys.argv[1]
    output_pdf = sys.argv[2]
    cert_file = sys.argv[3]
    key_file = sys.argv[4]
    scope = sys.argv[5]
    ts_url = sys.argv[6] if len(sys.argv) > 6 else None
    
    sign_pdf(input_pdf, output_pdf, cert_file, key_file, scope, ts_url)
