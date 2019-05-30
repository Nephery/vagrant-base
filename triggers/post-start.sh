#!/bin/bash
set -e

echo "POST-START BEGINNING --------"
echo

if [ "$(sudo docker ps -q -f "status=exited" | wc -l)" -ne "0" ]; then
	echo "Starting Docker Containers:"
	sudo docker ps -q -f "status=exited" | xargs -L1 sudo docker start
	echo

	echo "Waiting for containers to startup..."
	while [ "$(sudo docker ps -q -f 'health=starting' | wc -l)" -ne '0' ]; do : ; done
	echo "Containers are ready"
	echo
fi

echo "POST-START ENDING -----------"

