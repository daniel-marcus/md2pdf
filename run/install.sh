#!/bin/bash

set -e

SCRIPT_FILE="$HOME/.local/bin/mdtex"

echo -e "Creating ${SCRIPT_FILE} ..."
echo

touch $SCRIPT_FILE
chmod u+x $SCRIPT_FILE

cat > $SCRIPT_FILE << EOM
#/bin/bash

MDTEX_DIR=$(pwd)
export MDTEX_DIR

if [ -z "\$1" ]; then
  \$MDTEX_DIR/run/watch.sh
else 
  \$MDTEX_DIR/run/compile.sh "\$1"
fi
EOM

BOLD='\033[1m'
RESET='\033[0m'

echo "Installation successful! 🎉"
echo -e "You can now run ${BOLD}mdtex${RESET} to start the watch mode (recompile on .md changes),"
echo -e "or ${BOLD}mdtex yourfile.md${RESET} to compile a file manually."
echo
echo "Make sure that ~/.local/bin/ is in your PATH to run the command globally."