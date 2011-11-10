#!/bin/bash
target=""
add="127.0.0.1	facebook.com 9gag.com smartphowned.com unfriendable.com youtube.com plus.google.com twitter.com klout.com"
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
