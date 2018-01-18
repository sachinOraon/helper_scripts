#!/bin/bash

if [ "$UID" -ne 0 ];then echo "Please run this script with root privileges !!"; exit 1; fi
d="/tmp/proxi/`date +%d%m%y-%H%M%S`"
logfile="/tmp/proxi/Log-`date +%d%m%y`.log"
if [ ! -d "$d" ];then mkdir -p $d; fi

function fetch_proxy {
	wget -qO $d/proxy http://172.31.9.69/dc/api/proxy
   alive=`grep -o "\"status\":\"Working\"" $d/proxy | wc -l`
	egrep -o "\"speed\":\"[0-9]{1,5}([\.][0-9]{1,4} (MB|KB)| (KB|MB))" $d/proxy | cut -d: -f2 | tr -d "\"" > $d/s1
	if [ "$1" != "b" -o "$1" != "B" ];then
	   if [ `cat $d/s1 | wc -l` -eq 0 ];then echo "Unable to fetch proxy servers list !!"; exit 1; fi
	fi
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
	if `crontab -l -u root | grep -q "proxi"`;then crontab -u root -r; fi
	rm /usr/bin/proxi 2>/dev/null
	echo "[DONE]" | tee -a "$logfile"

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

case "$1" in
	"a" | "A" )
		fetch_proxy
		apply_system
		apply_apt
		tail -n5 $logfile
      echo -e "Current Proxy\t[`gsettings get org.gnome.system.proxy.http host | tr -d \'`]"
		;;
	"d" | "D" )
		clear_proxy
		;;
	"b" | "B" )
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
			echo "*/1 * * * * /usr/bin/proxi B" > $d/cronfile
			crontab -u root $d/cronfile
		fi
		;;
	* )
      fetch_proxy
      echo -e "Proxy\t\tSpeed\n------------------------------------"
      cat $d/lst
      echo "------------------------------------"
      echo -e "Current Proxy [`gsettings get org.gnome.system.proxy.http host | tr -d \'`]"
      echo "------------------------------------"
		echo -e "Available Options\n------------------------------------\nd, D\tDeactivate proxy\na, A\tActivate proxy\nb, B\tRun in background [crontab]"
		if [ -e "$logfile" ];then
			echo "------------------------------------"
			echo -e "\tLog Data"
			tail -n5 $logfile
		fi
		;;
esac
