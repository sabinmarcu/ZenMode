#!/bin/bash

script="$(cd -P "$(dirname "$(readlink "$0")")" && pwd)/denials/*"
target=""
add="127.0.0.1	"
for file in $script
do
	add="$add${file##*\/} "
done
stop_zen()	{
	echo "Stopping zen mode ..."
	target=$(read_file /etc/.hosts)
	sudo rm /etc/.hosts
	aux=$(echo -e $target | sudo tee /etc/hosts)
}
start_zen()	{
	echo "Starting zen mode ..."
	target=$(read_file /etc/hosts)
	aux=$(echo -e $target | sudo tee /etc/.hosts)
	target="$target\n$add"
	aux=$(echo -e $target | sudo tee /etc/hosts)
}
read_file()	{
	c=""
	while read line
	do
		c="$c$line\n"
	done < $1
	l=$((${#c} - 2))
	echo ${c:0:l}
}
[[ -a /etc/.hosts ]] && stop_zen || start_zen
