#!/bin/bash

function line {
	for((i=1; i<=20; i++)); do echo -n "--"; done; echo -en "\n"
}

line
echo " ██▓███   ▄▄▄       ███▄    █  ▐██▌  ▄████▄  ";
echo "▓██░  ██▒▒████▄     ██ ▀█   █  ▐██▌ ▒██▀ ▀█  ";
echo "▓██░ ██▓▒▒██  ▀█▄  ▓██  ▀█ ██▒ ▐██▌ ▒▓█    ▄ ";
echo "▒██▄█▓▒ ▒░██▄▄▄▄██ ▓██▒  ▐▌██▒ ▓██▒ ▒▓▓▄ ▄██▒";
echo "▒██▒ ░  ░ ▓█   ▓██▒▒██░   ▓██░ ▒▄▄  ▒ ▓███▀ ░";
echo "▒▓▒░ ░  ░ ▒▒   ▓▒█░░ ▒░   ▒ ▒  ░▀▀▒ ░ ░▒ ▒  ░";
echo "░▒ ░       ▒   ▒▒ ░░ ░░   ░ ▒░ ░  ░   ░  ▒   ";
echo "░░         ░   ▒      ░   ░ ░     ░ ░        ";
echo "               ░  ░         ░  ░    ░ ░      ";
echo "                                    ░        ";

#temp dir
dir="/tmp/panic/$(date +%s)"
mkdir -p $dir

#fetching ip range and finding live addresses
line
echo -n "Your IP adddress : "; echo -e "\033[1m$(hostname -I)\033[0m"
line
echo -ne "Enter IP (\033[1mA.B.C\033[0m) : "; read ip
echo -ne "Enter \033[1mXX\033[0m ($ip.\033[1mXX\033[0m) : "; read x
echo -ne "Enter \033[1mYY\033[0m ($ip.\033[1mYY\033[0m) : "; read y
line
echo -e "Scanning the network [$ip.\033[1m$x\033[0m-\033[1m$y\033[0m]"
line
for((i=1; x<=y; x++)); do
	ping -c 2 -i 0.2 -n -q $ip.$x > /dev/null
	if [ $? -eq 0 ]; then echo "$i.  $ip.$x" | tee --append $dir/ip.lst; ((i++)); fi
	if [ ! -e $dir/ip.lst ]; then echo -e "NO hosts found !!\nTry again later"; line; exit 1; fi
done

#script for automation after ssh login
cat<<EOF>$dir/tmp.sh
#!/bin/bash
#mousepad --display=:0 /tmp/ban.txt 2>/dev/null
DISPLAY=:0 gedit --new-window /tmp/ban.txt
EOF
if [ -e $dir/tmp.sh ];then chmod +x $dir/tmp.sh; fi

#funny banner for target
echo "                                                " >> $dir/ban.txt
echo "                                                " >> $dir/ban.txt
echo "██╗  ██╗ █████╗  ██████╗██╗  ██╗███████╗██████╗ " >> $dir/ban.txt
echo "██║  ██║██╔══██╗██╔════╝██║ ██╔╝██╔════╝██╔══██╗" >> $dir/ban.txt
echo "███████║███████║██║     █████╔╝ █████╗  ██║  ██║" >> $dir/ban.txt
echo "██╔══██║██╔══██║██║     ██╔═██╗ ██╔══╝  ██║  ██║" >> $dir/ban.txt
echo "██║  ██║██║  ██║╚██████╗██║  ██╗███████╗██████╔╝" >> $dir/ban.txt
echo "╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝╚══════╝╚═════╝ " >> $dir/ban.txt
echo "                                                " >> $dir/ban.txt

#selecting the target and attacking :)
line
echo -e "\t[\033[1mQ\033[0m to Quit]"
max=$(cat $dir/ip.lst | wc -l)
user="user"
while read -p "Enter your option (1-$max) : " opt; do
	if [ "$opt" == "Q" -o "$opt" == "q" ]; then echo "Thanks for using !"; exit 0
	elif [ $opt -lt 1 -o $opt -gt $max ];then echo "Invalid input.. Retry !"
	else
		target=$(head -n$opt $dir/ip.lst | tail -n+$opt | cut -d. -f2- | tr -d [:blank:])
		#launching xterm for ssh and scp connection
		if [ $(which xterm) ];then
			line
			echo -e "Attacking on \033[1m$target\033[0m"
			echo -en "Transfering files\t\t"
			xterm -T "Transfering files to $target" -e scp $dir/tmp.sh $dir/ban.txt $user@$target:/tmp/
			echo "[DONE]"
			echo -en "Establishing ssh connection\t"
			xterm -hold -T "Executing tmp.sh on $target" -e ssh $user@$target source /tmp/tmp.sh
			echo "[DONE]"
			line
		fi
	fi
done
