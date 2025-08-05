#!/bin/bash

set -e

# MD2PDF_DIR: if not provided, fallback to $(pwd)
: "${MD2PDF_DIR:=$(pwd)}"

# Check if an arg was provided
if [ -z "$1" ]; then
  echo "Usage: $0 [--raw] FILENAME.md"
  exit 1
fi

RAW=0
FILE_ARG=""

# Parse args
while [[ $# -gt 0 ]]; do
  case "$1" in
    --raw)
      RAW=1
      shift
      ;;
    *)
      if [[ -z "$FILE_ARG" ]]; then
        FILE_ARG="$1"
      fi
      shift
      ;;
  esac
done

MD_FILE=$(realpath "$FILE_ARG")
FILENAME=$(basename "$MD_FILE" .md)
CWD=$(dirname "$MD_FILE")

cd "$CWD"

# Extract the 'template' value from the YAML header or use DEFAULT_TEMPLATE
DEFAULT_TEMPLATE_FILENAME="letter.tex"
TEMPLATE_FILENAME=$(awk '
  BEGIN { in_yaml = 0 }
  /^---/ { in_yaml = !in_yaml; next }
  in_yaml && /^template:/ {
    sub(/^template:[[:space:]]*/, "", $0)
    print $0
    exit
  }
' "$MD_FILE")
TEMPLATE_FILENAME=${TEMPLATE_FILENAME:-$DEFAULT_TEMPLATE_FILENAME}
TEMPLATE_NAME="${TEMPLATE_FILENAME%.*}"
TEMPLATE_EXTENSION="${TEMPLATE_FILENAME##*.}"

TEMPLATE_FILE="$MD2PDF_DIR/templates/$TEMPLATE_FILENAME"
FILTER_FILE="$MD2PDF_DIR/templates/$TEMPLATE_NAME.lua"

if [ ! -e "$TEMPLATE_FILE" ]; then
  echo "❌ Error: Template $TEMPLATE_FILE not found"
  exit 1
fi

TEMPLATE_FILTER_ARG=$([[ -e "$FILTER_FILE" ]] && echo "--lua-filter=$FILTER_FILE")

HEADER_FILE="$MD2PDF_DIR/templates/_shared.$TEMPLATE_EXTENSION"
HEADER_ARG=$([[ -e "$HEADER_FILE" ]] && echo "--include-in-header=$HEADER_FILE")

EXAMPLE_CONFIG_FILE="$MD2PDF_DIR/config.example.yaml"
USER_CONFIG_FILE="$MD2PDF_DIR/config.yaml"

if [[ ! -f $USER_CONFIG_FILE ]]; then
  echo "config.yaml not found. Creating from config.example.yaml ..."
  cp $EXAMPLE_CONFIG_FILE $USER_CONFIG_FILE
fi

CONFIG_FILE=$([[ "$CWD" == "$MD2PDF_DIR/examples" ]] && echo "$EXAMPLE_CONFIG_FILE" || echo "$USER_CONFIG_FILE")

PDF_ENGINE=$([ "$TEMPLATE_EXTENSION" = "typ" ] && echo "typst" || echo "xelatex")

OUT_EXTENSION=$([[ "$RAW" == 1 ]] && echo "$TEMPLATE_EXTENSION" || echo "pdf")
OUT_FILE="$FILENAME.$OUT_EXTENSION"

if ! pandoc "$MD_FILE" \
  --pdf-engine="$PDF_ENGINE" \
  --metadata-file="$CONFIG_FILE" \
  --template="$TEMPLATE_FILE" \
  --lua-filter="$MD2PDF_DIR/templates/_shared.lua" \
  $TEMPLATE_FILTER_ARG \
  $HEADER_ARG \
  -s -o "$OUT_FILE"; then
  echo "❌ Error: pandoc failed"
  exit 1
else 
  BOLD='\033[1m'
  RESET='\033[0m'
  echo -e "✅ Compiled ${BOLD}$OUT_FILE${RESET} using ${PDF_ENGINE}"
fi