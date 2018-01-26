#!/bin/bash

if [ "$UID" -ne 0 ];then export rootUser="N"; d="$HOME/.proxy/`date +%d%m%y-%H%M%S`"; logfile="$HOME/.proxy/log-`date +%d%m%y`.log"
else export rootUser="Y";d="/tmp/proxi/`date +%d%m%y-%H%M%S`";logfile="/tmp/proxi/log-`date +%d%m%y`.log"; fi
if [ ! -d "$d" ];then mkdir -p $d; fi

function fetch_proxy {
	wget --no-proxy -qO $d/proxy http://172.31.9.69/dc/api/proxy
	alive=`grep -o "\"status\":\"Working\"" $d/proxy | wc -l`
	egrep -o "\"speed\":\"[0-9]{1,5}([\.][0-9]{1,4} (MB|KB)| (KB|MB))" $d/proxy | cut -d: -f2 | tr -d "\"" > $d/s1
	if [ `cat $d/s1 | wc -l` -eq 0 ];then if [ "$1" != "x" ];then echo "Unable to fetch proxy servers list !!"; fi; exit 1; fi
	egrep -o "\"speed_kbps\":\"(([0-9]{1,8})|([0-9]{1,8}.[0-9]{4}))" $d/proxy | cut -d: -f2 | tr -d "\"" > $d/s2
	egrep -o "\"ip\":\"172.31.[0-9]{1,3}\.[0-9]{1,3}" $d/proxy | cut -d: -f2 | tr -d "\"" > $d/ip
	N=`cat $d/ip | wc -l`
	for((i=1;i<=N;i++));do
		ip=`awk -v x=$i 'NR==x {print $0}' $d/ip`
		kb=`awk -v x=$i 'NR==x {print $0}' $d/s2`
		mb=`awk -v x=$i 'NR==x {print $0}' $d/s1`
		if [ "$kb" == "0" ];then continue; fi
		echo -e "$ip\t$mb\t$kb"
	done > $d/q
	awk '{print $4}' $d/q | sort -gr > $d/w
	j=`cat $d/w | wc -l`
	for ((i=1; i<=j; i++)); do
		kb=`awk -v x=$i 'NR==x {print $0}' $d/w`
		ip=`grep "$kb" $d/q | cut -f1`
		mb=`grep "$kb" $d/q | cut -f2`
		echo -e "$ip\t$mb/s"
	done > $d/lst
	export proxy=`head -n1 $d/lst | cut -f1`
	export speed=`head -n1 $d/lst | cut -f2,3`
	export port=3128
	export user=edcguest
	export pass=edcguest
}

function clear_proxy {
	if [ "$rootUser" == "Y" ];then
		rm /etc/apt/apt.conf 2>/dev/null
		crontab -u root -r 2>/dev/null
	else crontab -u "`whoami`" -r 2>/dev/null; echo "Please run \"sudo proxi D\" [to clear proxy for apt]"; fi
	if [ `which gsettings | wc -l` -ne 0 ];then
		echo -ne "Clearing proxy\t" | tee "$logfile"
		gsettings set org.gnome.system.proxy mode "none"
		gsettings set org.gnome.system.proxy.http host \"\"
		gsettings set org.gnome.system.proxy.http port 0
		gsettings set org.gnome.system.proxy.https host "\"\""
		gsettings set org.gnome.system.proxy.https port 0
		gsettings set org.gnome.system.proxy.ftp host "\"\""
		gsettings set org.gnome.system.proxy.ftp port 0
		gsettings set org.gnome.system.proxy.socks host "\"\""
		gsettings set org.gnome.system.proxy.socks port 0
		gsettings set org.gnome.system.proxy.http use-authentication false
		gsettings set org.gnome.system.proxy.http authentication-user "\"\""
		gsettings set org.gnome.system.proxy.http authentication-password "\"\""
		echo "[DONE]" | tee -a "$logfile"
	fi
}

function apply_system {
	if [ `which gsettings | wc -l` -ne 0 ];then
		gsettings set org.gnome.system.proxy mode "manual"
		gsettings set org.gnome.system.proxy.http host $proxy
		gsettings set org.gnome.system.proxy.http port $port
		gsettings set org.gnome.system.proxy.https host $proxy
		gsettings set org.gnome.system.proxy.https port $port
		gsettings set org.gnome.system.proxy.ftp host $proxy
		gsettings set org.gnome.system.proxy.ftp port $port
		gsettings set org.gnome.system.proxy.socks host $proxy
		gsettings set org.gnome.system.proxy.socks port $port
		gsettings set org.gnome.system.proxy.http authentication-user "$user"
		gsettings set org.gnome.system.proxy.http authentication-password "$pass"
		echo -e "Applying system proxy\t[DONE]" >> $logfile
	fi
}

function apply_apt {
	conf="/etc/apt/apt.conf"
	echo -e "Acquire::http::Proxy \"http://$user:$pass@$proxy:$port\";" > $conf
	echo -e "Acquire::https::Proxy \"https://$user:$pass@$proxy:$port\";" >> $conf
	echo -e "Acquire::ftp::Proxy \"ftp://$user:$pass@$proxy:$port\";" >> $conf
	echo -e "Applying proxy for apt\t[DONE]" >> $logfile
}

function cronjob {
	if [ "$rootUser" == "Y" ];then
		cur_user="`basename $HOME`"
		echo "Creating crontab entry for \"root\""
		cp "$PWD/$0" /usr/bin/proxi
		echo "*/1 * * * * /usr/bin/proxi x" > $d/cronfile
		crontab -u root $d/cronfile
		if [ -n "$cur_user" ];then echo "Creating crontab entry for \"$cur_user\""; crontab -u "$cur_user" $d/cronfile; fi
	else echo "Run this script with sudo."
	fi
}

function disp1 {
	echo "------------------------------------"
	echo -e "Proxy\t\tSpeed\n------------------------------------"
	cat $d/lst
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
		apply_system
		if [ "$rootUser" == "Y" ];then apply_apt; else echo "Please run \"sudo proxi A\" [to apply proxy for apt]"; fi
		disp2
		;;
	"m" | "M" )
		fetch_proxy
		echo "------------------------------------"
		echo -e "\tProxy\t\tSpeed\n------------------------------------"
		awk '{print NR,"  ",$0}' $d/lst
		echo "------------------------------------"
		max_opt=`cat $d/lst | wc -l`
		while read -p "Enter your option (1-$max_opt) : " opt; do
			if [ $opt -gt $max_opt -o $opt -lt 1 ];then echo "Invalid Input ! Retry !"; else break; fi
		done
		export proxy=`head -n$opt $d/lst | tail -n1 | cut -f1`
		echo "------------------------------------"
		if [ "$rootUser" == "Y" ];then apply_apt; else echo "Please run \"sudo proxi M\" [to apply proxy for apt]"; fi
		apply_system
		disp2
		;;
	"d" | "D" )
		clear_proxy
		;;
	"b" | "B" )
		cronjob
		;;
	"x" )
		fetch_proxy
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
		echo -e "Available Options\n------------------------------------\nd, D\tDeactivate proxy\na, A\tActivate proxy\nm, M\tManually choose proxy\nb, B\tRun in background [crontab]"
		echo "------------------------------------"
		;;
esac
find $HOME/.proxy -mindepth 1 -type d -exec rm -rf {} 2>/dev/null \;
