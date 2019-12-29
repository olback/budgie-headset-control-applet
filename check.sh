#!/bin/bash

/usr/local/bin/headsetcontrol -h >> /dev/null

if [ $? -ne 0 ]; then

    echo "-----------------------------------------------"
    echo ""
    echo "Make sure /usr/local/bin/headsetcontrol exists!"
    echo ""
    echo "-----------------------------------------------"

fi
