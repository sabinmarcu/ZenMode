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
watch()	{
	echo "Started watching..."
	files=$(crawl "$base/watches")
	ison=0
	canbeon=0
	while [ ${#files} -gt 0 ]; do
		aux=$(ps aux)
		canbeon=0
		for watch in $files
		do
			if [ $(echo $aux | grep -c $watch) -gt 0 ]; then
				if [ $ison -eq 0 ]; then
					start_zen
					ison=1
				fi
				canbeon=1
			fi
		done
		if [ $ison -eq 1 ] && [ $canbeon -eq 0 ]; then
			stop_zen
			ison=0
		fi
		sleep 1;
	done
}
clean(){
	if [[ -a /etc/.hosts ]]; then
		stop_zen
	fi
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
	watch|-w)
		clean
		watch
		;;
	addwatch|addWatch|-aw)
		if [ -a "$base/watches/$2" ]; then
			echo "Watch already listed!"
			exit 1
		else
			touch "$base/watches/$2"
		fi
		;;
	removewatch|removeWatch|-rw)
		if [ -a "$base/watches/$2" ]; then
			rm "$base/watches/$2"
		else
			echo "Watch does not exist!"
			exit 1
		fi
		;;
	listwatches|listWatches|-lw)
		files=$(crawl "$base/watches")
		echo
		for watch in $files 
		do
			echo $watch
		done
		echo
		;;
	clean|-c)
		clean
		;;
	*)
		echo -e "Usage: \033[1;31mzenmode \033[1;34m[options]\033[0m"
		echo
	        echo -e "\033[1;34mOptions\033[0m available : "
		echo -e "\033[1;32mstart \033[1;36m(-s)\033[0m : Start Zen Mode"
		echo -e "\033[1;32mstop \033[1;36m(-k)\033[0m : Stop Zen Mode"
		echo -e "\033[1;32mrestart \033[1;36m(-r)\033[1;32m / reload \033[0m: Restart Zen Mode"
		echo -e "\033[1;32mallow \033[1;36m(-a) \033[1;31m<website>\033[0m : Enable access to the specified website domain"
		echo -e "\033[1;32mdeny \033[1;36m(-d) \033[1;31m<website>\033[0m : Deny access to the specified website domain"
		echo -e "\033[1;32mlist \033[1;36m(-l)\033[0m : Print the denial list"	
		echo -e "\033[1;32minstall \033[1;36m(--short)\033[0m : Install ZenMode (--short installs under the name 'zm')"
		echo -e "\033[1;32mwatch \033[1;36m(-w)\033[0m : Watch for applications runnig and deny access if active."
		echo -e "\033[1;32maddwatch \033[1;36m(addWatch|-aw)\033[0m : Add a new application to the watch list."
		echo -e "\033[1;32mremovewatch \033[1;36m(removeWatch|-rw)\033[0m : Remove the application to the watch list."
		echo -e "\033[1;32mlistwatches \033[1;36m(listWatches|-lw)\033[0m : Print the watch list."
		echo -e "\033[1;32mclean \033[1;36m(-c)\033[0m : Clean the cache."
		echo
		exit 1
		;;
esac
