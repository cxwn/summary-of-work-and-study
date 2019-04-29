#!/bin/bash
LANGUAGE=zh_CN.UTF-8
LANGPATH=/etc/locale.conf
T_LANG=$(echo $LANG)
echo "Current Environment:$LANG"
locale #Show the current system langguage and character set
if [ "$LANGUAGE" !=  "$T_LANG" ]; then
    echo "$LANGUAGE">$LANGPATH
    echo "Congratulations!Done!"
    elif [ "$LANGUAGE" = "$T_LANG" ]; then
    echo "Current system have been setup!"
else
    echo "Sorry! System ERROR"
fi
