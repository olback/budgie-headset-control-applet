#!/bin/bash

/usr/local/bin/headsetcontrol -h >> /dev/null

if [ $? -ne 0 ]; then

    echo "Install sucessful but command headsetcontrol was not found"
    echo "Make sure /usr/local/bin/headsetcontrol exists!"

fi

