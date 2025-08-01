#!/bin/bash

echo "Watching for changes in ./in/*.md"

fswatch -e ".*" -i "\\.md$" -r ./in | while read -r file; do
  # Skip if file was deleted
  if [[ -f "$file" && "$file" == *.md ]]; then
    filename="$(basename "$file" .md)"
    echo "Detected change in $filename.md → Compiling ..."
    ./run/compile.sh "$filename"
  fi
done