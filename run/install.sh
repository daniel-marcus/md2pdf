#!/bin/bash

set -e

SCRIPT_FILE="$HOME/.local/bin/md2pdf"

echo -e "Creating ${SCRIPT_FILE} ..."
echo

mkdir -p "$(dirname "$SCRIPT_FILE")"   # Create directory if not exists
touch $SCRIPT_FILE
chmod u+x $SCRIPT_FILE

cat > $SCRIPT_FILE << EOM
#/bin/bash

MD2PDF_DIR=$(pwd)
export MD2PDF_DIR

if [ -z "\$1" ]; then
  \$MD2PDF_DIR/run/watch.sh
else 
  \$MD2PDF_DIR/run/compile.sh "\$@"
fi
EOM

BOLD='\033[1m'
RESET='\033[0m'

echo "Installation successful! 🎉"
echo -e "You can now run ${BOLD}md2pdf${RESET} to start the watch mode (recompile on .md changes),"
echo -e "or ${BOLD}md2pdf yourfile.md${RESET} to compile a file manually."
echo
echo "Make sure that $(dirname "$SCRIPT_FILE") is in your PATH to run the command globally."