#!/bin/bash
set -e

if [ -f "$HOME/.provisioning_lock" ]; then
	exit 0
fi

. /vagrant/provision/core.sh

if [ -f "/vagrant/provision/extra.sh" ]; then
	. /vagrant/provision/extra.sh
fi

touch "$HOME/.provisioning_lock"
