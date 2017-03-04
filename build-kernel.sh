# Suppress GCC warnings
# or use kanged Makefile
# Only for GCC > 4
export KCFLAGS='-Wno-unused-const-variable -Wno-misleading-indentation -Wno-shift-overflow -Wno-bool-compare -Wno-discarded-array-qualifiers -Wno-logical-not-parentheses -Wno-logical-not-parentheses -Wno-memset-transposed-args -fgnu89-inline'
# also don't forget to modify "wlan_nv_template_builtin.c" file

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
DTBTOOL=/home/sachin_hehal45/kernel-dev/tool/mkbootimg_tools/dtbToolCM

# kernel-v$ver.zip
if ! [ -e /home/sachin_hehal45/kernel-dev/tool/ver.dat ]; then
	echo '0' >/home/sachin_hehal45/kernel-dev/tool/ver.dat
fi

if [ ! `echo $PATH|grep ccache` ];then
	export PATH="/usr/lib/ccache:$PATH"
fi
# Tweakable Options Below
echo -e "$Yellow***********************************************"
echo -e "$Cyan\tExporting parameters"
export KBUILD_BUILD_USER="ubuntu"
export KBUILD_BUILD_HOST="gcloud"
export ARCH=arm64
export SUBARCH=arm64
export USE_CCACHE=1

# Choose Toolchain
export CROSS_COMPILE="/home/sachin_hehal45/kernel-dev/tc/sabermod-aarch64-linux-android-4.9/bin/aarch64-linux-android-"
#export CROSS_COMPILE="/home/sachin_hehal45/kernel-dev/tc/ubertc-aarch64-linux-android-4.9/bin/aarch64-linux-android-"

sleep 1
# Compilation Scripts Are Below
echo -e "$Yellow***********************************************"
echo -e "$Cyan\tCompiling YU Yuphoria kernel"
echo -e "$Yellow***********************************************"
echo -e "$Cyan\tPress enter to continue..."
read enterkey
echo -e "$Yellow***********************************************";echo -e $nocol
if [ -e $KERNEL_DIR/arch/arm64/boot/dt.img ];then rm -f $KERNEL_DIR/arch/arm64/boot/dt.img;fi
if [ -e $KERNEL_DIR/make.log ];then rm -f $KERNEL_DIR/make.log;fi
sleep 1
make clean &>/dev/null
echo -e "$Cyan\tmake clean\t["$Yellow"done"$Cyan"]"
make mrproper &>/dev/null
echo -e "$Cyan\tmake mrproper\t["$Yellow"done"$Cyan"]"
make cyanogenmod_lettuce-64_defconfig &>/dev/null
echo -e "$Cyan\tmake defconfig\t["$Yellow"done"$Cyan"]"
sleep 1
echo -e $nocol
make menuconfig
echo -e "$Cyan\tmake menuconfig\t["$Yellow"done"$Cyan"]"
sleep 1
echo -e "$Yellow***********************************************"
echo -e "$Cyan Please wait...while compilation completes...";echo -e $nocol
BUILD_START=$(date +"%s")
make -j$(cat /proc/cpuinfo|grep processor|wc --lines) &>make.log
# Checking for compiled zImage
sleep 1
if ! [ -e $ZIMAGE ]; then
	BUILD_END=$(date +"%s")
	DIFF=$(($BUILD_END - $BUILD_START))
	echo -e "$Yellow***********************************************";echo -e $Cyan
	cat $KERNEL_DIR/make.log | grep error
	echo -e "$Yellow***********************************************"
	echo -e "$Red Kernel Compilation failed!!! Fix the errors and try again later!!!"$Cyan"\t["$Yellow"TimeElapsed = $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds"$Cyan"]"
	echo -e "$Yellow***********************************************"
	echo -e $nocol
	exit 1
fi

ver=$(cat /home/sachin_hehal45/kernel-dev/tool/ver.dat)
let "ver += 1"
echo $ver>/home/sachin_hehal45/kernel-dev/tool/ver.dat

BUILD_END=$(date +"%s")
DIFF=$(($BUILD_END - $BUILD_START))
sleep 1
echo -e "$Yellow***********************************************"
echo -e "$Cyan Build completed in $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds"
echo -e "$Yellow***********************************************"
echo -e "$Cyan Creating dt.img"
echo -e "$Yellow***********************************************"
echo -e $nocol
$DTBTOOL --force-v2 --output-file $KERNEL_DIR/arch/arm64/boot/dt.img --page-size 2048 --dtc-path $KERNEL_DIR/scripts/dtc/ $KERNEL_DIR/arch/arm/boot/dts/
if ! [ -e $KERNEL_DIR/arch/arm64/boot/dt.img ];then
    echo -e "$Red Unable to create dt.img !!"
    echo -e $nocol
    exit 1
fi
sleep 1
echo -e "$Yellow***********************************************"
echo -e "$Cyan Removing old zImage and dt.img"
echo -e "$Yellow***********************************************"
rm /home/sachin_hehal45/kernel-dev/tool/kernel/tools/zImage 2>/dev/null
rm /home/sachin_hehal45/kernel-dev/tool/kernel/tools/dt.img 2>/dev/null
sleep 1
echo -e "$Cyan Copying zImage and dt.img"
echo -e "$Yellow***********************************************"
cp $ZIMAGE /home/sachin_hehal45/kernel-dev/tool/kernel/tools/zImage
if ! [ -e /home/sachin_hehal45/kernel-dev/tool/kernel/tools/zImage ]; then
	echo -e "$Red Unable to copy zImage !!"
	echo -e "$Yellow***********************************************"
	echo -e $nocol
	exit 1
fi
sleep 1
cp $KERNEL_DIR/arch/arm64/boot/dt.img /home/sachin_hehal45/kernel-dev/tool/kernel/tools/dt.img
if ! [ -e /home/sachin_hehal45/kernel-dev/tool/kernel/tools/dt.img ];then
	echo -e "$Red Unable to copy dt.img !!"
	echo -e "$Yellow***********************************************"
	echo -e $nocol
	exit 1
fi
echo -e "$Cyan Creating kernel_v"$ver".zip"
echo -e "$Yellow***********************************************"
echo -e $nocol
cd /home/sachin_hehal45/kernel-dev/tool/kernel/
zip -9 -r /home/sachin_hehal45/kernel-dev/kernel-v$ver.zip ./*
if ! [ -e /home/sachin_hehal45/kernel-dev/kernel-v$ver.zip ];then
	echo -e $Red "Unable to create kernel-v"$ver".zip !!"
	echo -e $nocol
	exit 1
fi
echo -e "$Yellow***********************************************"
echo -e "$Cyan kernel_v"$ver".zip created successfully"
echo -e $nocol