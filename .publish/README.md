# Whitepapers Publishing Guide

This folder contains operational metadata and guides for maintaining the whitepapers repository.

## Repository Structure

```
Whitepapers/
├── .publish/                           # Publishing operations (this folder)
│   ├── README.md                       # This guide
│   └── certificates/                   # Public signing certificates
│       └── Manuel-Antonio-Lara-Pupo-PUBLIC-2026-01-30.crt
│
└── [Whitepaper Name]/                  # Each whitepaper in its own folder
    ├── README.md                       # English index with current version
    ├── README-ES.md                    # Spanish index (if translated)
    ├── LICENSE.md                      # License and attribution
    ├── CHANGELOG.md                    # Version history (newest first)
    ├── src/                            # Source documents (Markdown)
    │   ├── [Whitepaper Name].md        # English source
    │   └── [Whitepaper Name]-ES.md     # Spanish source (if translated)
    └── releases/                       # Signed PDFs (versioned)
        ├── [Whitepaper Name]-v1.0.2-signed.pdf
        ├── [Whitepaper Name]-v1.0.2-ES-signed.pdf
        └── SHA256SUMS.txt              # Checksums for all versions
```

## Certificates

### Current Certificates

| File | Owner | Organization | Valid Until |
|------|-------|--------------|-------------|
| `Manuel-Antonio-Lara-Pupo-PUBLIC-2026-01-30.crt` | Manuel Antonio Lara Pupo | Unlimitech Cloud LLC | January 2036 |

### Certificate Location

- **Public certificate (.crt):** `.publish/certificates/` (in this repository)
- **Private key (.key):** Stored securely outside the repository (never committed)

### Certificate Renewal

When a certificate approaches expiration:

1. Generate a new certificate pair with date suffix
2. Add the new `.crt` to `.publish/certificates/`
3. Update this README with the new certificate info
4. Previously signed documents remain valid due to timestamps

---

## Publishing Workflow

### Prerequisites

1. **Private key** stored securely (not in this repository)
2. **Pandoc** and **pdflatex** installed
3. **pyHanko** installed in a virtual environment (`~/.venv/pyhanko/`)

### Step 1: Generate PDF from Markdown

```bash
cd [Whitepaper]/src

pandoc "[Whitepaper Name].md" -o "[Whitepaper Name].pdf" \
  --pdf-engine=pdflatex \
  -V geometry:margin=1in \
  -V fontsize=11pt \
  -V linkcolor=blue \
  -V urlcolor=blue \
  --toc \
  --toc-depth=4 \
  -V documentclass=report
```

### Step 2: Sign the PDF with Timestamp

```python
# Run with: ~/.venv/pyhanko/bin/python

from pyhanko.sign import signers, timestamps
from pyhanko.pdf_utils.incremental_writer import IncrementalPdfFileWriter

signer = signers.SimpleSigner.load(
    key_file="~/.ssh/unlimitech-cloud/whitepapers/Manuel-Antonio-Lara-Pupo-PUBLIC-2026-01-30.key",
    cert_file="../../.publish/certificates/Manuel-Antonio-Lara-Pupo-PUBLIC-2026-01-30.crt",
    key_passphrase=None
)

tst_client = timestamps.HTTPTimeStamper("http://freetsa.org/tsr")

with open("[Whitepaper Name].pdf", "rb") as inf:
    w = IncrementalPdfFileWriter(inf)
    out = signers.sign_pdf(
        w,
        signers.PdfSignatureMetadata(field_name="Signature"),
        signer=signer,
        timestamper=tst_client
    )
    with open("../releases/[Whitepaper Name]-v1.0.0-signed.pdf", "wb") as outf:
        outf.write(out.getbuffer())
```

Alternative TSA servers (free):
- `http://freetsa.org/tsr`
- `http://timestamp.digicert.com`
- `http://time.certum.pl`

### Step 3: Generate SHA256 Checksum

```bash
cd [Whitepaper]/releases
sha256sum *.pdf > SHA256SUMS.txt
```

### Step 4: Update Documentation

1. Update version in source `.md` files
2. Add entry to `CHANGELOG.md` (newest first)
3. Update `README.md` and `README-ES.md` with new version links

---

## Pre-Publish Consistency Checklist

Before publishing a new version, verify that all version references are synchronized:

### Version String Consistency

The version number (e.g., `v1.0.0`) must match in ALL of the following locations:

| Location | File | What to Check |
|----------|------|---------------|
| Source metadata | `src/[Name].md` | `**Version:** X.X.X` at document top |
| Source metadata | `src/[Name]-ES.md` | `**Versión:** X.X.X` at document top |
| Citation | `src/[Name].md` | Version in "How to cite" section |
| Citation | `src/[Name]-ES.md` | Version in "Cómo citar" section |
| Original Source link | `src/[Name].md` | URL contains `-vX.X.X-signed.pdf` |
| Original Source link | `src/[Name]-ES.md` | URL contains `-vX.X.X-ES-signed.pdf` |
| Whitepaper README | `README.md` | Version in download table |
| Whitepaper README | `README-ES.md` | Version in download table |
| PDF filename | `releases/` | `[Name]-vX.X.X-signed.pdf` |
| PDF filename | `releases/` | `[Name]-vX.X.X-ES-signed.pdf` |

### Date Consistency

The publication date must match in:

- Source document metadata (`**Published:**` / `**Publicado:**`)
- Citation sections in both languages
- CHANGELOG.md entry

### Original Source Links

Each source document must include an "Original Source" link at the very end pointing to the signed PDF in the repository:

**English:**
```markdown
**Original Source:** [Whitepaper-vX.X.X-signed.pdf](https://github.com/unlimitechcloud/docs.whitepapers/blob/master/[Whitepaper]/releases/[Whitepaper]-vX.X.X-signed.pdf)
```

**Spanish:**
```markdown
**Fuente Original:** [Whitepaper-vX.X.X-ES-signed.pdf](https://github.com/unlimitechcloud/docs.whitepapers/blob/master/[Whitepaper]/releases/[Whitepaper]-vX.X.X-ES-signed.pdf)
```

### Quick Verification Commands

```bash
# Check all version references in a whitepaper
grep -rn "v[0-9]\+\.[0-9]\+\.[0-9]\+" [Whitepaper]/

# Verify Original Source links match current version
grep -n "Original Source\|Fuente Original" [Whitepaper]/src/*.md
```

---

## Multi-Language Workflow

### File Naming Convention

| Language | Source File | Signed PDF |
|----------|-------------|------------|
| English (default) | `[Name].md` | `[Name]-v1.0.0-signed.pdf` |
| Spanish | `[Name]-ES.md` | `[Name]-v1.0.0-ES-signed.pdf` |
| Portuguese | `[Name]-PT.md` | `[Name]-v1.0.0-PT-signed.pdf` |

### Translation Guidelines

When translating, maintain these framework-specific terms in English:
- Intent, Intent Journal, Intent Tree
- Discovery, Proof of Concept (PoC), Refinement
- Intent Maturity Checkpoint (IMC), Intent Maturity Threshold (IMT)
- Distilled Capability, Distillation
- Progression Goals, Capability Velocity
- Emergent Roadmap
- Framework-specific acronyms (CDDD / C3D, etc.)

---

## Versioning

### Semantic Versioning

This repository follows [Semantic Versioning](https://semver.org/):

- **MAJOR (X.0.0):** Fundamental changes to the framework
- **MINOR (1.X.0):** New sections, significant additions
- **PATCH (1.0.X):** Corrections, clarifications, minor updates

### Version in Documents

Each source document includes version metadata at the top:

```markdown
# [Whitepaper Title]

**Version:** 1.0.0  
**Published:** January 30, 2026

## [Subtitle]
```

---

## Verification for Readers

Anyone can verify document authenticity:

1. Open the PDF in Adobe Reader or compatible viewer
2. Check the digital signature panel
3. Compare the signing certificate with the `.crt` file in `.publish/certificates/`
4. Verify the SHA256 checksum against `releases/SHA256SUMS.txt`

---

## Security Notes

- The private key (`*.key`) is **never** stored in this repository
- Only the public certificate (`*.crt`) is published here
- The timestamp proves the document was signed while the certificate was valid
- Any modification to a signed PDF invalidates the signature
- Only signed PDFs are kept in `releases/`; unsigned PDFs are not committed
