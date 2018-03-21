#!/bin/bash

if [ "$UID" -ne 0 ];then export rootUser="N"; d="$HOME/.proxy/`date +%d%m%y-%H%M%S`"; logfile="$HOME/.proxy/log-`date +%d%m%y`.log"
else export rootUser="Y";d="/tmp/proxi/`date +%d%m%y-%H%M%S`";logfile="/tmp/proxi/log-`date +%d%m%y`.log"; fi
if [ ! -d "$d" ];then mkdir -p $d; fi

if [ -z "`which gsettings`" ];then
	read -p "gsettings NOT found ! Do you want to install(y/n)? " opt
	if [ "$opt" == "y" -o "$opt" == "Y" ];then
		echo -en "Installing gsettings\t"
		apt-get update 1>/dev/null 2>/dev/null
		apt-get install network-manager-gnome 2>/dev/null 1>/dev/null
		if [ $? -eq 0 ];then echo "[DONE]"; else echo "[FAILED]"; exit 1; fi
	else echo -e "Without gsettings you can't set system proxy !\nHowever proxy for apt can be configured !"; fi
fi

function fetch_proxy {
	wget --no-proxy -qO $d/proxi http://172.31.9.69/dc/proxy
	egrep -o "<td><b>[0-9]{1,4}((\.| [KM]B)|(\.[0-9]{1,4} [KM]B))" $d/proxi | tr -d "<td><b>" > $d/y
	if [ `cat $d/y | wc -l` -eq 0 ];then if [ "$1" != "x" ];then echo "Unable to fetch proxy servers list !!"; fi; exit 1; fi
	cat $d/y | tr -d " " > $d/y1
	egrep -o "<td>172.31.[0-9]{1,3}.[0-9]{1,3}" $d/proxi | tr -d "<td>" > $d/x	
	N=`cat $d/y | wc -l`
	for((i=1;i<=N;i++));do
		x=`awk -v a=$i 'NR==a {print $0}' $d/x`
		y=`awk -v a=$i 'NR==a {print $0}' $d/y`
		y1=`awk -v a=$i 'NR==a {print $0}' $d/y1`
		echo -e "$x\t$y" >> $d/l
		echo -e "$y1\t$x" >> $d/l1
	done
	sort -hr $d/l1 -o $d/l2
	for((i=1;i<=N;i++));do
		x=`awk -v a=$i 'NR==a {print $2}' $d/l2`
		y=`grep "$x" $d/l | cut -f2`
		echo -e "$x\t$y/s"
	done > $d/l3
	export proxy=`head -n1 $d/l3 | cut -f1`
	export speed=`head -n1 $d/l3 | cut -f2,3`
	export port=3128
	export user=edcguest
	export pass=edcguest
}

function clear_proxy {
	if [ "$rootUser" == "Y" ];then
		rm /etc/apt/apt.conf 2>/dev/null
		crontab -u root -r 2>/dev/null
	else crontab -u "`whoami`" -r 2>/dev/null; echo "Please run \"sudo proxi D\" [to clear proxy for apt]"; fi
	echo -ne "Clearing proxy\t"
	if [ -d "$PWD/.git" ];then
		git config --global --unset http.proxy
		git config --global --unset https.proxy
	fi
	gsettings reset-recursively org.gnome.system.proxy 2>/dev/null	
	echo "[DONE]"
}

function apply_system {
	if [ -n "`which gsettings`" ];then
		gsettings set org.gnome.system.proxy mode "manual" 2>/dev/null
		gsettings set org.gnome.system.proxy.http host $proxy 2>/dev/null
		gsettings set org.gnome.system.proxy.http port $port 2>/dev/null
		gsettings set org.gnome.system.proxy.https host $proxy 2>/dev/null
		gsettings set org.gnome.system.proxy.https port $port 2>/dev/null
		gsettings set org.gnome.system.proxy.ftp host $proxy 2>/dev/null
		gsettings set org.gnome.system.proxy.ftp port $port 2>/dev/null
		gsettings set org.gnome.system.proxy.socks host $proxy 2>/dev/null
		gsettings set org.gnome.system.proxy.socks port $port 2>/dev/null
		gsettings set org.gnome.system.proxy.http use-authentication "true" 2>/dev/null
		gsettings set org.gnome.system.proxy.http authentication-user "$user" 2>/dev/null
		gsettings set org.gnome.system.proxy.http authentication-password "$pass" 2>/dev/null
		echo -e "Applying system proxy\t[DONE]" >> $logfile
	fi
}

function apply_apt {
	if [ ! -e /usr/bin/proxi ];then cp "$PWD/$0" /usr/bin/proxi; fi
	conf="/etc/apt/apt.conf"
	echo -e "Acquire::http::Proxy \"http://$user:$pass@$proxy:$port\";" > $conf
	echo -e "Acquire::https::Proxy \"https://$user:$pass@$proxy:$port\";" >> $conf
	echo -e "Acquire::ftp::Proxy \"ftp://$user:$pass@$proxy:$port\";" >> $conf
	echo -e "Applying proxy for apt\t[DONE]" >> $logfile
}

function apply_git {
	git config --global http.proxy "http://$1:$2@$3:$4"
	git config --global https.proxy "https://$1:$2@$3:$4"
	echo -e "git http proxy\t[`git config --get http.proxy`]"
	echo -e "git https proxy\t[`git config --get https.proxy`]"
}

function cronjob {
	if [ "$rootUser" == "Y" ];then
		cur_user="`basename $HOME`"
		echo "Creating crontab entry for \"root\""
		echo "*/1 * * * * /usr/bin/proxi x" > $d/cronfile
		crontab -u root $d/cronfile
		if [ -n "$cur_user" ];then echo "Creating crontab entry for \"$cur_user\""; crontab -u "$cur_user" $d/cronfile; fi
	else echo "Run this script with sudo."
	fi
}

function disp1 {
	echo "------------------------------------"
	echo -e "Proxy\t\tSpeed\n------------------------------------"
	cat $d/l3
	echo "------------------------------------"
}

function disp2 {
	echo -e "Current System Proxy\t[`gsettings get org.gnome.system.proxy.http host | tr -d \'`]"
	ip=`egrep -o "172.31.[0-9]{1,3}.[0-9]{1,3}" /etc/apt/apt.conf 2>/dev/null | head -n1`
	echo -e "Current apt Proxy\t[$ip]"
	echo "------------------------------------"
}

case "$1" in
	"a" | "A" )
		fetch_proxy
		disp1
		if [ "$rootUser" == "Y" ];then apply_apt; else echo "Please run \"sudo proxi A\" [to apply proxy for apt]"; apply_system; fi
		disp2
		;;
	"m" | "M" )
		fetch_proxy
		echo "------------------------------------"
		echo -e "\tProxy\t\tSpeed\n------------------------------------"
		awk '{print NR,"  ",$0}' $d/l3
		echo "------------------------------------"
		max_opt=`cat $d/l3 | wc -l`
		while read -p "Enter your option (1-$max_opt) : " opt; do
			if [ $opt -gt $max_opt -o $opt -lt 1 ];then echo "Invalid Input ! Retry !"; else break; fi
		done
		export proxy=`head -n$opt $d/l3 | tail -n1 | cut -f1`
		echo "------------------------------------"
		if [ "$rootUser" == "Y" ];then apply_apt; else echo "Please run \"sudo proxi M\" [to apply proxy for apt]"; apply_system; fi
		disp2
		;;
	"d" | "D" )
		clear_proxy
		;;
	"b" | "B" )
		cronjob
		;;
	"g" | "G" )
		if [ -d "$PWD/.git" ];then fetch_proxy; disp1; apply_git $user $pass $proxy $port
		else echo "No git repository found !"; fi
		;;
	"x" )
		fetch_proxy
		if [ -n "`which gnome-session`" ];then
			PID=$(pgrep gnome-session)
			export DBUS_SESSION_BUS_ADDRESS=$(grep -z DBUS_SESSION_BUS_ADDRESS /proc/$PID/environ|cut -d= -f2-)
		fi
		cur_proxy=`gsettings get org.gnome.system.proxy.http host | tr -d \'`
		if [ "$cur_proxy" != "$proxy" ];then
			echo "----------------------------------------------------" >> $logfile
			echo -e "Script executed by `whoami` on `date`" >> $logfile
			echo -e "[$proxy]\t[$speed]" >> $logfile
			apply_system
			if [ "$rootUser" == "Y" ];then apply_apt; fi
		fi
		;;
	* )
		fetch_proxy
		disp1
		disp2
		echo -e "Available Options\n------------------------------------\nd, D\tDeactivate proxy\na, A\tActivate proxy [for apt and system]\nm, M\tManually choose proxy\ng, G\tSet proxy for git\nb, B\tRun in background [crontab]"
		echo "------------------------------------"
		;;
esac
find $HOME/.proxy -mindepth 1 -type d -exec rm -rf {} 2>/dev/null \;
