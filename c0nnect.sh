#!/bin/bash
# Script to connect to given wireless access point.
# Uses iwlist for scanning, iwconfig for connecting to open network and wpa_supplicant for connecting to WPA2 protected networks.

function line { echo "-----------------------------------------------"; }

function targets {
	clear
	line
	echo -e "\tFollowing AP were found"
	if [ -e $td/dmp-01.csv ];then
		x=$(grep --line-number -i "station" $td/dmp-01.csv | cut -d ":" -f 1)
		y=$(( x-1 ))
		head -n $y $td/dmp-01.csv 1>$td/dmp.csv
		egrep -o "([A-Z0-9]{2}[\:]){5}[A-Z0-9]{2}" $td/dmp.csv 1>$td/dmp2.csv
		line
		cut -d "," --output-delimiter "  " -f 1,4,9,6,14 $td/dmp.csv | head -n -1 | tail -n +3 | awk 'BEGIN {OFS="  "} {print NR,"  ", $0}' 1>$td/dmp3.dat
	   cut -d "," --output-delimiter "  " -f 14 $td/dmp.csv | head -n -1 | tail -n +3 > $td/dmpe.dat
	   cut -d "," --output-delimiter "  " -f 6 $td/dmp.csv | head -n -1 | tail -n +3 > $td/dmpa.dat
		echo -e "#\tBSSID\t\tChannel\tENC\tPWR\tESSID\n"
		cat $td/dmp3.dat
		max_opt=`cat $td/dmp3.dat | wc -l`
		line
	fi
}

function airodmp {
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
	if [ `echo $iface | wc --chars` -gt 6 ];then
		# for system where wlan interface is named something like wlxc4e98415dc54
		# pick the first wlanmon interface for now.
		airmon-ng 1>$td/airm.dat
		x=`grep -n "mon" $td/airm.dat | head -n1 | tail -n1 | cut -d: -f1`
		intface=`head -n$x $td/airm.dat | tail -n1 | cut -f2`
	else miface=${iface}mon; fi
	echo -e "Starting airodump-ng... Please wait..\nYou can press Ctrl+C to stop airodump !"
   sleep 3
   if [ -z $miface ];then airodump-ng --output-format csv --write $td/dmp $intface; targets; airmon-ng stop $intface 1>/dev/null 2>/dev/null
   else airodump-ng --output-format csv --write $td/dmp $miface; targets; airmon-ng stop $miface 1>/dev/null 2>/dev/null; fi
}

function obt-iface-if {
	ifconfig > $td/if
	egrep -o "[[:alnum:]]{5,20}[\:]" $td/if | cut -d: -f1 > $td/if1
	num=1
	for i in `cat $td/if1`; do echo -e "$num.\t$i"; ((num++)); done > $td/if2
	line
	echo -e "\tWlan Interface Available"
	line
	cat $td/if2
	line
	max_opt=`cat $td/if2 | wc -l`
	if_file=$td/if2
}

function obt-iface-am {
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
	line
	max_opt=`cat $td/am4 | wc -l`
	if_file=$td/am4
}

function scan-iw {
	echo -en "Scanning for access points\t\t"
	sleep 2
	iwlist $iface scanning 1>$td/iw 2>/dev/null
	echo "[ DONE ]"
	grep "ESSID" $td/iw | awk -F "ESSID:" '{print $2}' > $td/iwe
	if [ `cat $td/iwe | wc -l` -eq 0 ];then
	   echo "NO AP were found !!"
	   if [ `which airodump-ng | wc -l` -eq 1 ];then
	      echo "Trying with airodump-ng"
	      airodmp
      else echo "NO AP were found !! Try again later.. Exiting !"; exit 1
      fi
   else
	   grep -oE "([A-Z0-9]{2}[\:]){5}[A-Z0-9]{2}" $td/iw > $td/iwb
   	grep "Quality" $td/iw | awk -F "Signal level=" '{print $2}' > $td/iwq
   	grep "Encryption" $td/iw | cut -d: -f2 > $td/iwen
   	j=`cat $td/iwe | wc -l`
   	echo -e "#    ESSID\t\tBSSID\t\tStrength\tEncryption\n" > $td/iwlst
   	for ((i=1;i<=j;i++)); do
   		e=`awk -v x=$i 'NR==x {print $0}' $td/iwe`
   		b=`awk -v x=$i 'NR==x {print $0}' $td/iwb`
	   	q=`awk -v x=$i 'NR==x {print $0}' $td/iwq`
	   	en=`awk -v x=$i 'NR==x {print $0}' $td/iwen`
	   	echo -e "$i.  $e\t$b\t$q\t$en"
	   done >> $td/iwlst
	   line
	   echo -e "\tFollowing AP were found"
	   line
	   cat $td/iwlst
	   line
	   max_opt=`cat $td/iwe | wc -l`
	fi
}

function install-wt {
	echo -ne "Installing wireless-tools\t" 
	apt-get install -y wireless-tools 1>/dev/null 2>/dev/null
	if [ `which iwconfig | wc -l` -eq 1 ];then echo "[ SUCCESS ]"; else echo "[ FAILED ]"; exit 1; fi
}

function install-ac {
	echo -ne "Installing aircrack-ng\t"
	apt-get install -y aircrack-ng 1>/dev/null 2>/dev/null
	if [ `which aircrack-ng | wc -l` -eq 1 ];then echo "[ SUCCESS ]"; obt-iface-am; else echo "[ FAILED ]"; fi
}

function install-ws {
	echo -ne "Installing wpasupplicant\t"
	apt-get install -y wpasupplicant 1>/dev/null 2>/dev/null
	if [ `which wpa_supplicant | wc -l` -eq 1 ];then echo "[ SUCCESS ]"; else echo "[ FAILED ]"; exit 1; fi
}

function install-nt {
	echo -ne "Installing net-tools\t\t"
	apt-get install -y net-tools 1>/dev/null 2>/dev/null
	if [ `which ifconfig | wc -l` -eq 1 ];then echo "[ SUCCESS ]"; else echo "[ FAILED ]"; exit 1; fi
}

function getIP {
   if [ -e /var/lib/dhcp/dhclient.leases ]; then rm /var/lib/dhcp/dhclient.leases; fi
   if [ `which dhclient | wc -l` -eq 0 ];then echo "dhclient NOT found ..exiting !!"; exit 1; fi
	dhclient -r $iface
	sleep 1
	echo -en "Obtainig IP address\t\t"
	dhclient $iface 1>/dev/null 2>/dev/null
	if [ $? -eq 0 ]; then echo "[ DONE ]"; else echo "[ FAILED ]"; fi
	ip=`hostname -I`
	if [ -z "$ip" ]; then echo -e " IP = NOT found !!"; else echo -e " IP = $ip"; fi
}

function connect-iw {
	dhclient -r $iface
	echo -en "Connection to \"$essid\"\t"
	iwconfig $iface essid "$essid" ap $bssid 2>/dev/null
	if [ $? -eq 0 ]; then echo "[ SUCCESS ]"; else echo -e "[ FAILED ]\nRetrying ...";
	   echo -en "Connection to $essid\t"
	   ifconfig $iface down 2>/dev/null
	   iwconfig $iface essid "$essid" ap $bssid 2>/dev/null
	   if [ $? -eq 0 ]; then echo "[ SUCCESS ]"; else echo -e "[ FAILED ]"; exit 1; fi
	fi
	getIP
}

function connect-wpa {
	if [ `which wpa_supplicant | wc -l` -eq 0 ];then echo "wpa_supplicant NOT found !! exiting .."; exit 1;
	else
      wpa_supplicant -h > $td/ws
      beg=`expr $(grep -nox "drivers:" $td/ws | cut -d: -f1) + 1`
      end=`expr $(grep -nox "options:" $td/ws | cut -d: -f1) - 2`
      echo "  Drivers available for wpa_supplicant"
      line
      head -n $end $td/ws | tail -n +$beg > $td/ws1
      b=`cat $td/ws1 | wc -l`
      for((a=1;a<=b;a++)); do
         l=`awk -v n=$a 'NR==n {print $0}' $td/ws1`
         echo "$a.$l"
      done > $td/ws2
      cat $td/ws2
      line
      while read -p "Enter your option (1-$b) : " opt; do
      	if [ $opt -gt $b -o $opt -lt 1 ];then echo -e "Invalid input !! Retry"; else break; fi
      done
      line
      driver=`head -n $opt $td/ws1 | tail -n 1 | cut -d= -f1 | tr -d =" "=`
		echo -en "Creating configuration file\t"
		wpa_passphrase $essid $key > /etc/wpa_supplicant.conf
		echo "[ DONE ]"
		echo -e "Connection to $essid"
		dhclient -r $iface
		echo -e "[$iface]\t[$driver]"
		wpa_supplicant -B -i$iface -c/etc/wpa_supplicant.conf -D$driver
      sleep 3
		iwconfig $iface > $td/chk
		if [[ `grep -o "ESSID:off/any" $td/chk` ]];then echo "Failed to connect...exiting !!"; exit 1; fi
		getIP
	fi
}

# check for root
if [ "$UID" -ne 0 ];then echo "Please run this script with root privileges !!"; exit 1; fi

# working directory
td="/tmp/c0nnect/`date +%d%m%y-%H%M%S`"
mkdir -p $td

# resize window
if [ `which resize | wc -l` -eq 1 ];then resize -s 30 84 1>/dev/null 2>/dev/null; fi
clear

# install dependencies
if [ ! -e $HOME/.skip_me ];then
   line
   echo -e "\tInstalling required packages"
   line
   install-wt
   install-ws
   install-nt
   touch $HOME/.skip_me 2>/dev/null
fi

# obtaining interface
airmon=`which airmon-ng`
Ifconfig=`which ifconfig`
if [ -z "$airmon" ]; then
	read -p "Do you want to install airmon-ng tool. It'll help to detect wireless interfaces efficiently. (y/n) : " ans
	if [ "$ans" == "y" -o "$ans" == "Y" ];then
		install-ac
	else
		if [ -z "$Ifconfig" ];then echo "ifconfig NOT found !! exiting.."; exit 1; else obt-iface-if; fi
	fi
else
	obt-iface-am
fi
while read -p "Enter your option (1-$max_opt) : " opt; do
	if [ $opt -gt $max_opt -o $opt -lt 1 ];then echo -e "Invalid input !! Retry"; else break; fi
done
export iface=`head -n $opt $if_file | tail -n 1 | awk '{print $2}'`

# scanning for access points
line
if [ -e /etc/init.d/networking ];then
   echo -ne "Starting /etc/init.d/networking\t"
   /etc/init.d/networking restart 1>/dev/null
   echo "[ DONE ]"
fi
if [ -e /etc/init.d/network-manager ];then
   echo -ne "Starting /etc/init.d/network-manager\t"
   /etc/init.d/network-manager restart 1>/dev/null
   echo "[ DONE ]"
fi
echo -en "ifconfig $iface down\t\t"
ifconfig $iface down
echo "[ DONE ]"
sleep 2
echo -en "ifconfig $iface up\t\t"
ifconfig $iface up 1>/dev/null
echo "[ DONE ]"
if [ `which iwlist | wc -l` -ne 1 ]; then
	echo -e "iwlist NOT found !!\nPress Enter to install it"
	read enterkey
	install-wt
else
	scan-iw
fi

# connection to given AP
while read -p "Enter your option (1-$max_opt) : " opt; do
	if [ $opt -gt $max_opt -o $opt -lt 1 ];then echo -e "Invalid input !! Retry"; else break; fi
done
if [ `cat $td/iwe | wc -l` -eq 0 ];then
   export essid=`head -n $opt $td/dmpe.dat | tail -n 1`
   export encrp=`head -n $opt $td/dmpa.dat | tail -n 1 | cut -d" " -f2`
   export bssid=`head -n $opt $td/dmp2.csv | tail -n 1`
else
   export essid=`head -n $opt $td/iwe | tail -n 1 | sed 's/"//g'`
   export encrp=`head -n $opt $td/iwen | tail -n 1`
   export bssid=`head -n $opt $td/iwb | tail -n 1`
fi
line
if ! [ "$encrp" == "off" -o "$encrp" == "OPN" ];then
	# check for previously saved psk
	if [ -e "/etc/NetworkManager/system-connections/$essid" ];then
	   key=`grep "psk=" /etc/NetworkManager/system-connections/$essid | cut -d= -f2`
	   if [ -n "$key" ];then
	      echo "Saved key found for $essid"
	      read -p "Do you want to use it ? (y/n) : " opt
	      line
	      if [ "$opt" == "y" -o "$opt" == "Y" ];then connect-wpa; fi
      else
         read -sp "Enter password : " key; echo
         connect-wpa
      fi
	else
      echo "$essid requires password"
      read -sp "Enter password : " key; echo
      line
      connect-wpa
	fi
else connect-iw
fi
line
