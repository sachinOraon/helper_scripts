#!/bin/bash

if [ "$UID" -ne 0 ];then echo "Please run this script with root privileges !!"; exit 1; fi
d="/tmp/proxi/`date +%d%m%y-%H%M%S`"
logfile="/tmp/proxi/Log-`date +%d%m%y`.log"
if [ ! -d "$d" ];then mkdir -p $d; fi

function fetch_proxy {
	wget -qO $d/proxy http://172.31.9.69/dc/api/proxy

	egrep -o "\"speed\":\"[0-9]{1,5}([\.][0-9]{1,4} (MB|KB)| (KB|MB))" $d/proxy | cut -d: -f2 | tr -d "\"" > $d/s1
	if [ `cat $d/s1 | wc -l` -eq 0 ];then echo "Unable to fetch proxy servers list !!"; exit 1; fi
	egrep -o "\"speed_kbps\":\"[0-9]{1,8}" $d/proxy | cut -d: -f2 | tr -d "\"" > $d/s2
	sort -gr $d/s2 > $d/s3

	egrep -o "\"ip\":\"172.31.[0-9]{1,3}\.[0-9]{1,3}" $d/proxy | cut -d: -f2 | tr -d "\"" > $d/ip
	j=`cat $d/ip | wc -l`
	for ((i=1; i<=j; i++)); do
		ip=`awk -v x=$i 'NR==x {print $0}' $d/ip`
		s1=`awk -v x=$i 'NR==x {print $0}' $d/s1`
		echo -e "$ip\t$s1"
	done > $d/lst

	for ((i=1; i<=j; i++)); do
	   x=`awk -v a=$i 'NR==a {print $0}' $d/s3`
	   if [ `expr $i % 2` -eq 0 ];then y=`grep -no "$x" $d/s2 | head -n1 | cut -d: -f1`
	   else y=`grep -no "$x" $d/s2 | tail -n1 | cut -d: -f1`; fi
	   z=`head -n$y $d/lst | tail -n1 | cut -f1`
	   w=`head -n$y $d/lst | tail -n1 | cut -f2`
	   echo -e "$z\t$w/s"
	   sleep 1
	done > $d/lst2
	proxy=`head -n1 $d/lst2 | cut -f1`
	speed=`head -n1 $d/lst2 | cut -f2`
	port=3128
	user=edcguest
	pass=edcguest
}

function clear_proxy {
	echo -ne "Clearing proxy\t" | tee "$logfile"
	gsettings set org.gnome.system.proxy mode "none"
	gsettings set org.gnome.system.proxy.http host \"\"
	gsettings set org.gnome.system.proxy.http port 0
	gsettings set org.gnome.system.proxy.https host "\"\""
	gsettings set org.gnome.system.proxy.https port 0
	gsettings set org.gnome.system.proxy.ftp host "\"\""
	gsettings set org.gnome.system.proxy.ftp port 0
	gsettings set org.gnome.system.proxy.http use-authentication false
	gsettings set org.gnome.system.proxy.http authentication-user "\"\""
	gsettings set org.gnome.system.proxy.http authentication-password "\"\""
	rm /etc/apt/apt.conf 2>/dev/null
	echo "[DONE]" | tee -a "$logfile"
	if `crontab -l -u root | grep -q "proxi"`;then crontab -u root -r; fi
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

if [ $# -eq 0 ];then echo -e "Available Options\nu, U\tUnset proxy\ns, S\tSet proxy\nd, D\tDaemonize"; fi
case "$1" in
	"s" | "S" )
		fetch_proxy
		apply_system
		apply_apt
		;;
	"u" | "U" )
		clear_proxy
		;;
	"d" | "D" )
		fetch_proxy
		cur_proxy=`gsettings get org.gnome.system.proxy.http host | tr -d \'`
		if [ "$cur_proxy" != "$proxy" ];then
			echo "----------------------------------------------------" >> $logfile
			echo -e "Script executed on `date`" >> $logfile
			echo -e "[$proxy]\t[$speed]" >> $logfile
			apply_system
			apply_apt
		fi
		if ! `crontab -l -u root | grep -q "proxi"`;then
			cp "$PWD/$0" /usr/bin/proxi
			echo "*/10 * * * * /usr/bin/proxi D" > $d/cronfile
			crontab -u root $d/cronfile
		fi
		;;
	* )
		if [ -e "$logfile" ];then
			echo "----------------------------------------------------"
			echo -e "\tLog Data"
			tail -n5 $logfile
		fi
		;;
esac
