#!/bin/bash

# MD2PDF_DIR: if not provided, fallback to $(pwd)
: "${MD2PDF_DIR:=$(pwd)}"

echo "Watching for changes in $(pwd)/*.md"

fswatch -e ".*" -i "\\.md$" --event=Updated -r ./ | while read -r file; do
  # Skip if file was deleted
  if [[ -f "$file" && "$file" == *.md ]]; then
    filename="$(basename "$file")"
    echo "Detected change in $filename → Compiling ..."
    $MD2PDF_DIR/run/compile.sh "$file"
  fi
done