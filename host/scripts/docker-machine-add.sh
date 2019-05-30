#!/bin/bash
set -e

scriptpath="$( cd "$(dirname "$0")" ; pwd -P )"
machine_alias="$1"

if [ -z "$machine_alias" ]; then
	>&2 echo "No machine alias was provided"
	>&2 echo
	exit 1
fi

vagrantfile_path="$scriptpath/../../"
ip="$(cd "$vagrantfile_path" && vagrant status | grep -oE 'private_net_ip"=>"[^"]+' | sed -n 's/\S*"\(\S*\)/\1/p')"
existing_machines="$(docker-machine ls | tail -n +2)"

if [ -n "$(echo "$existing_machines" | awk '{print $1}' | grep "^${machine_alias}$")" ]; then
	>&2 echo "Docker-machine alias $machine_alias is already in use"
	>&2 echo
	exit 1
fi

if [ -n "$(echo "$existing_machines" | awk '{print $5}' | grep -w "${ip}")" ]; then
	>&2 echo "Docker-machine IP $ip has already been registered"
	>&2 echo
	exit 1
fi

echo
echo "Will add docker-machine $machine_alias for IP $ip"

echo
echo "Running this script will restart all running containers. Do you wish to proceed?"
select yn in "Yes" "No"; do
	case $yn in
		Yes ) break;;
		No ) exit;;
	esac
done

key_file="$(cd "$vagrantfile_path" && vagrant ssh-config | grep -w IdentityFile | awk '{print $2}')"

echo
echo "Detected IdentityFile $key_file"
docker-machine.exe create --driver generic --generic-ip-address "$ip" --generic-ssh-user "vagrant" --generic-ssh-key="$key_file" "$machine_alias"

eval "$(docker-machine env "$machine_alias")"

if [ "$(docker ps -q -f 'status=exited' | wc -l)" -ne '0' ]; then
	echo
	echo "Starting Docker Containers:"
	docker ps -q -f 'status=exited' | xargs -L1 docker start

	echo
	echo "Waiting for containers to startup..."
	while [ "$(docker ps -q -f 'health=starting' | wc -l)" -ne '0' ]; do : ; done
	echo "Containers are ready"
fi

