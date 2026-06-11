#!/bin/bash

# Golden-file test: compiles every example with --raw and compares the
# generated .tex/.typ output against the reference files in tests/golden/.
# Run with --update to (re)create the reference files after intended changes.
# Note: output may vary between pandoc versions.

MD2PDF_DIR="${MD2PDF_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
GOLDEN_DIR="$MD2PDF_DIR/tests/golden"

UPDATE=0
[[ "$1" == "--update" ]] && UPDATE=1

BOLD='\033[1m'
RESET='\033[0m'

mkdir -p "$GOLDEN_DIR"
TMP_DIR=$(mktemp -d)
trap 'rm -rf "$TMP_DIR"' EXIT

FAIL=0

for MD_FILE in "$MD2PDF_DIR"/examples/*.md; do
  NAME=$(basename "$MD_FILE" .md)
  rm -f "$MD2PDF_DIR/examples/$NAME".{tex,typ} # stale outputs from earlier runs

  if ! MD2PDF_DIR="$MD2PDF_DIR" "$MD2PDF_DIR/run/compile.sh" --raw "$MD_FILE" > /dev/null; then
    echo -e "❌ ${BOLD}$NAME${RESET}: compilation failed"
    FAIL=1
    continue
  fi

  OUT_FILE=$(ls "$MD2PDF_DIR/examples/$NAME".{tex,typ} 2>/dev/null | head -1)
  OUT_NAME=$(basename "$OUT_FILE")
  mv "$OUT_FILE" "$TMP_DIR/"

  if [[ "$UPDATE" == 1 ]]; then
    cp "$TMP_DIR/$OUT_NAME" "$GOLDEN_DIR/$OUT_NAME"
    echo -e "📝 ${BOLD}$OUT_NAME${RESET}: golden file updated"
  elif [[ ! -f "$GOLDEN_DIR/$OUT_NAME" ]]; then
    echo -e "❌ ${BOLD}$NAME${RESET}: missing golden file (run $0 --update)"
    FAIL=1
  elif diff -u "$GOLDEN_DIR/$OUT_NAME" "$TMP_DIR/$OUT_NAME"; then
    echo -e "✅ ${BOLD}$NAME${RESET}"
  else
    echo -e "❌ ${BOLD}$NAME${RESET}: output differs from golden file"
    FAIL=1
  fi
done

exit $FAIL
