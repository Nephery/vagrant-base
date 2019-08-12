#!/bin/bash

NPM_MODULES="$HOME/npm_modules"
LN_NODE_MODULES="$PWD/node_modules"
RL_NODE_MODULES="$NPM_MODULES/${PWD#${HOME}/}/node_modules"

if [ ! -d $NPM_MODULES ]; then
	echo "Creating $NPM_MODULES"
	mkdir $NPM_MODULES
fi

if [ ! -d "$RL_NODE_MODULES" ]; then	
	echo "Creating $RL_NODE_MODULES"
	mkdir -p $RL_NODE_MODULES
fi

if [ ! -d "$LN_NODE_MODULES" ]; then
	echo "Creating symbolic link from $LN_NODE_MODULES to $RL_NODE_MODULES"
	ln -s $RL_NODE_MODULES $LN_NODE_MODULES
fi
