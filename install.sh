#!/bin/bash

script="$(cd -P "$(dirname "$(readlink "$0")")" && pwd)/zenmode.sh"
target="/usr/local/bin/zenmode"
if [ -e $target ] || [ -h $target ]; then 
	sudo rm $target 
fi
sudo ln -s $script $target
