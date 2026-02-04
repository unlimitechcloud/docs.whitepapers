#!/bin/bash
# Generate PDF from Markdown whitepaper with proper formatting (PUBLIC REPOSITORY)
# Usage: ./generate-pdf.sh <input.md> <output.pdf> <lang: en|es>
#
# This script is for the PUBLIC repository only.
# No confidential watermark or notice is included.

set -e

INPUT="$1"
OUTPUT="$2"
LANG="${3:-en}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PUBLISH_DIR="$(dirname "$SCRIPT_DIR")"

# Export language for Lua filter
export NOTICE_LANG="$LANG"

# Build pandoc command
PANDOC_CMD="pandoc"
PANDOC_CMD="$PANDOC_CMD --lua-filter $PUBLISH_DIR/filters/build-date-field.lua"
PANDOC_CMD="$PANDOC_CMD -F mermaid-filter -M mermaid-filter-width=400"
PANDOC_CMD="$PANDOC_CMD --lua-filter $PUBLISH_DIR/filters/remove-confidential-notice.lua"
PANDOC_CMD="$PANDOC_CMD --lua-filter $PUBLISH_DIR/filters/scale-mermaid-images.lua"

PANDOC_CMD="$PANDOC_CMD --pdf-engine=xelatex"
PANDOC_CMD="$PANDOC_CMD -H $PUBLISH_DIR/templates/center-images.tex"
PANDOC_CMD="$PANDOC_CMD -H $PUBLISH_DIR/templates/blockquote-style.tex"
PANDOC_CMD="$PANDOC_CMD -H $PUBLISH_DIR/templates/title-page.tex"
PANDOC_CMD="$PANDOC_CMD -V colorlinks=true"
PANDOC_CMD="$PANDOC_CMD -V linkcolor=blue"
PANDOC_CMD="$PANDOC_CMD -V urlcolor=blue"
PANDOC_CMD="$PANDOC_CMD -V geometry:margin=1in"
PANDOC_CMD="$PANDOC_CMD -V fontsize=11pt"
PANDOC_CMD="$PANDOC_CMD -V mainfont='DejaVu Sans'"
PANDOC_CMD="$PANDOC_CMD -V monofont='DejaVu Sans Mono'"
PANDOC_CMD="$PANDOC_CMD --toc"
PANDOC_CMD="$PANDOC_CMD --toc-depth=4"
PANDOC_CMD="$PANDOC_CMD -H $PUBLISH_DIR/templates/toc-pagebreak.tex"

PANDOC_CMD="$PANDOC_CMD -o '$OUTPUT'"
PANDOC_CMD="$PANDOC_CMD '$INPUT'"

echo "Generating: $OUTPUT"
eval $PANDOC_CMD
echo "Done: $OUTPUT"
