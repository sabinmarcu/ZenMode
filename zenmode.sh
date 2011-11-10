#!/bin/bash


target=""
add="127.0.0.1	"
base="$(cd -P "$(dirname "$(readlink "$0")")" && pwd)" 
script="$base/denials"
if [ -a $script ]; then
	script="$script/*"
	for file in $script
	do
		add="$add${file##*\/} "
	done
fi
script="$base/denials.lst"
if [ -a $script ]; then
	while read line
	do
		add="$add$line "
	done < $script
fi
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
