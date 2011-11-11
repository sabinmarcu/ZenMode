#!/bin/bash

target=""
add="127.0.0.1	"
scriptname=$(readlink "$0")
base="$(cd -P "$(dirname "$scriptname")" && pwd)" 
stop_zen()	{
	echo "Stopping zen mode ..."

	target=$(read_file /etc/.hosts "\n")
	sudo rm /etc/.hosts
	
	aux=$(echo -e $target | sudo tee /etc/hosts)
}
start_zen()	{
	echo "Starting zen mode ..."
	
	script="$base/denials"
	add="$add$(crawl $script) "
	target=$(read_file /etc/hosts "\n")

	aux=$(echo -e $target | sudo tee /etc/.hosts)
	target="$target\n$add"
	aux=$(echo -e $target | sudo tee /etc/hosts)
}
read_file()	{
	c=""
	while read line
	do
		c="$c$line$2"
	done < $1
	l=$((${#c} - 2))
	echo ${c:0:l}
}
crawl()	 {
	script=$1
	add=""
	if [ -a $script ]; then
		script="$script/*"
		for file in $script
		do
			add="$add${file##*\/} "
		done
	fi
	echo $add
}
case "$1" in
	start|-s)
		if [[ -a /etc/.hosts ]]; then
			echo "Zen mode already started"
		else
			start_zen
		fi
		;;
	stop|-k)
		if [[ -a /etc/.hosts ]]; then
			stop_zen
		else
			echo "Zen mode already stopped"
		fi
		;;
	restart|reload|-r)
		[[ -a /etc/.hosts ]] && stop_zen
		start_zen
		;;
	allow|-a)
		if [ -a "$base/denials/$2" ]; then 
			rm "$base/denials/$2"
		else 
			echo "Website not denied!"
			exit 1
		fi
		[[ -a /etc/.hosts ]] && stop_zen && start_zen
		;;
	deny|-d)
		if [ -a "$base/denials/$2" ]; then
			echo "Website already denied!"
			exit 1
		else
			touch "$base/denials/$2"
		fi
		[[ -a /etc/.hosts ]] && stop_zen && start_zen
		;;
	list|-l)	
		list="\n"$(crawl "$base/denials")
		list=${list//\ /"\n"}"\n"
		echo -e $list
		;;
	install)
		target="/usr/local/bin"
		if [ -a "$target/zm" ] || [ -h "$target/zm" ];
		then
			sudo rm "$target/zm"
		fi
		if [ -a "$target/zenmode" ] || [ -h "$target/zenmode" ]; then
		       	sudo rm "$target/zenmode"
		fi
		if [ "$2" = "--short" ];
		then
			target="$target/zm"
		else
			target="$target/zenmode"
		fi
		file=$(readlink "$0")
		if [ "$scriptname" == "" ]; then
			file=$0
		else 
			file=$scriptname
		fi
		file=${file##*/}
		sudo ln -s "$base/$file" $target
		;;
	*)
		echo -e "Usage: \e[1;31mzenmode \e[1;34m[options]\e[0m"
		echo
	        echo -e "\e[1;34mOptions\e[0m available : "
		echo -e "\e[1;32mstart \e[1;36m(-s)\e[0m : Start Zen Mode"
		echo -e "\e[1;32mstop \e[1;36m(-k)\e[0m : Stop Zen Mode"
		echo -e "\e[1;32mrestart \e[1;36m(-r)\e[1;32m / reload \e[0m: Restart Zen Mode"
		echo -e "\e[1;32mallow \e[1;36m(-a) \e[1;31m<website>\e[0m : Enable access to the specified website domain"
		echo -e "\e[1;32mdeny \e[1;36m(-d) \e[1;31m<website>\e[0m : Deny access to the specified website domain"
		echo -e "\e[1;32mlist \e[1;36m(-l)\e[0m : Print the denial list"	
		echo -e "\e[1;32minstall \e[1;36m(--short)\e[0m : Install ZenMode (--short installs under the name \"zm\")"
		echo
		exit 1
		;;
esac
