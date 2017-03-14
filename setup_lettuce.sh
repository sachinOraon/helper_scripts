romdir=$PWD
case "$1" in
	-j)
		echo "---------------------------------------------"
		update-alternatives --config java
		update-alternatives --config javac
		echo "---------------------------------------------"
		java -version
		echo "---------------------------------------------"
		exit 0
		;;
	-c)
		echo "---------------------------------------------"
		read -p "BRANCH (L/M/N) = " b
		case "$b" in
			l|L)
				b=cm-12.1
			;;
			m|M)
				b=cm-13.0
			;;
			n|N)
				b=cm-14.1
			;;
			*)
				echo "Invalid branch...!"
				exit 1
			;;
		esac
		read -p "SOURCE (L/C)   = " s
		case "$s" in
			l|L)
				s="LineageOS"
			;;
			c|C)
				s="CyanogenMod"
			;;
			*)
				echo "Invalid source...!"
				exit 1
			;;
		esac
		echo "---------------------------------------------"
		echo -e "\tCOPYING caf trees"
		echo "---------------------------------------------"
		if [ -d $HOME/workspace/lettuce-trees/$s/$b/hardware/qcom ];then
		mkdir -p hardware/qcom/audio-caf/msm8916
		cp -r $HOME/workspace/lettuce-trees/$s/$b/hardware/qcom/audio-caf/msm8916/* hardware/qcom/audio-caf/msm8916 2>/dev/null
		if ! [ $? -lt 1 ];then echo -e "audio-caf\t\t[FAILED]"; else echo -e "audio-caf\t\t[DONE]"; fi
		sleep 1
		mkdir -p hardware/qcom/display-caf/msm8916
		cp -r $HOME/workspace/lettuce-trees/$s/$b/hardware/qcom/display-caf/msm8916/* hardware/qcom/display-caf/msm8916 2>/dev/null
		if ! [ $? -lt 1 ];then echo -e "display-caf\t\t[FAILED]"; else echo -e "display-caf\t\t[DONE]"; fi
		mkdir -p hardware/qcom/media-caf/msm8916
		cp -r $HOME/workspace/lettuce-trees/$s/$b/hardware/qcom/media-caf/msm8916/* hardware/qcom/media-caf/msm8916 2>/dev/null
		sleep 1
		if ! [ $? -lt 1 ];then echo -e "media-caf\t\t[FAILED]"; else echo -e "media-caf\t\t[DONE]"; fi
		if [ "$b" = "cm-12.1" -o "$b" = "cm-13.0" ]; then
			rm -r hardware/qcom/ril-caf 2>/dev/null
			cp -r $HOME/workspace/lettuce-trees/$s/$b/hardware/ril-caf/* hardware/ril-caf 2>/dev/null
			if ! [ $? -lt 1 ];then echo -e "ril-caf\t\t\t[FAILED]"; else echo -e "ril-caf\t\t\t[DONE]"; fi
		fi
		echo "---------------------------------------------"
		else echo -e "- Please setup trees properly.\n- To do run ./setup_lettuce -st";fi
		exit 1
		;;
	-f)
		echo "---------------------------------------------"
		echo -e "\tFixing device makefiles"
		echo "---------------------------------------------"
		if [ -e $romdir/device/yu/lettuce/*.dat ];then
			file=$(cat $romdir/device/yu/lettuce/*.dat)
			if [ -e $romdir/device/yu/lettuce/$(echo $file)_lettuce.mk ];then
				mv $romdir/device/yu/lettuce/$(echo $file)_lettuce.mk $romdir/device/yu/lettuce/$(echo $file).mk
				if [ $? -eq 0 ];then echo -e "- Renaming $(echo $file)_lettuce.mk to $(echo $file).mk";else echo "- Can't rename $(echo $file)_lettuce.mk";fi
				sleep 1
				rm $romdir/device/yu/lettuce/AndroidProducts.mk
				if [ $? -eq 0 ];then echo "- Old AndroidProducts.mk removed";else echo "- Old AndroidProducts.mk can't be removed";fi
				echo "PRODUCT_MAKEFILES := device/yu/lettuce/$(echo $file).mk" > $romdir/device/yu/lettuce/AndroidProducts.mk
				sleep 1
				if [ $? -eq 0 ];then echo "- New AndroidProducts.mk created";else echo "- Can't create new AndroidProducts.mk";fi
				if [ -e $romdir/device/yu/lettuce/$(echo $file).mk ];then echo -e "- Now lunch can run successfully";fi
				echo "---------------------------------------------"
				touch $romdir/device/yu/lettuce/run.dat
			else
				mv $romdir/device/yu/lettuce/$(echo $file).mk $romdir/device/yu/lettuce/$(echo $file)_lettuce.mk
				if [ $? -eq 0 ];then echo -e "- Renaming $file.mk to $(echo $file)_lettuce.mk";else echo "- Can't rename $file.mk";fi
				sleep 1
				rm $romdir/device/yu/lettuce/AndroidProducts.mk
				if [ $? -eq 0 ];then echo "- Old AndroidProducts.mk removed";else echo "- Old AndroidProducts.mk can't be removed";fi
				echo "PRODUCT_MAKEFILES := device/yu/lettuce/$(echo $file)_lettuce.mk" > $romdir/device/yu/lettuce/AndroidProducts.mk
				sleep 1
				if [ $? -eq 0 ];then echo "- New AndroidProducts.mk created";else echo "- Can't create new AndroidProducts.mk";fi
				if [ -e $romdir/device/yu/lettuce/$(echo $file)_lettuce.mk ];then echo -e "- Now lunch can run successfully";fi
				echo "---------------------------------------------"
				touch $romdir/device/yu/lettuce/run.dat
			fi
		else
			echo "- Can't find saved file"
		fi
		exit 1
		;;
	-st)
		echo "---------------------------------------------"
		read -p "BRANCH (L/M/N) = " b
		case "$b" in
			l|L)
				b=cm-12.1
				br=cm-12.1-caf-8916
			;;
			m|M)
				b=cm-13.0
				br=cm-13.0-caf-8916
			;;
			n|N)
				b=cm-14.1
				br=cm-14.1-caf-8916
			;;
			*)
				echo "Invalid branch...!"
				exit 1
			;;
		esac
		mkdir -p $HOME/workspace
		mkdir -p $HOME/workspace/lettuce-trees
		mkdir -p $HOME/workspace/lettuce-trees/CyanogenMod
		mkdir -p $HOME/workspace/lettuce-trees/CyanogenMod/cm-12.1
		mkdir -p $HOME/workspace/lettuce-trees/CyanogenMod/cm-13.0
		mkdir -p $HOME/workspace/lettuce-trees/CyanogenMod/cm-14.1
		mkdir -p $HOME/workspace/lettuce-trees/LineageOS
		mkdir -p $HOME/workspace/lettuce-trees/LineageOS/cm-12.1
		mkdir -p $HOME/workspace/lettuce-trees/LineageOS/cm-13.0
		mkdir -p $HOME/workspace/lettuce-trees/LineageOS/cm-14.1
		read -p "SOURCE (L/C)   = " s
		case "$s" in
			l|L)
				s="https://github.com/LineageOS"
				src="$HOME/workspace/lettuce-trees/LineageOS"
			;;
			c|C)
				s="https://github.com/CyanogenMod"
				src="$HOME/workspace/lettuce-trees/CyanogenMod"
			;;
			*)
				echo "Invalid source...!"
				exit 1
			;;
		esac
		echo "---------------------------------------------"
		echo -e "\tSeting up trees"
		if [ -e $src/$b/device/yu/lettuce/Android.mk ];then
			echo "---------------------------------------------"
			echo -e "Previous trees have been found..."
			read -p "Do you want to re-sync ?(Y/N) : " x
			echo "---------------------------------------------"
			if [ "$x" = "y" -o "$x" = "Y" ];then
				echo "- Removing $src/$b ..."
				rm -rf $src/$b/ 2>/dev/null
				if ! [ $? -eq 0 ];then
					sleep 1
					echo "- Unable to remove old stuffs..."
					exit 1
				fi
			else
				echo "Okay..then stay with old stuffs..."
				exit 1
			fi
		fi
		echo "---------------------------------------------"
		echo "Press enter to begin ..."
		read enterkey
		echo "---------------------------------------------"
		echo "Cloning device tree..."
		echo "---------------------------------------------"
		git clone -b $b --single-branch $s/android_device_yu_lettuce.git $src/$b/device/yu/lettuce
		echo "---------------------------------------------"
		echo "Cloning Shared tree..."
		echo "---------------------------------------------"
		git clone -b $b --single-branch $s/android_device_cyanogen_msm8916-common.git $src/$b/device/cyanogen/msm8916-common
		echo "---------------------------------------------"
		echo "Cloning android_device_qcom_sepolicy..."
		echo "---------------------------------------------"
		git clone -b $b --single-branch $s/android_device_qcom_sepolicy.git $src/$b/device/qcom/sepolicy
		echo "---------------------------------------------"
		echo "Cloning qcom_common tree..."
		echo "---------------------------------------------"
		git clone -b $b --single-branch $s/android_device_qcom_common.git $src/$b/device/qcom/common
		if ! [ "$b" = "cm-13.0" -o "$b" = "cm-12.1" ];then
			echo "---------------------------------------------"
			echo "Cloning qcom_binaries..."
			echo "---------------------------------------------"
			git clone -b $b --single-branch https://github.com/TheMuppets/proprietary_vendor_qcom_binaries.git $src/$b/vendor/qcom/binaries
		fi
		if [ "$s" = "https://github.com/LineageOS" ];then
			echo "---------------------------------------------"
			echo "Cloning qcom_opensource..."
			echo "---------------------------------------------"
			if [ "$b" = "cm-13.0" ];then
				git clone -b cm-13.0 https://github.com/LineageOS/android_vendor_qcom_opensource_cryptfs_hw.git $src/cm-13.0/vendor/qcom/opensource/cryptfs_hw
				git clone -b cm-13.0 https://github.com/LineageOS/android_vendor_qcom_opensource_dataservices.git $src/cm-13.0/vendor/qcom/opensource/dataservices
				git clone -b cm-13.0 https://github.com/LineageOS/android_vendor_qcom_opensource_dpm.git $src/cm-13.0/vendor/qcom/opensource/dpm
				git clone -b cm-13.0 https://github.com/LineageOS/android_vendor_qcom_opensource_time-services.git $src/cm-13.0/vendor/qcom/opensource/time-services
			else
				if [ "$b" = "cm-14.1" ];then
					git clone -b cm-14.1 https://github.com/LineageOS/android_vendor_qcom_opensource_cryptfs_hw.git $src/cm-14.1/vendor/qcom/opensource/cryptfs_hw
					git clone -b cm-14.1 https://github.com/LineageOS/android_vendor_qcom_opensource_bluetooth.git $src/cm-14.1/vendor/qcom/opensource/bluetooth
					git clone -b cm-14.1 https://github.com/LineageOS/android_vendor_qcom_opensource_dataservices.git $src/cm-14.1/vendor/qcom/opensource/dataservices
					git clone -b cm-14.1 https://github.com/LineageOS/android_vendor_qcom_opensource_dpm.git $src/cm-14.1/vendor/qcom/opensource/dpm
					git clone -b cm-14.1 https://github.com/LineageOS/android_vendor_qcom_opensource_time-services.git $src/cm-14.1/vendor/qcom/opensource/time-services
				fi
			fi
		fi
		echo "---------------------------------------------"
		echo "Cloning vendor_yu tree..."
		echo "---------------------------------------------"
		git clone -b $b --single-branch https://github.com/TheMuppets/proprietary_vendor_yu.git $src/$b/vendor/yu
		echo "---------------------------------------------"
		echo "Cloning kernel tree..."
		echo "---------------------------------------------"
		git clone -b $b --single-branch $s/android_kernel_cyanogen_msm8916.git $src/$b/kernel/cyanogen/msm8916
		echo "---------------------------------------------"
		echo "Cloning audio-caf tree..."
		echo "---------------------------------------------"
		git clone -b $br --single-branch $s/android_hardware_qcom_audio.git $src/$b/hardware/qcom/audio-caf/msm8916
		echo "---------------------------------------------"
		echo "Cloning display-caf tree..."
		echo "---------------------------------------------"
		git clone -b $br --single-branch $s/android_hardware_qcom_display.git $src/$b/hardware/qcom/display-caf/msm8916
		echo "---------------------------------------------"
		echo "Cloning media-caf tree..."
		echo "---------------------------------------------"
		git clone -b $br --single-branch $s/android_hardware_qcom_media.git $src/$b/hardware/qcom/media-caf/msm8916
		echo "---------------------------------------------"
		if [ "$b" = "cm-13.0" ];then
			echo "Cloning ril-caf tree..."
			echo "---------------------------------------------"
			git clone -b cm-13.0-caf --single-branch $s/android_hardware_ril-caf.git $src/$b/hardware/ril-caf
			echo "---------------------------------------------"
		fi
		if ! [ -e $HOME/workspace/lettuce-trees/kernel.mk ]; then
			wget -O $HOME/workspace/lettuce-trees/kernel.mk https://github.com/AOSIP/platform_build/raw/n-mr1/core/tasks/kernel.mk &>/dev/null
		fi
	exit 1
	;;
	-tc)
		echo -e "\tToolchains Available for Download"
		echo "---------------------------------------------"
		echo -e "1.\tSabermod v4.9\n2.\tUber v4.9\n3.\tLinaro v4.9\n4.\tSDClang v3.8"
		echo "---------------------------------------------"
		read -p "Which toolchain do you want (1/2/3/4)? " tc
		echo "---------------------------------------------"
		case "$tc" in
			4)
				if [ -d $HOME/workspace/toolchains/sdclang-3.8 ];then
					echo "SDClang v3.8 already available..."
					exit 1
				else
					echo "Cloning SDClang v3.8..."
					echo "---------------------------------------------"
					git clone https://github.com/sachinOraon/sdclang.git $HOME/workspace/toolchains/sdclang-3.8
					echo "---------------------------------------------"
				fi
				exit 1
				;;
			1)
				if ! [ -e $HOME/workspace/toolchains/sabermod-aarch64-linux-android-4.9/sb.dat ]; then
					echo "Cloning SaberMod 4.9 Toolchain..."
					echo "---------------------------------------------"
					git clone -b sabermod --single-branch https://bitbucket.org/xanaxdroid/aarch64-linux-android-4.9.git $HOME/workspace/toolchains/sabermod-aarch64-linux-android-4.9
					touch $HOME/workspace/toolchains/sabermod-aarch64-linux-android-4.9/sb.dat
					echo "---------------------------------------------"
				else
					echo "SaberMod 4.9 Toolchain already available..."
					echo "---------------------------------------------"
				fi
				exit 1
				;;
			2)
				if ! [ -e $HOME/workspace/toolchains/ubertc-aarch64-linux-android-4.9/ub.dat ]; then
					echo "Cloning Uber 4.9 Toolchain..."
					echo "---------------------------------------------"
					git clone https://bitbucket.org/UBERTC/aarch64-linux-android-4.9.git $HOME/workspace/toolchains/ubertc-aarch64-linux-android-4.9
					touch $HOME/workspace/toolchains/ubertc-aarch64-linux-android-4.9/ub.dat
					echo "---------------------------------------------"
				else
					echo "Uber 4.9 Toolchain already available..."
					echo "---------------------------------------------"
				fi
				exit 1
				;;
			3)
				if ! [ -e $HOME/workspace/toolchains/linaro-aarch64-linux-android-4.9/ln.dat ]; then
					echo "Cloning Linaro 4.9 Toolchain..."
					echo "---------------------------------------------"
					git clone -b linaro --single-branch https://bitbucket.org/xanaxdroid/aarch64-linux-android-4.9.git $HOME/workspace/toolchains/linaro-aarch64-linux-android-4.9
					touch $HOME/workspace/toolchains/linaro-aarch64-linux-android-4.9/ln.dat
					echo "---------------------------------------------"
				else
					echo "Linaro 4.9 Toolchain already available..."
					echo "---------------------------------------------"
				fi
				exit 1
				;;
			*)
				echo -e "Invaild Choice !"
				exit 1
				;;
		esac
		exit 1
		;;
	-t)
		if ! [ `ls $romdir/prebuilts/gcc/linux-x86/aarch64/*.*|grep def.dat` ]; then
			touch $romdir/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9/def.dat 2>/dev/null
		fi
		echo "---------------------------------------------"
		echo -e "\tToolchains Selection"
		echo "---------------------------------------------"
		echo -e "1.\tSabermod v4.9\n2.\tUber v4.9\n3.\tLinaro v4.9\n4.\tSDClang v3.8.8\n5.\tRestore Toolchain"
		echo "---------------------------------------------"
		curr=$(ls $romdir/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9/*.dat|cut -d "/" -f 11-)
		case "$curr" in
			def.dat) echo -e "Current Toolchain\t[DEFAULT]";;
			sb.dat) echo -e "Current Toolchain\t[SABERMOD]";;
			ln.dat) echo -e "Current Toolchain\t[LINARO]";;
			ub.dat) echo -e "Current Toolchain\t[UBERTC]";;
			*) echo -e "Current Toolchain\t[UNABLE TO FIND]";;
		esac
		sdc=`grep -i -c "SDCLANG" $romdir/device/yu/lettuce/BoardConfig.mk`
		if [ -d $romdir/prebuilts/clang/linux-x86/host/sdclang-3.8 ];then
			if [ $sdc -gt 0 ];then
				if [ -e $romdir/device/qcom/common/sdllvm-lto-defs.mk ];then
					echo -e "SDclang 3.8\t\t[ENABLED]"
				fi
			fi
		else
			echo -e "SDclang 3.8\t\t[DISABLED]"
		fi
		echo "---------------------------------------------"
		read -p "Which toolchain do you want (1/2/3/4/5)? " ch
		echo "---------------------------------------------"
		case "$ch" in
			4)
				if ! [ -d $romdir/prebuilts/clang/linux-x86/host/sdclang-3.8 ];then
					if ! [ -e $HOME/workspace/toolchains/sdclang-3.8 ];then
						echo -e " * SDClang not found\n  Please run ./setup_lettuce.sh -tc to download..."
						exit 1
					else
						echo "Enabling Snapdragon LLVM ARM Compiler 3.8.8"
						mkdir -p $romdir/prebuilts/clang/linux-x86/host/sdclang-3.8
						cp -r $HOME/workspace/toolchains/sdclang-3.8/* $romdir/prebuilts/clang/linux-x86/host/sdclang-3.8
						if [ $? -eq 0 ];then echo " * SDClang copied successfully";else echo " * Unable to copy SDClang !!";fi
						if ! [ -e $romdir/device/qcom/common/sdllvm-lto-defs.mk ];then
							echo " * Creating sdllvm-lto-defs.mk in device/qcom/common"
							wget -O $romdir/device/qcom/common/sdllvm-lto-defs.mk https://github.com/LineageOS/android_device_qcom_common/raw/cm-14.1/sdllvm-lto-defs.mk &>/dev/null
							if [ $? -eq 0 ];then echo " * sdllvm-lto-defs.mk created";else echo " * Failed to create sdllvm-lto-defs.mk";fi
						else
							echo " * sdllvm-lto-defs.mk Found"
						fi
						chk=`grep -i -c "SDCLANG" $romdir/device/yu/lettuce/BoardConfig.mk`
						if [ $chk -eq 0 ];then
							echo " * Creating backup of Boardconfig.mk"
							cp $romdir/device/yu/lettuce/BoardConfig.mk $romdir/device/yu/lettuce/BoardConfig.mk.bak 2>/dev/null
							echo " * Modifying Boardconfig.mk"
							echo -e "\nSDCLANG := true\nSDCLANG_PATH := prebuilts/clang/linux-x86/host/sdclang-3.8/bin\nSDCLANG_LTO_DEFS := device/qcom/common/sdllvm-lto-defs.mk">>$romdir/device/yu/lettuce/BoardConfig.mk
							if ! [ `grep -i -c "SDCLANG" $romdir/device/yu/lettuce/BoardConfig.mk` ]; then echo " * Unable to modify BoardConfig.mk";fi
						else
							echo " * BoardConfig already modified"
						fi
					fi
				else
					read -p "Do you want to Disable SDClang (Y/N)? " y
					if [ "$y" = "Y" -o "$y" = "y" ];then
						echo " * Removing prebuilts/clang/linux-x86/host/sdclang-3.8"
						rm -rf $romdir/prebuilts/clang/linux-x86/host/sdclang-3.8 2>/dev/null
						echo " * Removing sdllvm-lto-defs.mk"
						rm -f $romdir/device/qcom/common/sdllvm-lto-defs.mk 2>/dev/null
						echo " * Restoring BoardConfig.mk"
						if [ -e $romdir/device/yu/lettuce/BoardConfig.mk.bak ];then
							rm $romdir/device/yu/lettuce/BoardConfig.mk
							mv $romdir/device/yu/lettuce/BoardConfig.mk.bak $romdir/device/yu/lettuce/BoardConfig.mk
							if [ $? -eq 0 ];then echo " * DONE";else echo " * FAILED";fi
						else
							" * NO backup found.."
						fi
					else
						echo "Okay...let that survive !!"
					fi
				fi
				exit 1
			;;
			1)
				if [ -e $HOME/workspace/toolchains/sabermod-aarch64-linux-android-4.9/sb.dat ];then
					echo "Copying SaberMod toolchain..."
					echo "---------------------------------------------"
					if ! [ -e $romdir/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9/def.dat ];then
						if [ -e $romdir/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9/sb.dat ];then
							echo -e "Sabermod\t[ACTIVATED]"
							echo "---------------------------------------------"
						else
							if [ -e $romdir/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9/ub.dat ];then
								mv $romdir/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9 $romdir/prebuilts/gcc/linux-x86/aarch64/ubertc-aarch64-linux-android-4.9 &>/dev/null
								if [ -e $romdir/prebuilts/gcc/linux-x86/aarch64/sabermod-aarch64-linux-android-4.9/sb.dat ];then
									mv $romdir/prebuilts/gcc/linux-x86/aarch64/sabermod-aarch64-linux-android-4.9 $romdir/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9 &>/dev/null
									if [ $? -gt 0 ];then echo -e "- SaberMod\t\t[FAILED]";else echo -e "- SaberMod\t\t[SUCCESS]";fi
								else
									cp -r $HOME/workspace/toolchains/sabermod-aarch64-linux-android-4.9 $romdir/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9 &>/dev/null
									if [ $? -gt 0 ];then echo -e "- SaberMod\t\t[FAILED]";else echo -e "- SaberMod\t\t[SUCCESS]";fi
								fi
							else
								if [ -e $romdir/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9/ln.dat ];then
									mv $romdir/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9 $romdir/prebuilts/gcc/linux-x86/aarch64/linaro-aarch64-linux-android-4.9 &>/dev/null
									if [ -e $romdir/prebuilts/gcc/linux-x86/aarch64/sabermod-aarch64-linux-android-4.9/sb.dat ];then
										mv $romdir/prebuilts/gcc/linux-x86/aarch64/sabermod-aarch64-linux-android-4.9 $romdir/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9 &>/dev/null
										if [ $? -gt 0 ];then echo -e "- SaberMod\t\t[FAILED]";else echo -e "- SaberMod\t\t[SUCCESS]";fi
									else
										cp -r $HOME/workspace/toolchains/sabermod-aarch64-linux-android-4.9 $romdir/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9 &>/dev/null
										if [ $? -gt 0 ];then echo -e "- SaberMod\t\t[FAILED]";else echo -e "- SaberMod\t\t[SUCCESS]";fi
									fi
								fi
							fi
						fi
					else
						mv $romdir/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9 $romdir/prebuilts/gcc/linux-x86/aarch64/default-aarch64-linux-android-4.9 &>/dev/null
						if [ -e $romdir/prebuilts/gcc/linux-x86/aarch64/sabermod-aarch64-linux-android-4.9/sb.dat ];then
							mv $romdir/prebuilts/gcc/linux-x86/aarch64/sabermod-aarch64-linux-android-4.9 $romdir/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9 &>/dev/null
							if [ $? -gt 0 ];then echo -e "- SaberMod\t\t[FAILED]";else echo -e "- SaberMod\t\t[SUCCESS]";fi
						else
							cp -r $HOME/workspace/toolchains/sabermod-aarch64-linux-android-4.9 $romdir/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9 &>/dev/null
							if [ $? -gt 0 ];then echo -e "- SaberMod\t\t[FAILED]";else echo -e "- SaberMod\t\t[SUCCESS]";fi
						fi
					fi
				else
					echo -e "Sabermod TC isn't available on $HOME/workspace/toolchain...\nPlease run ./lettuce.sh -tc and select SaberMod from there to download.\n---------------------------------------------"
				fi
				exit 1
				;;
			2)
			if [ -e $HOME/workspace/toolchains/ubertc-aarch64-linux-android-4.9/ub.dat ];then
				echo "Copying Uber Toolchain..."
				echo "---------------------------------------------"
				if ! [ -e $romdir/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9/def.dat ];then
					if [ -e $romdir/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9/ub.dat ];then
						echo -e "UberTC\t\t[ACTIVATED]"
						echo "---------------------------------------------"
					else
						if [ -e $romdir/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9/sb.dat ];then
							mv $romdir/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9 $romdir/prebuilts/gcc/linux-x86/aarch64/sabermod-aarch64-linux-android-4.9 &>/dev/null
							if [ -e $romdir/prebuilts/gcc/linux-x86/aarch64/ubertc-aarch64-linux-android-4.9/ub.dat ];then
								mv $romdir/prebuilts/gcc/linux-x86/aarch64/ubertc-aarch64-linux-android-4.9 $romdir/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9 &>/dev/null
								if [ $? -gt 0 ];then echo -e "- UberTC\t\t[FAILED]";else echo -e "- UberTC\t\t[SUCCESS]";fi
							else
								cp -r $HOME/workspace/toolchains/ubertc-aarch64-linux-android-4.9 $romdir/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9 &>/dev/null
								if [ $? -gt 0 ];then echo -e "- UberTC\t\t[FAILED]";else echo -e "- UberTC\t\t[SUCCESS]";fi
							fi
						else
							if [ -e $romdir/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9/ln.dat ];then
								mv $romdir/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9 $romdir/prebuilts/gcc/linux-x86/aarch64/linaro-aarch64-linux-android-4.9 &>/dev/null
								if [ -e $romdir/prebuilts/gcc/linux-x86/aarch64/ubertc-aarch64-linux-android-4.9/ub.dat ];then
									mv $romdir/prebuilts/gcc/linux-x86/aarch64/ubertc-aarch64-linux-android-4.9 $romdir/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9 &>/dev/null
									if [ $? -gt 0 ];then echo -e "- UberTC\t\t[FAILED]";else echo -e "- UberTC\t\t[SUCCESS]";fi
								else
									cp -r $HOME/workspace/toolchains/ubertc-aarch64-linux-android-4.9 $romdir/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9 &>/dev/null
									if [ $? -gt 0 ];then echo -e "- UberTC\t\t[FAILED]";else echo -e "- UberTC\t\t[SUCCESS]";fi
								fi
							fi
						fi
					fi
				else
					mv $romdir/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9 $romdir/prebuilts/gcc/linux-x86/aarch64/default-aarch64-linux-android-4.9 &>/dev/null
					if [ -e $romdir/prebuilts/gcc/linux-x86/aarch64/ubertc-aarch64-linux-android-4.9/ub.dat ];then
						mv $romdir/prebuilts/gcc/linux-x86/aarch64/ubertc-aarch64-linux-android-4.9 $romdir/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9 &>/dev/null
						if [ $? -gt 0 ];then echo -e "- UberTC\t\t[FAILED]";else echo -e "- UberTC\t\t[SUCCESS]";fi
					else
						cp -r $HOME/workspace/toolchains/ubertc-aarch64-linux-android-4.9 $romdir/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9 &>/dev/null
						if [ $? -gt 0 ];then echo -e "- UberTC\t\t[FAILED]";else echo -e "- UberTC\t\t[SUCCESS]";fi
					fi
				fi
			else
				echo -e "UberTC isn't available on $HOME/workspace/toolchain...\nPlease run ./lettuce.sh -tc and select UberTC from there to download.\n---------------------------------------------"
			fi
				exit 1
				;;
			3)
			if [ -e $HOME/workspace/toolchains/linaro-aarch64-linux-android-4.9/ln.dat ];then
				echo "Copying Linaro Toolchain..."
				echo "---------------------------------------------"
				if ! [ -e $romdir/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9/def.dat ];then
					if [ -e $romdir/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9/ub.dat ];then
						mv $romdir/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9 $romdir/prebuilts/gcc/linux-x86/aarch64/ubertc-aarch64-linux-android-4.9 &>/dev/null
						if [ -e $romdir/prebuilts/gcc/linux-x86/aarch64/linaro-aarch64-linux-android-4.9/ln.dat ];then
							mv $romdir/prebuilts/gcc/linux-x86/aarch64/linaro-aarch64-linux-android-4.9 $romdir/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9 &>/dev/null
							if [ $? -gt 0 ];then echo -e "- Linaro\t\t[FAILED]";else echo -e "- Linaro\t\t[SUCCESS]";fi
						else
							cp -r $HOME/workspace/toolchains/linaro-aarch64-linux-android-4.9 $romdir/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9 &>/dev/null
							if [ $? -gt 0 ];then echo -e "- Linaro\t\t[FAILED]";else echo -e "- Linaro\t\t[SUCCESS]";fi
						fi
					else
						if [ -e $romdir/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9/sb.dat ];then
							mv $romdir/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9 $romdir/prebuilts/gcc/linux-x86/aarch64/sabermod-aarch64-linux-android-4.9 &>/dev/null
							if [ -e $romdir/prebuilts/gcc/linux-x86/aarch64/linaro-aarch64-linux-android-4.9/ln.dat ];then
								mv $romdir/prebuilts/gcc/linux-x86/aarch64/linaro-aarch64-linux-android-4.9 $romdir/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9 &>/dev/null
								if [ $? -gt 0 ];then echo -e "- Linaro\t\t[FAILED]";else echo -e "- Linaro\t\t[SUCCESS]";fi
							else
								cp -r $HOME/workspace/toolchains/linaro-aarch64-linux-android-4.9 $romdir/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9 &>/dev/null
								if [ $? -gt 0 ];then echo -e "- Linaro\t\t[FAILED]";else echo -e "- Linaro\t\t[SUCCESS]";fi
							fi
						else
							if [ -e $romdir/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9/ln.dat ];then
								echo -e "Linaro\t\t[ACTIVATED]"
								echo "---------------------------------------------"
							fi
						fi
					fi
				else
					mv $romdir/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9 $romdir/prebuilts/gcc/linux-x86/aarch64/default-aarch64-linux-android-4.9 &>/dev/null
					if [ -e $romdir/prebuilts/gcc/linux-x86/aarch64/linaro-aarch64-linux-android-4.9/ln.dat ];then
						mv $romdir/prebuilts/gcc/linux-x86/aarch64/linaro-aarch64-linux-android-4.9 $romdir/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9 &>/dev/null
						if [ $? -gt 0 ];then echo -e "- Linaro\t\t[FAILED]";else echo -e "- Linaro\t\t[SUCCESS]";fi
					else
						cp -r $HOME/workspace/toolchains/linaro-aarch64-linux-android-4.9 $romdir/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9 &>/dev/null
						if [ $? -gt 0 ];then echo -e "- Linaro\t\t[FAILED]";else echo -e "- Linaro\t\t[SUCCESS]";fi
					fi
				fi
			else
				echo -e "Linaro TC isn't available on $HOME/workspace/toolchain...\nPlease run ./lettuce.sh -tc and select Linaro from there to download.\n---------------------------------------------"
			fi
				exit 1
				;;
			5)
				echo "Restoring Toolchain..."
				echo "---------------------------------------------"
				if ! [ -e $romdir/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9/def.dat ];then
					if [ -e $romdir/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9/ub.dat ];then
						mv $romdir/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9 $romdir/prebuilts/gcc/linux-x86/aarch64/ubertc-aarch64-linux-android-4.9 &>/dev/null
						mv $romdir/prebuilts/gcc/linux-x86/aarch64/default-aarch64-linux-android-4.9 $romdir/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9 &>/dev/null
						if [ $? -gt 0 ];then echo -e "- Default\t\t[FAILED]";else echo -e "- Default\t\t[RESTORED]";fi
					else
						if [ -e $romdir/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9/sb.dat ];then
							mv $romdir/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9 $romdir/prebuilts/gcc/linux-x86/aarch64/sabermod-aarch64-linux-android-4.9 &>/dev/null
							mv $romdir/prebuilts/gcc/linux-x86/aarch64/default-aarch64-linux-android-4.9 $romdir/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9 &>/dev/null
							if [ $? -gt 0 ];then echo -e "- Default\t\t[FAILED]";else echo -e "- Default\t\t[RESTORED]";fi
						else
							if [ -e $romdir/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9/ln.dat ];then
								mv $romdir/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9 $romdir/prebuilts/gcc/linux-x86/aarch64/linaro-aarch64-linux-android-4.9 &>/dev/null
								mv $romdir/prebuilts/gcc/linux-x86/aarch64/default-aarch64-linux-android-4.9 $romdir/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9 &>/dev/null
								if [ $? -gt 0 ];then echo -e "- Default\t\t[FAILED]";else echo -e "- Default\t\t[RESTORED]";fi
							fi
						fi
					fi
				else
					echo -e "- Default Toolchain\t\t[ACTIVATED]"
				fi
				exit 1
				;;
			*)
				echo -e "Invaild Choice !"
				exit 1
				;;
		esac
		exit 1
		;;
	-ct)
		echo "---------------------------------------------"
		read -p "BRANCH (L/M/N) = " b
		case "$b" in
			l|L)
				b=cm-12.1
			;;
			m|M)
				b=cm-13.0
			;;
			n|N)
				b=cm-14.1
			;;
			*)
				echo "Invalid branch...!"
				exit 1
			;;
		esac
		read -p "SOURCE (L/C)   = " s
		case "$s" in
			l|L)
				s="LineageOS"
			;;
			c|C)
				s="CyanogenMod"
			;;
			*)
				echo "Invalid source...!"
				exit 1
			;;
		esac
		echo "---------------------------------------------"
		echo -e "Press enter to begin Copying trees from $s/$b"
		read enterkey
		echo "---------------------------------------------"
		if [ -d $HOME/workspace/lettuce-trees/$s/$b ];then
			echo "Copying device/yu/lettuce"
			mkdir -p $romdir/device/
			mkdir -p $romdir/device/yu/
			mkdir -p $romdir/device/yu/lettuce
			cp -r $HOME/workspace/lettuce-trees/$s/$b/device/yu/lettuce/* $romdir/device/yu/lettuce
			if ! [ -e $romdir/device/yu/lettuce/device.mk ];then dt=1; else dt=0; fi
			echo "---------------------------------------------"
			echo "Copying device/cyanogen/msm8916-common"
			mkdir -p $romdir/device/cyanogen
			mkdir -p $romdir/device/cyanogen/msm8916-common
			cp -r $HOME/workspace/lettuce-trees/$s/$b/device/cyanogen/msm8916-common/* $romdir/device/cyanogen/msm8916-common
			if ! [ -e $romdir/device/cyanogen/msm8916-common/Android.mk ];then st=1; else st=0; fi
			echo "---------------------------------------------"
			if ! [ -e $romdir/device/qcom/common/Android.mk ];then
				mkdir -p $romdir/device/qcom
				mkdir -p $romdir/device/qcom/common
				echo "Copying device/qcom/common"
				cp -r $HOME/workspace/lettuce-trees/$s/$b/device/qcom/common/* $romdir/device/qcom/common
				if ! [ -e $romdir/device/qcom/common/Android.mk ];then qc=1;qc=0;fi
			else
				echo " * device/qcom/common already available..."
				qc=N
			fi
			echo "---------------------------------------------"
			if [ -d $romdir/device/qcom/common/cryptfs_hw ];then
				echo " * device/qcom/common/cryptfs_hw available..."
				grep -i "TARGET_CRYPTFS_HW_PATH " $romdir/system/vold/Android.mk
				flg1=1
			fi
			if [ -d $romdir/vendor/qcom/opensource/cryptfs_hw ];then
				echo " * vendor/qcom/opensource/cryptfs_hw available..."
				grep -i "TARGET_CRYPTFS_HW_PATH " $romdir/system/vold/Android.mk
				flg2=1
			fi
			if [ "$flg1" = "1" -a "$flg2" = "1" ];then
				echo -e " * cryptfs_hw is available on multiple places\n   Please remove one of them."
				echo " * system/vold/Android.mk --> $( grep -i "TARGET_CRYPTFS_HW_PATH " $romdir/system/vold/Android.mk)"
			fi
			sleep 1
			echo "---------------------------------------------"
			echo "Copying vendor/yu"
			mkdir -p $romdir/vendor/yu
			cp -r $HOME/workspace/lettuce-trees/$s/$b/vendor/yu/* $romdir/vendor/yu
			if ! [ -e $romdir/vendor/yu/lettuce/Android.mk ];then vt=1; else vt=0; fi
			echo "---------------------------------------------"
			echo "Copying device/qcom/sepolicy"
			if [ -d $romdir/device/qcom/sepolicy ];then
				echo " * device/qcom/sepolicy already available..."
				qs=N
			else
				mkdir -p $romdir/device/qcom
				mkdir -p $romdir/device/qcom/sepolicy
				cp -r $HOME/workspace/lettuce-trees/$s/$b/device/qcom/sepolicy/* $romdir/device/qcom/sepolicy
				if [ -e $romdir/device/qcom/sepolicy/Android.mk ];then qs=0;else qs=1;fi
			fi
			echo "---------------------------------------------"
			echo "Copying kernel/cyanogen/msm8916"
			mkdir -p $romdir/kernel
			mkdir -p $romdir/kernel/cyanogen
			mkdir -p $romdir/kernel/cyanogen/msm8916
			cp -r $HOME/workspace/lettuce-trees/$s/$b/kernel/cyanogen/msm8916/* $romdir/kernel/cyanogen/msm8916
			if ! [ -e $romdir/kernel/cyanogen/msm8916/AndroidKernel.mk ]; then kt=1; else kt=0; fi
			echo "---------------------------------------------"
			ls $romdir/vendor
			echo "---------------------------------------------"
			read -p "Enter name of rom's vendor : " vn
			echo $vn>$romdir/device/yu/lettuce/$vn.dat
			echo "---------------------------------------------"
			find $romdir/vendor/$vn -type f \( -name "*common*.mk" -o -name "*$vn*.mk" -o -name "main.mk" \) | cut --delimiter "/" --fields 6-
			echo "---------------------------------------------"
			echo "    (Choose from above list)"
			read -p "Enter path/to/vendor/config/file : " vf
			echo "---------------------------------------------"
			echo -e "- Creating $(echo $vn)_lettuce.mk"
			sleep 1
			echo -e "- Creating AndroidProducts.mk"
			if ! [ -e $romdir/device/yu/lettuce/cm.mk ];then
				mv $romdir/device/yu/lettuce/lineage.mk $romdir/device/yu/lettuce/$(echo $vn)_lettuce.mk
				echo "PRODUCT_MAKEFILES := device/yu/lettuce/$(echo $vn)_lettuce.mk" > $romdir/device/yu/lettuce/AndroidProducts.mk
				echo "s/PRODUCT_NAME := lineage_lettuce/PRODUCT_NAME := $(echo $vn)_lettuce/">$romdir/tmp
				sed -f $romdir/tmp -i $romdir/device/yu/lettuce/$(echo $vn)_lettuce.mk
				rm $romdir/tmp
			else
				mv $romdir/device/yu/lettuce/cm.mk $romdir/device/yu/lettuce/$(echo $vn)_lettuce.mk
				echo "PRODUCT_MAKEFILES := device/yu/lettuce/$(echo $vn)_lettuce.mk" > $romdir/device/yu/lettuce/AndroidProducts.mk
				echo "s/PRODUCT_NAME := cm_lettuce/PRODUCT_NAME := $(echo $vn)_lettuce/">$romdir/tmp
				sed -f $romdir/tmp -i $romdir/device/yu/lettuce/$(echo $vn)_lettuce.mk
				rm $romdir/tmp
			fi
			echo "---------------------------------------------"
			if [ -e vendor/$vn/sepolicy/file_contexts ];then
				flag=`grep -ci /data/misc/radio vendor/$vn/sepolicy/file_contexts`
				str=`grep -i /data/misc/radio vendor/$vn/sepolicy/file_contexts`
				flag2=`grep -ci /data/misc/radio device/qcom/sepolicy/common/file_contexts`
				if [ $flag -gt 0 -a $flag2 -gt 0 ];then
					echo -e " * Please remove [ $str ]\n   from vendor/$vn/sepolicy/file_contexts to avoid errors."
				fi
			fi
			echo "s/vendor\/cm\/config\/common_full_phone.mk/">$romdir/tmp1
			echo "$(echo $vf)">$romdir/tmp2
			sed -i 's/\//\\\//g' $romdir/tmp2
			paste --delimiters "" $romdir/tmp1 $romdir/tmp2>$romdir/tmp
			sed -i 's/mk$/mk\//' $romdir/tmp
			sed -f $romdir/tmp -i $romdir/device/yu/lettuce/$(echo $vn)_lettuce.mk
			rm -r $romdir/tmp*
			sleep 1
			if [ -e $romdir/build/core/tasks/kernel.mk ];then
				mv $romdir/build/core/tasks/kernel.mk $romdir/kernel.mk.bak
				if [ -e $HOME/workspace/lettuce-trees/kernel.mk ];then
					cp $HOME/workspace/lettuce-trees/kernel.mk $romdir/build/core/tasks/kernel.mk 2>/dev/null
					if [ $? -lt 1 ];then echo -e "- kernel.mk file replaced.";else echo -e "\tkernel.mk file wasn't replaced.";fi
				else
					wget -O $romdir/build/core/tasks/kernel.mk https://github.com/AOSIP/platform_build/raw/n-mr1/core/tasks/kernel.mk &>/dev/null
					if [ $? -lt 1 ];then echo -e "- kernel.mk file replaced.";else echo -e "\tkernel.mk file wasn't replaced.";fi
				fi
			else
				if [ -e $romdir/vendor/$vn/build/tasks/kernel.mk ];then
					mv $romdir/vendor/$vn/build/tasks/kernel.mk $romdir/kernel.mk.bak
					if [ -e $HOME/workspace/lettuce-trees/kernel.mk ];then
						cp $HOME/workspace/lettuce-trees/kernel.mk $romdir/vendor/$vn/build/tasks/kernel.mk 2>/dev/null
						if [ $? -lt 1 ];then echo -e "- kernel.mk file replaced.";else echo -e "\tkernel.mk file wasn't replaced.";fi
					else
						wget -O $romdir/vendor/$vn/build/tasks/kernel.mk https://github.com/AOSIP/platform_build/raw/n-mr1/core/tasks/kernel.mk &>/dev/null
						if [ $? -lt 1 ];then echo -e "- kernel.mk file replaced.";else echo -e "\tkernel.mk file wasn't replaced.";fi
					fi
				fi
			fi
			echo "---------------------------------------------"
			echo -e "- Fixing derps..."
			sed -i '/PRODUCT_BRAND/D' $romdir/device/yu/lettuce/full_lettuce.mk
			sed -i '/PRODUCT_DEVICE/a PRODUCT_BRAND := YU' $romdir/device/yu/lettuce/$(echo $vn)_lettuce.mk
			sleep 1
			sed -i '/config_deviceHardwareKeys/D' $romdir/device/yu/lettuce/overlay/frameworks/base/core/res/res/values/config.xml
			sed -i '/config_deviceHardwareWakeKeys/D' $romdir/device/yu/lettuce/overlay/frameworks/base/core/res/res/values/config.xml
			if ! [ `grep -i "MEASUREMENT_COUNT" $romdir/system/media/audio_effects/include/audio_effects/effect_visualizer.h|cut -d " " -f 2` ];then
				sed -i '/#define MEASUREMENT_IDX_RMS  1/a #define MEASUREMENT_COUNT 2' $romdir/system/media/audio_effects/include/audio_effects/effect_visualizer.h
			fi
			sleep 1
			if [ -e $romdir/device/yu/lettuce/board-info.txt ];then
				echo "- Fixing Assertions..."
				rm $romdir/device/yu/lettuce/board-info.txt 2>/dev/null
				if [ $? -eq 0 ];then echo " * device/yu/lettuce/board-info.txt removed";else echo " * unable to remove device/yu/lettuce/board-info.txt";fi
				sed -i '/TARGET_BOARD_INFO_FILE/d' $romdir/device/yu/lettuce/BoardConfig.mk
				er=`grep -ci TARGET_BOARD_INFO_FILE $romdir/device/yu/lettuce/BoardConfig.mk`
				if [ $er -eq 0 ];then echo " * BoardConfig.mk modified";else echo " * unable to edit BoardConfig.mk";fi
			fi
			echo "---------------------------------------------"
			echo -e "- Creating vendorsetup.sh"
			if [ -e $romdir/device/yu/lettuce/vendorsetup.sh ]; then rm $romdir/device/yu/lettuce/vendorsetup.sh 2>/dev/null;fi
			sleep 1
cat <<EOF>$romdir/device/yu/lettuce/vendorsetup.sh
add_lunch_combo $(echo $vn)_lettuce-userdebug
EOF
			echo "---------------------------------------------"
			echo -e "- Creating $(echo $vn)-build.sh"
			if ! [ -e $romdir/$(echo $vn)-build.sh ]; then
				jobs=$(grep -ci processor /proc/cpuinfo)
				jobs=`expr $jobs \* 2`
cat <<EOF>$romdir/$(echo $vn)-build.sh
err=\$(echo \$PATH|grep -c -i aarch64)
case "\$1" in
	-c)
		. build/envsetup.sh
		sleep 1
		rm -rf $HOME/.ccache &>/dev/null
		if [ \$err -eq 0 ]
		then
			lunch $(echo $vn)_lettuce-userdebug
		fi
		sleep 1
		make clean && make clobber
		sleep 1
		make otapackage -j$(echo $jobs)
		;;
	*)
		. build/envsetup.sh
		sleep 1
		if [ \$err -eq 0 ]
		then
			lunch $(echo $vn)_lettuce-userdebug
		fi
		sleep 1
		make otapackage -j$(echo $jobs)
		;;
esac
EOF
				chmod a+x $romdir/$(echo $vn)-build.sh
			fi
			echo "---------------------------------------------"
			echo -e "- Creating remove_trees.sh"
			if [ -e $romdir/remove_trees.sh ]; then rm -f $romdir/remove_trees.sh &>/dev/null;fi
cat <<EOF>$romdir/remove_trees.sh
echo "---------------------------------------------"
rm -rf $HOME/.ccache &>/dev/null
echo "- Removing device tree..."
rm -rf $romdir/device/yu/lettuce &>/dev/null
echo "---------------------------------------------"
echo "- Removing msm8916-common tree..."
rm -rf $romdir/device/cyanogen/msm8916-common &>/dev/null
echo "---------------------------------------------"
echo "- Removing vendor/yu tree..."
rm -rf $romdir/vendor/yu &>/dev/null
echo "---------------------------------------------"
echo "- Removing kernel tree..."
rm -rf $romdir/kernel/ &>/dev/null
echo "---------------------------------------------"
echo "- Removing caf HAL trees..."
rm -rf $romdir/hardware/qcom/audio-caf/msm8916 &>/dev/null
rm -rf $romdir/hardware/qcom/display-caf/msm8916 &>/dev/null
rm -rf $romdir/hardware/qcom/media-caf/msm8916 &>/dev/null
echo "---------------------------------------------"
EOF
			chmod a+x $romdir/remove_trees.sh
			echo "- run ./setup_lettuce.sh -c to copy CAF-HAL trees if needed."
			echo "- also run ./setup_lettuce.sh -f to fix device tree if lunch fails."
			sleep 1
			echo "---------------------------------------------"
			echo -e "\tLOG"
			echo "---------------------------------------------"
			if [ "$dt" = "1" ]; then echo -e "- device tree\t\t[FAILED]";else echo -e "- device tree\t\t[SUCCESS]";fi
			if [ "$st" = "1" ]; then echo -e "- shared tree\t\t[FAILED]";else echo -e "- shared tree\t\t[SUCCESS]";fi
			if [ "$vt" = "1" ]; then echo -e "- vendor_yu\t\t[FAILED]";else echo -e "- vendor_yu\t\t[SUCCESS]";fi
			if [ "$kt" = "1" ]; then echo -e "- kernel tree\t\t[FAILED]";else echo -e "- kernel tree\t\t[SUCCESS]";fi
			if [ "$qs" = "1" ]; then
				echo -e "- qcom-sepolicy tree\t[FAILED]"
			elif [ "$qs" = "N" ]; then
				echo -e "- qcom-sepolicy tree\t[NOT REQUIRED]"
			else
				echo -e "- qcom-sepolicy tree\t[SUCCESS]"
			fi
			if [ "$qc" = "1" ]; then
				echo -e "- qcom-common tree\t[FAILED]"
			elif [ "$qc" = "N" ]; then
				echo -e "- qcom-common tree\t[NOT REQUIRED]"
			else
				echo -e "- qcom-common tree\t[SUCCESS]"
			fi
			echo "---------------------------------------------"
		else
			echo -e "- Please setup trees properly.\n- To do run ./setup_lettuce -st"
		fi
		exit 1
		;;
	*)
		echo -e "\t---------------------------------------------"
		echo -e "\t|               HELP MENU                   |"
		echo -e "\t---------------------------------------------"
		echo -e "\t|   -j     Switch jdk versions              |"
		echo -e "\t|   -c     Copy some caf HAL trees          |"
		echo -e "\t|   -f     To fix lunch error               |"
		echo -e "\t|   -t     Switch toolchain for compilation |"
		echo -e "\t|   -st    Download device trees for later  |"
		echo -e "\t|          use                              |"
		echo -e "\t|   -ct    Copy device trees to working-dir |"
		echo -e "\t|   -tc    Download toolchain for later use |"
		echo -e "\t---------------------------------------------"
		exit 1
		;;
esac