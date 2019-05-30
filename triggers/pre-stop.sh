#!/bin/bash
set -e

echo "PRE-STOP BEGINNING --------"
echo

if [ "$(sudo docker ps -q | wc -l)" -ne "0" ]; then
	echo "Stopping Docker Containers:"
	sudo docker ps -q | xargs -L1 sudo docker stop
	echo
fi

echo "PRE-STOP ENDING -----------"

