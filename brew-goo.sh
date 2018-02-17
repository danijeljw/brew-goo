#!/usr/bin/env bash
# -*- coding: utf-8 -*-
# Copyright (c) 2017-2018 Danijel-James Wynyard
# All Rights Reserved.
#
#   Permission is hereby granted, free of charge, to any person obtaining a copy
#   of this software and associated documentation files (the "Software"), to deal
#   in the Software without restriction, including without limitation the rights
#   to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
#   copies of the Software, and to permit persons to whom the Software is
#   furnished to do so, subject to the following conditions:
#
#   The above copyright notice and this permission notice shall be included in all
#   copies or substantial portions of the Software.
#
#   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#   IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#   FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#   AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#   LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#   OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
#   SOFTWARE.

currentVersion="0.1.1"

LIGHTBLUE='033[1;34m' # Light Blue text colour
RED='\033[0;31m'      # Red text colour
NC='\033[0m'          # No text colour


comeondialog()
{
    if command -v dialog>/dev/null 2>&1; then
        call_Dialog
    else
        printf "Requires ${LIGHTBLUE}dialog${NC}, but it's not installed.\nPlease install via ${RED}'brew install dialog'${NC}"
        return 0
    fi
}

callDialog()
{
: ${DIALOG=dialog}
: ${DIALOG_OK=0}
: ${DIALOG_CANCEL=1}
: ${DIALOG_ESC=255}

# Create a temporary file, delete when completed
tmp_file=$(tempfile 2>/dev/null) || tmp_file=/tmp/test$$
trap "rm -f $tmp_file" 0 1 2 5 15


$DIALOG --backtitle "brew goo v${currentVersion}" \
        --title "CHOICES" \
        --checklist \
"Hi, this is a checklist box. You can use this to \n\
present a list of choices which can be turned on or \n\
off. If there are more items than can fit on the \n\
screen, the list will be scrolled. You can use the \n\
UP/DOWN arrow keys, the first letter of the choice as a \n\
hot key, or the number keys 1-9 to choose an option. \n\
Press SPACE to toggle an option on/off. \n\n\
Which of the following are fruits?" 20 61 5 \
        "Apple"  "It's an apple." off \
        "Dog"    "No, that's not my dog." ON \
        "Orange" "Yeah, that's juicy." off \
        "Chicken"    "Normally not a pet." off \
        "Cat"    "No, never put a dog and a cat together!" oN \
        "Fish"   "Cats like fish." On \
        "Lemon"  "You know how it tastes." on 2> $tempfile

retval=$?

choice=`cat $tempfile`
case $retval in
  $DIALOG_OK)
    echo "'$choice' chosen.";;
  $DIALOG_CANCEL)
    echo "Cancel pressed.";;
  $DIALOG_ESC)
    echo "ESC pressed.";;
  *)
    echo "Unexpected return code: $retval (ok would be $DIALOG_OK)";;
esac
}


# Function to print HELP menu
help () {
    cat <<EOF

    USAGE: brew-goo [-h|--help] [-l|--list] TEXT
EOF
    if [[ 'list' == $1 ]]; then
        echo 'Supported one line commands:'
        for key in ${!emojis[@]}; do
            echo -e "$key ${emojis[$key]}"
        done
    fi
    exit 0
}

# Checks the installed bash version to see if it's compatible with emojify
check_version () {
    if (( ${BASH_VERSION%%.*} >= 4 )); then
        return
    else
        echo -e "Oh my! That’s a very old version of bash you’re using, we don’t support that anymore :(\n" \
        "\nConsider upgrading it or, if you must use bash ${BASH_VERSION} download an old version of" \
        "brew-goo from here: https://github.com/danijeljw/brew-goo/blob/------press-y-on-file-required"
        exit 0
    fi
}

# If arguments are provided on the command line then check for supported help
if [[ -n $1 ]]; then
    case $1 in
    '-h' | '--help' )
        help
        ;;

    * )
        check_version
        parse_line "$*"
        ;;
    esac
else
    check_version
    while IFS=''; read -r line || [ -n "$line" ]; do
        parse_line "$line"
    done
fi
