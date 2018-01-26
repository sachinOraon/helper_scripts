# To Suppress GCC warnings
# Only for GCC > 4.x
# export KCFLAGS='-Wno-unused-const-variable -Wno-misleading-indentation -Wno-shift-overflow -Wno-bool-compare -Wno-discarded-array-qualifiers -Wno-logical-not-parentheses -Wno-logical-not-parentheses -Wno-memset-transposed-args -fgnu89-inline'

# Color Codes
Black='\e[0;30m'        # Black
Red='\e[1;31m'          # Red
Green='\e[1;32m'        # Green
Yellow='\e[1;33m'       # Yellow
Blue='\e[1;34m'         # Blue
Purple='\e[1;35m'       # Purple
Cyan='\e[1;36m'         # Cyan
White='\e[0;37m'        # White
Fiuscha="\033[0;35m"    # Fiuscha
nocol='\033[0m'         # Default

id="$(id)"; id="${id#*=}"; id="${id%%\(*}"; id="${id%% *}"
if [ "$id" != "0" ] && [ "$id" != "root" ]; then
	echo -e "$Yellow root permission required !! $nocol"
	exit 1
fi

tput clear
# Init Script
KERNEL_DIR=$PWD
ZIMAGE=$KERNEL_DIR/arch/arm64/boot/Image
DTBTOOL=$HOME/workspace/kernel-dev/tool/mkbootimg_tools/dtbToolCM

# kernel-#$ver.zip
if ! [ -e $HOME/workspace/kernel-dev/tool/ver.dat ]; then
	echo '0' >$HOME/workspace/kernel-dev/tool/ver.dat
fi

if [ ! `echo $PATH|grep ccache` ];then
	export PATH="/usr/lib/ccache:$PATH"
fi
echo -e "$Yellow-----------------------------------------------"
echo -ne "$Green";echo -e "
╦ ╦╦ ╦  ╦  ╔═╗╔╦╗╔╦╗╦ ╦╔═╗╔═╗  ╦╔═╔═╗╦═╗╔╗╔╔═╗╦  
╚╦╝║ ║  ║  ║╣  ║  ║ ║ ║║  ║╣   ╠╩╗║╣ ╠╦╝║║║║╣ ║  
 ╩ ╚═╝  ╩═╝╚═╝ ╩  ╩ ╚═╝╚═╝╚═╝  ╩ ╩╚═╝╩╚═╝╚╝╚═╝╩═╝
";echo -ne $nocol;

# Tweakable Options Below
echo -e "$Yellow-----------------------------------------------"
echo -e "$Cyan\tExporting parameters"
export KBUILD_BUILD_USER="sachin727"
export KBUILD_BUILD_HOST="jenkins"
export ARCH=arm64
export SUBARCH=arm64
export USE_CCACHE=1

# Choose Toolchain
#export CROSS_COMPILE="$HOME/workspace/kernel-dev/tc/sabermod-aarch64-linux-android-4.9/bin/aarch64-linux-android-"
#export CROSS_COMPILE="$HOME/workspace/kernel-dev/tc/ubertc-aarch64-linux-android-4.9/bin/aarch64-linux-android-"
export CROSS_COMPILE="$HOME/workspace/kernel-dev/tc/linaro-aarch64-linux-android-6.3/bin/aarch64-linux-android-"

sleep 1
# Compilation Scripts Are Below
echo -e "$Yellow-----------------------------------------------"
echo -ne "$Cyan\tPress enter to continue..."
read enterkey
echo -e "$Yellow-----------------------------------------------";echo -ne $nocol
if [ -e $KERNEL_DIR/arch/arm64/boot/dt.img ];then rm -f $KERNEL_DIR/arch/arm64/boot/dt.img;fi
if [ -e $KERNEL_DIR/make.log ];then rm -f $KERNEL_DIR/make.log;fi
rm -rf $HOME/.ccache 2>/dev/null
rm -rf $HOME/.cache 2>/dev/null
sleep 1
if [ "$1" = "-c" -o "$1" = "-C" ];then
    make clean &>/dev/null
    echo -e "$Cyan\tmake clean\t["$Yellow"done"$Cyan"]"
    make mrproper &>/dev/null
    echo -e "$Cyan\tmake mrproper\t["$Yellow"done"$Cyan"]"
fi
def=`ls $KERNEL_DIR/arch/arm64/configs|grep 'lettuce'`
make $def &>/dev/null
echo -e "$Cyan\tmake defconfig\t["$Yellow"done"$Cyan"]"
#sleep 1
echo -e $nocol
#make menuconfig 2>/dev/null
#echo -e "$Cyan\tmake menuconfig\t["$Yellow"done"$Cyan"]"
sleep 1
echo -e "$Yellow-----------------------------------------------"
echo -ne "$Cyan Please wait...while compilation completes...";echo -e $nocol
BUILD_START=$(date +"%s")
jobs=$(grep -ci processor /proc/cpuinfo)
jobs=`expr $jobs \* 2`
make -j$(echo $jobs) &>make.log
#make -j$(cat /proc/cpuinfo|grep processor|wc --lines) &>make.log
# Checking for compiled zImage
sleep 1
if ! [ -e $ZIMAGE ]; then
	BUILD_END=$(date +"%s")
	DIFF=$(($BUILD_END - $BUILD_START))
	echo -e "$Yellow-----------------------------------------------";echo -ne $nocol
	grep --color=never --line-number 'Error' $KERNEL_DIR/make.log
    grep --color=never --line-number 'error:' $KERNEL_DIR/make.log
    grep --color=never --line-number -i 'No such file or directory' $KERNEL_DIR/make.log
	echo -e "$Yellow-----------------------------------------------"
	echo -e "$Red Kernel Compilation failed!!! Fix the errors and try again later!!!"$Cyan"\t["$Yellow"TimeElapsed = $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds"$Cyan"]"
	echo -e "$Yellow-----------------------------------------------"
	echo -e $nocol
	exit 1
fi

ver=$(cat $HOME/workspace/kernel-dev/tool/ver.dat)
let "ver += 1"
echo $ver>$HOME/workspace/kernel-dev/tool/ver.dat

BUILD_END=$(date +"%s")
DIFF=$(($BUILD_END - $BUILD_START))
sleep 1

echo -e "$Yellow-----------------------------------------------"
echo -e "$Cyan Creating dt.img"
echo -e "$Yellow-----------------------------------------------"
echo -e $nocol
$DTBTOOL --force-v2 --output-file $KERNEL_DIR/arch/arm64/boot/dt.img --page-size 2048 --dtc-path $KERNEL_DIR/scripts/dtc/ $KERNEL_DIR/arch/arm/boot/dts/
if ! [ -e $KERNEL_DIR/arch/arm64/boot/dt.img ];then
    echo -e "$Red Unable to create dt.img !!"
    echo -e $nocol
    exit 1
fi
sleep 1
echo -e "$Yellow-----------------------------------------------"
echo -e "$Cyan Removing old zImage and dt.img"
echo -e "$Yellow-----------------------------------------------"
rm $HOME/workspace/kernel-dev/tool/kernel/zImage 2>/dev/null
rm $HOME/workspace/kernel-dev/tool/kernel/dt.img 2>/dev/null
sleep 1
echo -e "$Cyan Moving zImage and dt.img"
echo -e "$Yellow-----------------------------------------------"
mv $ZIMAGE $HOME/workspace/kernel-dev/tool/kernel/zImage
if ! [ -e $HOME/workspace/kernel-dev/tool/kernel/zImage ]; then
	echo -e "$Red Unable to copy zImage !!"
	echo -e "$Yellow-----------------------------------------------"
	echo -e $nocol
	exit 1
fi
sleep 1
mv $KERNEL_DIR/arch/arm64/boot/dt.img $HOME/workspace/kernel-dev/tool/kernel/dt.img
if ! [ -e $HOME/workspace/kernel-dev/tool/kernel/dt.img ];then
	echo -e "$Red Unable to copy dt.img !!"
	echo -e "$Yellow-----------------------------------------------"
	echo -e $nocol
	exit 1
fi
echo -e "$Cyan Creating kernel-#"$ver".zip"
echo -e "$Yellow-----------------------------------------------"
echo -e $nocol
if ! [ -d $HOME/workspace/kernel-dev/output ];then
    mkdir -p $HOME/workspace/kernel-dev/output
fi
cd $HOME/workspace/kernel-dev/tool/kernel/
zip -9 -r $HOME/workspace/kernel-dev/output/kernel-#$ver.zip ./*
if ! [ -e $HOME/workspace/kernel-dev/output/kernel-#$ver.zip ];then
	echo -e $Red "Unable to create kernel-#"$ver".zip !!"
	echo -e $nocol
	exit 1
fi
echo -e "$Yellow-----------------------------------------------"
echo -e "$Cyan kernel-#"$ver".zip created successfully"
echo -ne $nocol
echo -e "$Yellow-----------------------------------------------"
echo -e "$Cyan Build completed in $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds"
echo -ne $nocol
make clean &>/dev/null;rm -f $KERNEL_DIR/make.log 2>/dev/null;
rm -rf $HOME/.ccache 2>/dev/null; rm -rf $HOME/.cache 2>/dev/null;
echo -e "$Yellow-----------------------------------------------"