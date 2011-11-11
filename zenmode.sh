#!/bin/bash


target=""
add="127.0.0.1	"
base="$(cd -P "$(dirname "$(readlink "$0")")" && pwd)" 
stop_zen()	{
	echo "Stopping zen mode ..."
	target=$(read_file /etc/.hosts)
	sudo rm /etc/.hosts
	aux=$(echo -e $target | sudo tee /etc/hosts)
}
start_zen()	{
	echo "Starting zen mode ..."
	
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
case "$1" in
	start)
		if [[ -a /etc/.hosts ]]; then
			echo "Zen mode already started"
		else
			start_zen
		fi
		;;
	stop)
		if [[ -a /etc/.hosts ]]; then
			stop_zen
		else
			echo "Zen mode already stopped"
		fi
		;;
	restart|reload)
		[[ -a /etc/.hosts ]] && stop_zen
		start_zen
		;;
	allow)
		rm "$base/denials/$2"
		[[ -a /etc/.hosts ]] && stop_zen && start_zen
		;;
	deny)
		touch "$base/denials/$2"
		[[ -a /etc/.hosts ]] && stop_zen && start_zen
		;;
	*)
		echo "Usage: zenmode {start|stop|restart|allow hosthame|deny hostname}" >&2
		exit 1
		;;
esac