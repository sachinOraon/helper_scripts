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
        echo -en "BRANCH (\033[1mL/M/N\033[0m) = "
        read b
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
                echo -e " * \033[1mInvalid\033[0m branch...!"
                exit 1
            ;;
        esac
        echo -en "SOURCE (\033[1mL/C\033[0m)   = "
        read s
        case "$s" in
            l|L)
                s="LineageOS"
            ;;
            c|C)
                s="CyanogenMod"
            ;;
            *)
                echo -e " * \033[1mInvalid\033[0m source...!"
                exit 1
            ;;
        esac
        echo "---------------------------------------------"
        echo -e " * \033[1mRemoving\033[0m previous \033[1mcaf\033[0m HAL trees..."
        rm -rf $romdir/hardware/qcom/audio-caf/msm8916 &>/dev/null
        rm -rf $romdir/hardware/qcom/display-caf/msm8916 &>/dev/null
        rm -rf $romdir/hardware/qcom/media-caf/msm8916 &>/dev/null
        rm -rf $romdir/hardware/qcom/wlan-caf &>/dev/null
        rm -rf $romdir/hardware/qcom/bt-caf &>/dev/null
        rm -rf $romdir/hardware/ril-caf &>/dev/null
        sleep 1
        echo "---------------------------------------------"
        echo -e "\tCLONING \033[1mcaf\033[0m trees"
        echo "---------------------------------------------"
        #if [ -d $HOME/workspace/lettuce-trees/$s/$b/hardware/qcom ];then
        #mkdir -p hardware/qcom/audio-caf/msm8916
        #cp -r $HOME/workspace/lettuce-trees/$s/$b/hardware/qcom/audio-caf/msm8916/* hardware/qcom/audio-caf/msm8916 2>/dev/null
        git clone -qb $b-caf-8916 https://github.com/$s/android_hardware_qcom_audio.git hardware/qcom/audio-caf/msm8916
        if ! [ $? -lt 1 ];then echo -e "   \033[1maudio-caf\033[0m\t\t[\033[1mFAILED\033[0m]"; else echo -e "   \033[1maudio-caf\033[0m\t\t[DONE]"; fi
        #sleep 1
        #mkdir -p hardware/qcom/display-caf/msm8916
        #cp -r $HOME/workspace/lettuce-trees/$s/$b/hardware/qcom/display-caf/msm8916/* hardware/qcom/display-caf/msm8916 2>/dev/null
        git clone https://github.com/$s/android_hardware_qcom_display.git -qb $b-caf-8916 hardware/qcom/display-caf/msm8916
        if ! [ $? -lt 1 ];then echo -e "   \033[1mdisplay-caf\033[0m\t\t[\033[1mFAILED\033[0m]"; else echo -e "   \033[1mdisplay-caf\033[0m\t\t[DONE]"; fi
        #mkdir -p hardware/qcom/media-caf/msm8916
        #cp -r $HOME/workspace/lettuce-trees/$s/$b/hardware/qcom/media-caf/msm8916/* hardware/qcom/media-caf/msm8916 2>/dev/null
        git clone -qb $b-caf-8916 https://github.com/$s/android_hardware_qcom_media.git hardware/qcom/media-caf/msm8916
        #sleep 1
        if ! [ $? -lt 1 ];then echo -e "   \033[1mmedia-caf\033[0m\t\t[\033[1mFAILED\033[0m]"; else echo -e "   \033[1mmedia-caf\033[0m\t\t[DONE]"; fi
        #mkdir -p hardware/qcom/wlan-caf
        #cp -r $HOME/workspace/lettuce-trees/$s/$b/hardware/qcom/wlan-caf/* hardware/qcom/wlan-caf 2>/dev/null
        #git clone -qb $b-caf https://github.com/$s/android_hardware_qcom_wlan.git hardware/qcom/wlan-caf 2>/dev/null
        rm -rf $romdir/hardware/qcom/wlan 2>/dev/null
        git clone -qb $b-caf https://github.com/$s/android_hardware_qcom_wlan.git hardware/qcom/wlan 2>/dev/null
        if ! [ $? -lt 1 ];then echo -e "   \033[1mwlan-caf\033[0m\t\t[\033[1mFAILED\033[0m]"; else echo -e "   \033[1mwlan-caf\033[0m\t\t[DONE]"; fi
        #mkdir -p hardware/qcom/bt-caf
        #cp -r $HOME/workspace/lettuce-trees/$s/$b/hardware/qcom/bt-caf/* hardware/qcom/bt-caf 2>/dev/null
        #git clone -qb $b-caf https://github.com/$s/android_hardware_qcom_bt.git hardware/qcom/bt-caf 2>/dev/null
        rm -rf $romdir/hardware/qcom/bt 2>/dev/null
        git clone -qb $b-caf https://github.com/$s/android_hardware_qcom_bt.git hardware/qcom/bt 2>/dev/null
        if ! [ $? -lt 1 ];then echo -e "   \033[1mbt-caf\033[0m\t\t[\033[1mFAILED\033[0m]"; else echo -e "   \033[1mbt-caf\033[0m\t\t[DONE]"; fi
        #mkdir -p hardware/ril-caf
        #cp -r $HOME/workspace/lettuce-trees/$s/$b/hardware/ril-caf/* hardware/ril-caf 2>/dev/null
        #git clone -qb $b-caf https://github.com/$s/android_hardware_ril-caf.git hardware/ril-caf 2>/dev/null
        rm -rf $romdir/hardware/ril 2>/dev/null
        git clone -qb $b-caf https://github.com/$s/android_hardware_ril-caf.git hardware/ril 2>/dev/null
        if ! [ $? -lt 1 ];then echo -e "   \033[1mril-caf\033[0m\t\t[\033[1mFAILED\033[0m]"; else echo -e "   \033[1mril-caf\033[0m\t\t[DONE]"; fi
        #if [ "$b" = "cm-12.1" -o "$b" = "cm-13.0" ]; then
        #    rm -r hardware/qcom/ril-caf 2>/dev/null
        #    cp -r $HOME/workspace/lettuce-trees/$s/$b/hardware/ril-caf/* hardware/ril-caf 2>/dev/null
        #    if ! [ $? -lt 1 ];then echo -e "ril-caf\t\t\t[\033[1mFAILED\033[0m]"; else echo -e "ril-caf\t\t\t[DONE]"; fi
        #fi
        echo "---------------------------------------------"
        #else echo -e "- Please setup trees properly.\n- To do run ./setup_lettuce -st";fi
        exit 1
        ;;
    -f)
        echo "---------------------------------------------"
        echo -e "\t\033[1mFixing device makefiles\033[0m"
        echo "---------------------------------------------"
        if [ -e $romdir/device/yu/lettuce/vendor.dat ];then
            file=$(cat $romdir/device/yu/lettuce/vendor.dat)
            if [ -e $romdir/device/yu/lettuce/$(echo $file)_lettuce.mk ];then
                mv $romdir/device/yu/lettuce/$(echo $file)_lettuce.mk $romdir/device/yu/lettuce/$(echo $file).mk
                if [ $? -eq 0 ];then echo -e "- Renaming \033[1m$(echo $file)_lettuce.mk\033[0m to \033[1m$(echo $file).mk\033[0m";else echo -e "- \033[1mCan't\033[0m rename \033[1m$(echo $file)_lettuce.mk\033[0m";fi
                sleep 1
                rm $romdir/device/yu/lettuce/AndroidProducts.mk
                if [ $? -eq 0 ];then echo -e "- Old \033[1mAndroidProducts.mk\033[0m removed";else echo -e "- Old \033[1mAndroidProducts.mk\033[0m can't be removed";fi
                echo "PRODUCT_MAKEFILES := device/yu/lettuce/$(echo $file).mk" > $romdir/device/yu/lettuce/AndroidProducts.mk
                sleep 1
                if [ $? -eq 0 ];then echo -e "- \033[1mNew\033[0m AndroidProducts.mk created";else echo -e "- \033[1mCan't\033[0m create new AndroidProducts.mk";fi
                if [ -e $romdir/device/yu/lettuce/$(echo $file).mk ];then echo -e "- Now \033[1mlunch\033[0m can run successfully";fi
                echo "---------------------------------------------"
            else
                mv $romdir/device/yu/lettuce/$(echo $file).mk $romdir/device/yu/lettuce/$(echo $file)_lettuce.mk
                if [ $? -eq 0 ];then echo -e "- Renaming \033[1m$file.mk\033[0m to \033[1m$(echo $file)_lettuce.mk\033[0m";else echo -e "- \033[1mCan't\033[0m rename \033[1m$file.mk\033[0m";fi
                sleep 1
                rm $romdir/device/yu/lettuce/AndroidProducts.mk
                if [ $? -eq 0 ];then echo -e "- Old \033[1mAndroidProducts.mk\033[0m removed";else echo -e "- Old \033[1mAndroidProducts.mk\033[0m can't be removed";fi
                echo "PRODUCT_MAKEFILES := device/yu/lettuce/$(echo $file)_lettuce.mk" > $romdir/device/yu/lettuce/AndroidProducts.mk
                sleep 1
                if [ $? -eq 0 ];then echo -e "- \033[1mNew\033[0m AndroidProducts.mk created";else echo -e "- \033[1mCan't\033[0m create new AndroidProducts.mk";fi
                if [ -e $romdir/device/yu/lettuce/$(echo $file)_lettuce.mk ];then echo -e "- Now \033[1mlunch\033[0m can run successfully";fi
                echo "---------------------------------------------"
            fi
        else
            echo -e "- \033[1mCan't\033[0m find \033[1msaved\033[0m file"
        fi
        exit 1
        ;;
    -st)
        echo "---------------------------------------------"
        echo -en "BRANCH (\033[1mL/M/N\033[0m) = "
        read b
        case "$b" in
            l|L)
                b=cm-12.1
                br=cm-12.1-caf-8916
                brc=cm-12.1-caf
            ;;
            m|M)
                b=cm-13.0
                br=cm-13.0-caf-8916
                brc=cm-13.0-caf
            ;;
            n|N)
                b=cm-14.1
                br=cm-14.1-caf-8916
                brc=cm-14.1-caf
            ;;
            *)
                echo -e " * \033[1mInvalid\033[0m branch...!"
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
        mkdir -p $HOME/workspace/lettuce-trees/YU-N
        mkdir -p $HOME/workspace/lettuce-trees/YU-N/cm-14.1
        echo -en "SOURCE (\033[1mL/C\033[0m)   = "
        read s
        case "$s" in
            l|L)
                s="https://github.com/LineageOS"
                src="$HOME/workspace/lettuce-trees/LineageOS"
                if [ "$b" = "cm-14.1" ];then
                    echo -en "Do you want to have \033[1mYU-N\033[0m trees also (\033[1my/n\033[0m)? "
                    read cho
                    if [ "$cho" = "y" -o "$cho" = "Y" ];then
                        sy="https://github.com/YU-N"
                        srcy="$HOME/workspace/lettuce-trees/YU-N"
                    fi
                fi
            ;;
            c|C)
                s="https://github.com/CyanogenMod"
                src="$HOME/workspace/lettuce-trees/CyanogenMod"
                if [ "$b" = "cm-14.1" ];then
                    echo -en "Do you want to have \033[1mYU-N\033[0m trees also (\033[1my/n\033[0m)? "
                    read cho
                    if [ "$cho" = "y" -o "$cho" = "Y" ];then
                        sy="https://github.com/YU-N"
                        srcy="$HOME/workspace/lettuce-trees/YU-N"
                    fi
                fi
            ;;
            *)
                echo -e " * \033[1mInvalid\033[0m source...!"
                exit 1
            ;;
        esac
        echo "---------------------------------------------"
        if [ "$cho" = "y" -o "$cho" = "Y" ]; then
            echo -e "\tSeting up trees with\n * \033[1m$s/$b\033[0m AND\n * \033[1m$sy/$b\033[0m"
        else
            echo -e "\tSeting up trees with\n * \033[1m$s/$b\033[0m"
        fi
        if [ -e $src/$b/device/yu/lettuce/Android.mk ];then
            echo "---------------------------------------------"
            echo -e "\033[1mPrevious\033[0m trees have been \033[1mfound\033[0m..."
            echo -en "Do you want to \033[1mre-sync\033[0m (\033[1mY/N\033[0m)? : "
            read x
            echo "---------------------------------------------"
            if [ "$x" = "y" -o "$x" = "Y" ];then
                echo -e "- Removing \033[1m$src/$b\033[0m ..."
                sleep 1
                rm -rf $src/$b/ 2>/dev/null
                if ! [ $? -eq 0 ];then
                    sleep 1
                    echo -e "- Unable to remove \033[1m$src/$b\033[0m ..."
                    exit 1
                fi
                if [ "$cho" = "y" -o "$cho" = "Y" ];then
                    if [ -e $srcy/$b/device/yu/lettuce/Android.mk ];then
                        echo -en "Do you want to update \033[1mYU-N\033[0m trees also (\033[1mY/N\033[0m)? :"
                        read var
                        if [ "$var" = "y" -o "$var" = "Y" ];then
                            echo -e "- Removing \033[1m$srcy/$b\033[0m ..."
                            rm -rf $srcy/$b/ 2>/dev/null
                            if ! [ $? -eq 0 ];then echo -e "- Unable to remove \033[1m$srcy/$b\033[0m ...";exit 1;fi
                        fi
                    fi
                fi
            else
                echo -e " * Okay..then stay with \033[1mold\033[0m stuffs..."
                exit 1
            fi
        fi
        echo "---------------------------------------------"
        echo -ne "Press \033[1menter\033[0m to begin cloning ..."
        read enterkey
        if [ "$cho" = "y" -o "$cho" = "Y" ];then
            echo "---------------------------------------------"
            echo -e "Cloning \033[1mdevice\033[0m tree..."
            echo "---------------------------------------------"
            git clone -b $b --single-branch $sy/android_device_yu_lettuce.git $srcy/$b/device/yu/lettuce
            echo "---------------------------------------------"
            echo -e "Cloning \033[1mkernel\033[0m tree..."
            echo "---------------------------------------------"
            git clone -b $b --single-branch $sy/android_kernel_cyanogen_msm8916.git $srcy/$b/kernel/cyanogen/msm8916
            echo "---------------------------------------------"
            echo -e "Cloning \033[1mvendor_yu\033[0m tree..."
            echo "---------------------------------------------"
            git clone -b $b --single-branch $sy/proprietary_vendor_yu.git $srcy/$b/vendor/yu
        else
            echo "---------------------------------------------"
            echo -e "Cloning \033[1mdevice\033[0m tree..."
            echo "---------------------------------------------"
            git clone -b $b --single-branch $s/android_device_yu_lettuce.git $src/$b/device/yu/lettuce
            echo "---------------------------------------------"
            echo -e "Cloning \033[1mkernel\033[0m tree..."
            echo "---------------------------------------------"
            git clone -b $b --single-branch $s/android_kernel_cyanogen_msm8916.git $src/$b/kernel/cyanogen/msm8916
            echo "---------------------------------------------"
            echo -e "Cloning \033[1mvendor_yu\033[0m tree..."
            echo "---------------------------------------------"
            git clone -b $b --single-branch https://github.com/TheMuppets/proprietary_vendor_yu.git $src/$b/vendor/yu
        fi
        echo "---------------------------------------------"
        echo -e "Cloning \033[1mShared\033[0m tree..."
        echo "---------------------------------------------"
        git clone -b $b --single-branch $s/android_device_cyanogen_msm8916-common.git $src/$b/device/cyanogen/msm8916-common
        echo "---------------------------------------------"
        echo -e "Cloning \033[1mandroid_device_qcom_sepolicy\033[0m..."
        echo "---------------------------------------------"
        git clone -b $b --single-branch $s/android_device_qcom_sepolicy.git $src/$b/device/qcom/sepolicy
        echo "---------------------------------------------"
        echo -e "Cloning \033[1mqcom_common\033[0m tree..."
        echo "---------------------------------------------"
        git clone -b $b --single-branch $s/android_device_qcom_common.git $src/$b/device/qcom/common
        #if ! [ "$b" = "cm-13.0" -o "$b" = "cm-12.1" ];then
        #    echo "---------------------------------------------"
        #    echo "Cloning qcom_binaries..."
        #    echo "---------------------------------------------"
        #    git clone -b $b --single-branch https://github.com/TheMuppets/proprietary_vendor_qcom_binaries.git $src/$b/vendor/qcom/binaries
        #fi
        if [ "$s" = "https://github.com/LineageOS" ];then
            #echo "---------------------------------------------"
            echo -e "Cloning \033[1mqcom_opensource\033[0m..."
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
#        echo "---------------------------------------------"
#        echo -e "Cloning \033[1maudio-caf\033[0m tree..."
#        echo "---------------------------------------------"
#        git clone -b $br --single-branch $s/android_hardware_qcom_audio.git $src/$b/hardware/qcom/audio-caf/msm8916
#        echo "---------------------------------------------"
#        echo -e "Cloning \033[1mdisplay-caf\033[0m tree..."
#        echo "---------------------------------------------"
#        git clone -b $br --single-branch $s/android_hardware_qcom_display.git $src/$b/hardware/qcom/display-caf/msm8916
#        echo "---------------------------------------------"
#        echo "Cloning media-caf tree..."
#        echo "---------------------------------------------"
#        git clone -b $br --single-branch $s/android_hardware_qcom_media.git $src/$b/hardware/qcom/media-caf/msm8916
#        echo "---------------------------------------------"
#        echo "Cloning ril-caf tree..."
#        echo "---------------------------------------------"
#        git clone -b $brc --single-branch $s/android_hardware_ril.git $src/$b/hardware/ril-caf
#        echo "---------------------------------------------"
#       echo "Cloning wlan-caf tree..."
#        echo "---------------------------------------------"
#        git clone -b $brc --single-branch $s/android_hardware_qcom_wlan.git $src/$b/hardware/qcom/wlan-caf
#        echo "---------------------------------------------"
#        echo "Cloning bt-caf tree..."
#        echo "---------------------------------------------"
#        git clone -b $brc --single-branch $s/android_hardware_qcom_bt.git $src/$b/hardware/qcom/bt-caf
        echo "---------------------------------------------"
#        if ! [ -e $HOME/workspace/lettuce-trees/kernel.mk ]; then
#            wget -qO $HOME/workspace/lettuce-trees/kernel.mk https://github.com/AOSIP/platform_build/raw/n-mr1/core/tasks/kernel.mk
#        fi
    exit 1
    ;;
    -tc)
        echo -e "\t\033[1mToolchains\033[0m Available for Download"
        echo "---------------------------------------------"
        echo -e "1.\t\033[1mSabermod\033[0m v4.9\n2.\t\033[1mUber\033[0m v4.9\n3.\t\033[1mLinaro\033[0m v4.9\n4.\t\033[1mSDClang\033[0m v3.8"
        echo "---------------------------------------------"
        echo -en "Which \033[1mtoolchain\033[0m do you want (\033[1m1/2/3/4\033[0m)? "
        read tc
        echo "---------------------------------------------"
        case "$tc" in
            4)
                if [ -d $HOME/workspace/toolchains/sdclang-3.8 ];then
                    echo -e "\033[1mSDClang v3.8\033[0m already available..."
                    exit 1
                else
                    echo -e "Cloning \033[1mSDClang\033[0m v3.8..."
                    echo "---------------------------------------------"
                    git clone https://github.com/sachinOraon/sdclang.git $HOME/workspace/toolchains/sdclang-3.8
                    echo "---------------------------------------------"
                fi
                exit 1
                ;;
            1)
                if ! [ -e $HOME/workspace/toolchains/sabermod-aarch64-linux-android-4.9/sb.dat ]; then
                    echo -e "Cloning \033[1mSaberMod 4.9\033[0m Toolchain..."
                    echo "---------------------------------------------"
                    git clone -b sabermod --single-branch https://bitbucket.org/xanaxdroid/aarch64-linux-android-4.9.git $HOME/workspace/toolchains/sabermod-aarch64-linux-android-4.9
                    touch $HOME/workspace/toolchains/sabermod-aarch64-linux-android-4.9/sb.dat
                    echo "---------------------------------------------"
                else
                    echo -e "\033[1mSaberMod 4.9\033[0m Toolchain already available..."
                    echo "---------------------------------------------"
                fi
                exit 1
                ;;
            2)
                if ! [ -e $HOME/workspace/toolchains/ubertc-aarch64-linux-android-4.9/ub.dat ]; then
                    echo -e "Cloning \033[1mUber 4.9\033[0m Toolchain..."
                    echo "---------------------------------------------"
                    git clone https://bitbucket.org/UBERTC/aarch64-linux-android-4.9.git $HOME/workspace/toolchains/ubertc-aarch64-linux-android-4.9
                    touch $HOME/workspace/toolchains/ubertc-aarch64-linux-android-4.9/ub.dat
                    echo "---------------------------------------------"
                else
                    echo -e "\033[1mUber 4.9\033[0m Toolchain already available..."
                    echo "---------------------------------------------"
                fi
                exit 1
                ;;
            3)
                if ! [ -e $HOME/workspace/toolchains/linaro-aarch64-linux-android-4.9/ln.dat ]; then
                    echo -e "Cloning \033[1mLinaro 4.9\033[0m Toolchain..."
                    echo "---------------------------------------------"
                    git clone -b linaro --single-branch https://bitbucket.org/xanaxdroid/aarch64-linux-android-4.9.git $HOME/workspace/toolchains/linaro-aarch64-linux-android-4.9
                    touch $HOME/workspace/toolchains/linaro-aarch64-linux-android-4.9/ln.dat
                    echo "---------------------------------------------"
                else
                    echo -e "\033[1mLinaro 4.9\033[0m Toolchain already available..."
                    echo "---------------------------------------------"
                fi
                exit 1
                ;;
            *)
                echo -e " * \033[1mInvaild\033[0m Choice !"
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
        echo -e "\t\033[1mToolchains Selection\033[0m"
        echo "---------------------------------------------"
        echo -e "1.\t\033[1mSabermod\033[0m v4.9\n2.\t\033[1mUber\033[0m v4.9\n3.\t\033[1mLinaro\033[0m v4.9\n4.\t\033[1mSDClang\033[0m v3.8.8\n5.\t\033[1mRestore\033[0m Toolchain"
        echo "---------------------------------------------"
        curr=$(ls $romdir/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9/*.dat|cut -d "/" -f 11- 2>/dev/null)
        case "$curr" in
            def.dat) echo -e "Current Toolchain\t[\033[1mDEFAULT\033[0m]";;
            sb.dat) echo -e "Current Toolchain\t[\033[1mSABERMOD\033[0m]";;
            ln.dat) echo -e "Current Toolchain\t[\033[1mLINARO\033[0m]";;
            ub.dat) echo -e "Current Toolchain\t[\033[1mUBERTC\033[0m]";;
            *) echo -e "Current Toolchain\t[\033[1mUNABLE TO FIND\033[0m]";;
        esac
        sdc=`grep -i -c "SDCLANG" $romdir/device/yu/lettuce/BoardConfig.mk`
        if [ -d $romdir/prebuilts/clang/linux-x86/host/sdclang-3.8 ];then
            if [ $sdc -gt 0 ];then
                if [ -e $romdir/device/qcom/common/sdllvm-lto-defs.mk ];then
                    echo -e "\033[1mSDclang\033[0m 3.8\t\t[\033[1mENABLED\033[0m]"
                fi
            else
                echo -e "\033[1mSDclang\033[0m 3.8\t\t[\033[1mDISABLED\033[0m]"
            fi
        else
            echo -e "\033[1mSDclang\033[0m 3.8\t\t[\033[1mDISABLED\033[0m]"
        fi
        echo "---------------------------------------------"
        echo -en "Which \033[1mtoolchain\033[0m do you want (\033[1m1/2/3/4/5\033[0m)? "
        read ch
        echo "---------------------------------------------"
        case "$ch" in
            4)
                if [ -e $romdir/device/yu/lettuce/branch.dat ];then
                br=`cat $romdir/device/yu/lettuce/branch.dat`
                if ! [ "$br" = "cm-14.1" ];then
                    echo -e "\033[1mSnapdragon LLVM ARM Compiler\033[0m is \033[1mNOT\033[0m for \033[1mcm-13.0\033[0m or \033[1mcm-12.1\033[0m"
                    exit 1
                else
                if ! [ -d $romdir/prebuilts/clang/linux-x86/host/sdclang-3.8 ];then
                    if ! [ -d $HOME/workspace/toolchains/sdclang-3.8 ];then
                        echo -e " * SDClang \033[1mnot\033[0m found\n  Please run \033[1m./setup_lettuce.sh -tc\033[0m to download..."
                        exit 1
                    else
                        echo -e "Enabling \033[1mSnapdragon LLVM ARM Compiler\033[0m 3.8.8"
                        mkdir -p $romdir/prebuilts/clang/linux-x86/host/sdclang-3.8
                        cp -r $HOME/workspace/toolchains/sdclang-3.8/* $romdir/prebuilts/clang/linux-x86/host/sdclang-3.8
                        if [ $? -eq 0 ];then echo -e " * \033[1mSDClang\033[0m copied successfully";else echo -e " * \033[1mUnable\033[0m to copy SDClang !!";fi
                        if ! [ -e $romdir/device/qcom/common/sdllvm-lto-defs.mk ];then
                            echo -e " * Creating \033[1msdllvm-lto-defs.mk\033[0m in \033[1mdevice/qcom/common\033[0m"
                            wget -qO $romdir/device/qcom/common/sdllvm-lto-defs.mk https://github.com/LineageOS/android_device_qcom_common/raw/cm-14.1/sdllvm-lto-defs.mk
                            if [ $? -eq 0 ];then echo -e " * sdllvm-lto-defs.mk \033[1mcreated\033[0m";else echo -e " * \033[1mFailed\033[0m to create sdllvm-lto-defs.mk";fi
                        else
                            echo -e " * \033[1msdllvm-lto-defs.mk\033[0m Found"
                        fi
                        chk=`grep -i -c "SDCLANG" $romdir/device/yu/lettuce/BoardConfig.mk`
                        if [ $chk -eq 0 ];then
                            echo -e " * Creating backup of \033[1mBoardconfig.mk\033[0m"
                            cp $romdir/device/yu/lettuce/BoardConfig.mk $romdir/device/yu/lettuce/BoardConfig.mk.bak 2>/dev/null
                            echo -e " * \033[1mModifying\033[0m Boardconfig.mk"
                            echo -e "\nSDCLANG := true\nSDCLANG_PATH := prebuilts/clang/linux-x86/host/sdclang-3.8/bin\nSDCLANG_LTO_DEFS := device/qcom/common/sdllvm-lto-defs.mk">>$romdir/device/yu/lettuce/BoardConfig.mk
                            if ! [ `grep -i -c "SDCLANG" $romdir/device/yu/lettuce/BoardConfig.mk` ]; then echo -e " * \033[1mUnable\033[0m to modify BoardConfig.mk";else echo -e " * \033[1mDONE\033[1m";fi
                        else
                            echo -e " * \033[1mBoardConfig.mk\033[0m already modified\n * \033[1mDONE\033[1m"
                        fi
                    fi
                else
                    echo -en "Do you want to Disable \033[1mSDClang\033[0m (\033[1mY/N\033[0m)? "
                    read y
                    if [ "$y" = "Y" -o "$y" = "y" ];then
                        echo -e " * Removing \033[1mprebuilts/clang/linux-x86/host/sdclang-3.8\033[0m"
                        rm -rf $romdir/prebuilts/clang/linux-x86/host/sdclang-3.8 2>/dev/null
                        echo -e " * Removing \033[1msdllvm-lto-defs.mk\033[0m"
                        rm -f $romdir/device/qcom/common/sdllvm-lto-defs.mk 2>/dev/null
                        echo -e " * Restoring \033[1mBoardConfig.mk\033[0m"
                        if [ -e $romdir/device/yu/lettuce/BoardConfig.mk.bak ];then
                            rm $romdir/device/yu/lettuce/BoardConfig.mk
                            mv $romdir/device/yu/lettuce/BoardConfig.mk.bak $romdir/device/yu/lettuce/BoardConfig.mk
                            if [ $? -eq 0 ];then echo -e " * \033[1mDONE\033[0m";else echo -e " * \033[1mFAILED\033[0m";fi
                        else
                            echo -e " * \033[1mNO\033[0m backup found.."
                        fi
                    else
                        echo -e "Okay...let that \033[1msurvive\033[0m !!"
                    fi
                fi
                fi
            else
                echo -e " * Please run \033[1m./setup_lettuce -ct\033[0m first."
            fi
                exit 1
            ;;
            1)
                if [ -e $HOME/workspace/toolchains/sabermod-aarch64-linux-android-4.9/sb.dat ];then
                    echo -e "Copying \033[1mSaberMod\033[0m toolchain..."
                    echo "---------------------------------------------"
                    if ! [ -e $romdir/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9/def.dat ];then
                        if [ -e $romdir/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9/sb.dat ];then
                            echo -e "Sabermod\t[\033[1mACTIVATED\033[0m]"
                            echo "---------------------------------------------"
                        else
                            if [ -e $romdir/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9/ub.dat ];then
                                mv $romdir/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9 $romdir/prebuilts/gcc/linux-x86/aarch64/ubertc-aarch64-linux-android-4.9 &>/dev/null
                                if [ -e $romdir/prebuilts/gcc/linux-x86/aarch64/sabermod-aarch64-linux-android-4.9/sb.dat ];then
                                    mv $romdir/prebuilts/gcc/linux-x86/aarch64/sabermod-aarch64-linux-android-4.9 $romdir/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9 &>/dev/null
                                    if [ $? -gt 0 ];then echo -e "- SaberMod\t\t[\033[1mFAILED\033[0m]";else echo -e "- SaberMod\t\t[\033[1mSUCCESS\033[0m]";fi
                                else
                                    cp -r $HOME/workspace/toolchains/sabermod-aarch64-linux-android-4.9 $romdir/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9 &>/dev/null
                                    if [ $? -gt 0 ];then echo -e "- SaberMod\t\t[\033[1mFAILED\033[0m]";else echo -e "- SaberMod\t\t[\033[1mSUCCESS\033[0m]";fi
                                fi
                            else
                                if [ -e $romdir/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9/ln.dat ];then
                                    mv $romdir/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9 $romdir/prebuilts/gcc/linux-x86/aarch64/linaro-aarch64-linux-android-4.9 &>/dev/null
                                    if [ -e $romdir/prebuilts/gcc/linux-x86/aarch64/sabermod-aarch64-linux-android-4.9/sb.dat ];then
                                        mv $romdir/prebuilts/gcc/linux-x86/aarch64/sabermod-aarch64-linux-android-4.9 $romdir/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9 &>/dev/null
                                        if [ $? -gt 0 ];then echo -e "- SaberMod\t\t[\033[1mFAILED\033[0m]";else echo -e "- SaberMod\t\t[\033[1mSUCCESS\033[0m]";fi
                                    else
                                        cp -r $HOME/workspace/toolchains/sabermod-aarch64-linux-android-4.9 $romdir/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9 &>/dev/null
                                        if [ $? -gt 0 ];then echo -e "- SaberMod\t\t[\033[1mFAILED\033[0m]";else echo -e "- SaberMod\t\t[\033[1mSUCCESS\033[0m]";fi
                                    fi
                                fi
                            fi
                        fi
                    else
                        mv $romdir/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9 $romdir/prebuilts/gcc/linux-x86/aarch64/default-aarch64-linux-android-4.9 &>/dev/null
                        if [ -e $romdir/prebuilts/gcc/linux-x86/aarch64/sabermod-aarch64-linux-android-4.9/sb.dat ];then
                            mv $romdir/prebuilts/gcc/linux-x86/aarch64/sabermod-aarch64-linux-android-4.9 $romdir/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9 &>/dev/null
                            if [ $? -gt 0 ];then echo -e "- SaberMod\t\t[\033[1mFAILED\033[0m]";else echo -e "- SaberMod\t\t[\033[1mSUCCESS\033[0m]";fi
                        else
                            cp -r $HOME/workspace/toolchains/sabermod-aarch64-linux-android-4.9 $romdir/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9 &>/dev/null
                            if [ $? -gt 0 ];then echo -e "- SaberMod\t\t[\033[1mFAILED\033[0m]";else echo -e "- SaberMod\t\t[\033[1mSUCCESS\033[0m]";fi
                        fi
                    fi
                else
                    echo -e "\033[1mSabermod\033[0m TC isn't available on \033[1m$HOME/workspace/toolchain\033[0m...\nPlease run \033[1m./lettuce.sh -tc\033[0m and select \033[1mSaberMod\033[0m from there to \033[1mdownload\033[0m.\n---------------------------------------------"
                fi
                exit 1
                ;;
            2)
            if [ -e $HOME/workspace/toolchains/ubertc-aarch64-linux-android-4.9/ub.dat ];then
                echo -e "Copying Uber Toolchain..."
                echo "---------------------------------------------"
                if ! [ -e $romdir/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9/def.dat ];then
                    if [ -e $romdir/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9/ub.dat ];then
                        echo -e "UberTC\t\t[\033[1mACTIVATED\033[0m]"
                        echo "---------------------------------------------"
                    else
                        if [ -e $romdir/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9/sb.dat ];then
                            mv $romdir/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9 $romdir/prebuilts/gcc/linux-x86/aarch64/sabermod-aarch64-linux-android-4.9 &>/dev/null
                            if [ -e $romdir/prebuilts/gcc/linux-x86/aarch64/ubertc-aarch64-linux-android-4.9/ub.dat ];then
                                mv $romdir/prebuilts/gcc/linux-x86/aarch64/ubertc-aarch64-linux-android-4.9 $romdir/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9 &>/dev/null
                                if [ $? -gt 0 ];then echo -e "- UberTC\t\t[\033[1mFAILED\033[0m]";else echo -e "- UberTC\t\t[\033[1mSUCCESS\033[0m]";fi
                            else
                                cp -r $HOME/workspace/toolchains/ubertc-aarch64-linux-android-4.9 $romdir/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9 &>/dev/null
                                if [ $? -gt 0 ];then echo -e "- UberTC\t\t[\033[1mFAILED\033[0m]";else echo -e "- UberTC\t\t[\033[1mSUCCESS\033[0m]";fi
                            fi
                        else
                            if [ -e $romdir/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9/ln.dat ];then
                                mv $romdir/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9 $romdir/prebuilts/gcc/linux-x86/aarch64/linaro-aarch64-linux-android-4.9 &>/dev/null
                                if [ -e $romdir/prebuilts/gcc/linux-x86/aarch64/ubertc-aarch64-linux-android-4.9/ub.dat ];then
                                    mv $romdir/prebuilts/gcc/linux-x86/aarch64/ubertc-aarch64-linux-android-4.9 $romdir/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9 &>/dev/null
                                    if [ $? -gt 0 ];then echo -e "- UberTC\t\t[\033[1mFAILED\033[0m]";else echo -e "- UberTC\t\t[\033[1mSUCCESS\033[0m]";fi
                                else
                                    cp -r $HOME/workspace/toolchains/ubertc-aarch64-linux-android-4.9 $romdir/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9 &>/dev/null
                                    if [ $? -gt 0 ];then echo -e "- UberTC\t\t[\033[1mFAILED\033[0m]";else echo -e "- UberTC\t\t[\033[1mSUCCESS\033[0m]";fi
                                fi
                            fi
                        fi
                    fi
                else
                    mv $romdir/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9 $romdir/prebuilts/gcc/linux-x86/aarch64/default-aarch64-linux-android-4.9 &>/dev/null
                    if [ -e $romdir/prebuilts/gcc/linux-x86/aarch64/ubertc-aarch64-linux-android-4.9/ub.dat ];then
                        mv $romdir/prebuilts/gcc/linux-x86/aarch64/ubertc-aarch64-linux-android-4.9 $romdir/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9 &>/dev/null
                        if [ $? -gt 0 ];then echo -e "- UberTC\t\t[\033[1mFAILED\033[0m]";else echo -e "- UberTC\t\t[\033[1mSUCCESS\033[0m]";fi
                    else
                        cp -r $HOME/workspace/toolchains/ubertc-aarch64-linux-android-4.9 $romdir/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9 &>/dev/null
                        if [ $? -gt 0 ];then echo -e "- UberTC\t\t[\033[1mFAILED\033[0m]";else echo -e "- UberTC\t\t[\033[1mSUCCESS\033[0m]";fi
                    fi
                fi
            else
                echo -e "UberTC isn't available on $HOME/workspace/toolchain...\nPlease run ./lettuce.sh -tc and select UberTC from there to download.\n---------------------------------------------"
            fi
                exit 1
                ;;
            3)
            if [ -e $HOME/workspace/toolchains/linaro-aarch64-linux-android-4.9/ln.dat ];then
                echo -e "Copying Linaro Toolchain..."
                echo "---------------------------------------------"
                if ! [ -e $romdir/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9/def.dat ];then
                    if [ -e $romdir/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9/ub.dat ];then
                        mv $romdir/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9 $romdir/prebuilts/gcc/linux-x86/aarch64/ubertc-aarch64-linux-android-4.9 &>/dev/null
                        if [ -e $romdir/prebuilts/gcc/linux-x86/aarch64/linaro-aarch64-linux-android-4.9/ln.dat ];then
                            mv $romdir/prebuilts/gcc/linux-x86/aarch64/linaro-aarch64-linux-android-4.9 $romdir/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9 &>/dev/null
                            if [ $? -gt 0 ];then echo -e "- Linaro\t\t[\033[1mFAILED\033[0m]";else echo -e "- Linaro\t\t[\033[1mSUCCESS\033[0m]";fi
                        else
                            cp -r $HOME/workspace/toolchains/linaro-aarch64-linux-android-4.9 $romdir/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9 &>/dev/null
                            if [ $? -gt 0 ];then echo -e "- Linaro\t\t[\033[1mFAILED\033[0m]";else echo -e "- Linaro\t\t[\033[1mSUCCESS\033[0m]";fi
                        fi
                    else
                        if [ -e $romdir/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9/sb.dat ];then
                            mv $romdir/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9 $romdir/prebuilts/gcc/linux-x86/aarch64/sabermod-aarch64-linux-android-4.9 &>/dev/null
                            if [ -e $romdir/prebuilts/gcc/linux-x86/aarch64/linaro-aarch64-linux-android-4.9/ln.dat ];then
                                mv $romdir/prebuilts/gcc/linux-x86/aarch64/linaro-aarch64-linux-android-4.9 $romdir/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9 &>/dev/null
                                if [ $? -gt 0 ];then echo -e "- Linaro\t\t[\033[1mFAILED\033[0m]";else echo -e "- Linaro\t\t[\033[1mSUCCESS\033[0m]";fi
                            else
                                cp -r $HOME/workspace/toolchains/linaro-aarch64-linux-android-4.9 $romdir/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9 &>/dev/null
                                if [ $? -gt 0 ];then echo -e "- Linaro\t\t[\033[1mFAILED\033[0m]";else echo -e "- Linaro\t\t[\033[1mSUCCESS\033[0m]";fi
                            fi
                        else
                            if [ -e $romdir/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9/ln.dat ];then
                                echo -e "Linaro\t\t[\033[1mACTIVATED\033[0m]"
                                echo "---------------------------------------------"
                            fi
                        fi
                    fi
                else
                    mv $romdir/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9 $romdir/prebuilts/gcc/linux-x86/aarch64/default-aarch64-linux-android-4.9 &>/dev/null
                    if [ -e $romdir/prebuilts/gcc/linux-x86/aarch64/linaro-aarch64-linux-android-4.9/ln.dat ];then
                        mv $romdir/prebuilts/gcc/linux-x86/aarch64/linaro-aarch64-linux-android-4.9 $romdir/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9 &>/dev/null
                        if [ $? -gt 0 ];then echo -e "- Linaro\t\t[\033[1mFAILED\033[0m]";else echo -e "- Linaro\t\t[\033[1mSUCCESS\033[0m]";fi
                    else
                        cp -r $HOME/workspace/toolchains/linaro-aarch64-linux-android-4.9 $romdir/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9 &>/dev/null
                        if [ $? -gt 0 ];then echo -e "- Linaro\t\t[\033[1mFAILED\033[0m]";else echo -e "- Linaro\t\t[\033[1mSUCCESS\033[0m]";fi
                    fi
                fi
            else
                echo -e "Linaro TC isn't available on $HOME/workspace/toolchain...\nPlease run ./lettuce.sh -tc and select Linaro from there to download.\n---------------------------------------------"
            fi
                exit 1
                ;;
            5)
                echo -e "Restoring Toolchain..."
                echo "---------------------------------------------"
                if ! [ -e $romdir/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9/def.dat ];then
                    if [ -e $romdir/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9/ub.dat ];then
                        mv $romdir/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9 $romdir/prebuilts/gcc/linux-x86/aarch64/ubertc-aarch64-linux-android-4.9 &>/dev/null
                        mv $romdir/prebuilts/gcc/linux-x86/aarch64/default-aarch64-linux-android-4.9 $romdir/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9 &>/dev/null
                        if [ $? -gt 0 ];then echo -e "- Default\t\t[\033[1mFAILED\033[0m]";else echo -e "- Default\t\t[\033[1mRESTORED\033[0m]";fi
                    else
                        if [ -e $romdir/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9/sb.dat ];then
                            mv $romdir/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9 $romdir/prebuilts/gcc/linux-x86/aarch64/sabermod-aarch64-linux-android-4.9 &>/dev/null
                            mv $romdir/prebuilts/gcc/linux-x86/aarch64/default-aarch64-linux-android-4.9 $romdir/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9 &>/dev/null
                            if [ $? -gt 0 ];then echo -e "- Default\t\t[\033[1mFAILED\033[0m]";else echo -e "- Default\t\t[\033[1mRESTORED\033[0m]";fi
                        else
                            if [ -e $romdir/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9/ln.dat ];then
                                mv $romdir/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9 $romdir/prebuilts/gcc/linux-x86/aarch64/linaro-aarch64-linux-android-4.9 &>/dev/null
                                mv $romdir/prebuilts/gcc/linux-x86/aarch64/default-aarch64-linux-android-4.9 $romdir/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9 &>/dev/null
                                if [ $? -gt 0 ];then echo -e "- Default\t\t[\033[1mFAILED\033[0m]";else echo -e "- Default\t\t[\033[1mRESTORED\033[0m]";fi
                            fi
                        fi
                    fi
                else
                    echo -e "- Default Toolchain\t\t[\033[1mACTIVATED\033[0m]"
                fi
                exit 1
                ;;
            *)
                echo -e " * \033[1mInvaild\033[0m Choice !"
                exit 1
                ;;
        esac
        exit 1
        ;;
    -ct)
        echo "---------------------------------------------"
        echo -en "BRANCH (\033[1mL/M/N\033[0m) = "
        read b
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
                echo -e " * \033[1mInvalid\033[0m branch...!"
                exit 1
            ;;
        esac
        echo -en "SOURCE (\033[1mL/C\033[0m)   = "
        read s
        case "$s" in
            l|L)
                s="LineageOS"
                url="https://github.com/LineageOS"
                sy="YU-N"
            ;;
            c|C)
                s="CyanogenMod"
                url="https://github.com/CyanogenMod"
                sy="YU-N"
            ;;
            *)
                echo -e " * \033[1mInvalid\033[0m source...!"
                exit 1
            ;;
        esac
        if [ "$b" = "cm-14.1" ];then
            echo -en "Do you want \033[1mYU-N\033[0m trees also ?(Y/N) : "
            read choi
            if ! [ -e $HOME/workspace/lettuce-trees/$s/$b/device/yu/lettuce/Android.mk ];then
                echo -e "\033[1mYU-N\033[0m trees \033[1mnot\033[0m found...Please run \033[1m./setup_lettuce -st\033[0m"
                exit 1
            fi
        fi
        echo "---------------------------------------------"
        if [ "$choi" = "y" -o "$choi" = "Y" ];then
            echo -ne "Press \033[1menter\033[0m to begin Copying trees from\n * \033[1m$s/$b\033[0m\n * \033[1m$sy/$b\033[0m"
        else
            echo -ne "Press \033[1menter\033[0m to begin Copying trees from\n * \033[1m$s/$b\033[0m"
        fi
        read enterkey
        echo "---------------------------------------------"
        if [ -d $HOME/workspace/lettuce-trees/$s/$b ];then
            echo -e "Copying \033[1mdevice/yu/lettuce\033[0m"
            mkdir -p $romdir/device/
            mkdir -p $romdir/device/yu/
            mkdir -p $romdir/device/yu/lettuce
            if [ "$choi" = "y" -o "$choi" = "Y" ];then
                cp -r $HOME/workspace/lettuce-trees/$sy/$b/device/yu/lettuce/* $romdir/device/yu/lettuce
            else
                cp -r $HOME/workspace/lettuce-trees/$s/$b/device/yu/lettuce/* $romdir/device/yu/lettuce
            fi
            echo $b>$romdir/device/yu/lettuce/branch.dat 2>/dev/null
            if ! [ -e $romdir/device/yu/lettuce/device.mk ];then dt=1; else dt=0; fi
            echo "---------------------------------------------"
            echo -e "Copying \033[1mdevice/cyanogen/msm8916-common\033[0m"
            mkdir -p $romdir/device/cyanogen
            mkdir -p $romdir/device/cyanogen/msm8916-common
            cp -r $HOME/workspace/lettuce-trees/$s/$b/device/cyanogen/msm8916-common/* $romdir/device/cyanogen/msm8916-common
            if ! [ -e $romdir/device/cyanogen/msm8916-common/Android.mk ];then st=1; else st=0; fi
            echo "---------------------------------------------"
            if ! [ -e $romdir/device/qcom/common/Android.mk ];then
                mkdir -p $romdir/device/qcom
                mkdir -p $romdir/device/qcom/common
                echo -e "Copying \033[1mdevice/qcom/common\033[0m"
                cp -r $HOME/workspace/lettuce-trees/$s/$b/device/qcom/common/* $romdir/device/qcom/common
                if ! [ -e $romdir/device/qcom/common/Android.mk ];then qc=1;qc=0;fi
            else
                echo -e " * \033[1mdevice/qcom/common\033[0m already available..."
                qc=N
            fi
            echo "---------------------------------------------"
            if [ -d $romdir/device/qcom/common/cryptfs_hw ];then
                echo -e " * device/qcom/common/\033[1mcryptfs_hw\033[0m available..."
                grep -i "TARGET_CRYPTFS_HW_PATH " $romdir/system/vold/Android.mk
                flg1=1
            else
                flg1=0
            fi
            if [ -d $romdir/vendor/qcom/opensource/cryptfs_hw ];then
                echo -e " * vendor/qcom/opensource/\033[1mcryptfs_hw\033[0m available..."
                grep -i "TARGET_CRYPTFS_HW_PATH " $romdir/system/vold/Android.mk
                flg2=1
            else
                flg2=0
            fi
            if [ $flg1 -eq 1 -a $flg2 -eq 1 ];then
                echo -e " * \033[1mcryptfs_hw\033[0m is available on \033[1mmultiple places\033[0m\n   Please \033[1mremove one\033[0m of them."
                echo -e " * \033[1msystem/vold/Android.mk\033[0m --> \033[1m$( grep -i "TARGET_CRYPTFS_HW_PATH " $romdir/system/vold/Android.mk)\033[0m"
            else
                if [ $flg1 -eq 0 -a $flg2 -eq 0 ];then
                    echo -e " * \033[1mNO cryptfs_hw\033[0m directory found...!!!"
                    val=`grep -ci "TARGET_CRYPTFS_HW_PATH " $romdir/system/vold/Android.mk`
                    if [ $val -eq 1 ];then
                        path=`grep -i "TARGET_CRYPTFS_HW_PATH " $romdir/system/vold/Android.mk|cut -d "=" -f 2`
                        echo -e " * \033[1msystem/vold/Android.mk\033[0m --> \033[1m$( grep -i "TARGET_CRYPTFS_HW_PATH " $romdir/system/vold/Android.mk)\033[0m"
                        if [ "$s" = "CyanogenMod" ];then
                            git clone -qb $b $url/android_device_qcom_common.git $HOME/android_device_qcom_common
                            mkdir -p $path
                            cp -r $HOME/android_device_qcom_common/cryptfs_hw/* $path/ 2>/dev/null
                            if [ -e $path/cryptfs_hw.c ];then echo -e " * \033[1mcryptfs_hw\033[0m copied to \033[1m$path\033[0m";rm -r $HOME/android_device_qcom_common 2>/dev/null;else echo -e " * \033[1munable\033[0m to copy \033[1mcryptfs_hw\033[0m at \033[1m$path\033[0m";fi
                        fi
                        if [ "$s" = "LineageOS" ];then
                            git clone -qb $b $url/android_vendor_qcom_opensource_cryptfs_hw.git $path
                            if [ -e $path/cryptfs_hw.c ];then echo -e " * \033[1mcryptfs_hw\033[0m copied to \033[1m$path\033[0m";else echo -e " * \033[1munable\033[0m to copy \033[1mcryptfs_hw\033[0m at \033[1m$path\033[0m";fi
                        fi
                    else
                        echo -e " * \033[1mTARGET_CRYPTFS_HW_PATH = NULL\033[0m\n   You have to manually edit \033[1msystem/vold/Android.mk\033[0m"
                        git clone -qb $b https://github.com/LineageOS/android_vendor_qcom_opensource_cryptfs_hw.git $romdir/vendor/qcom/opensource/cryptfs_hw
                        if [ -e $romdir/vendor/qcom/opensource/cryptfs_hw/Android.mk ];then
                            echo -e "   \033[1mcryptfs_hw\033[0m cloned into \033[1mvendor/qcom/opensource/cryptfs_hw\033[0m"
                        else
                            echo -e "   Please clone \033[1mandroid_vendor_qcom_opensource_cryptfs_hw\033[0m"
                        fi
                    fi
                fi
            fi
            sleep 1
            echo "---------------------------------------------"
            echo -e "Copying \033[1mvendor/yu\033[0m"
            mkdir -p $romdir/vendor/yu
            if [ "$choi" = "y" -o "$choi" = "Y" ];then
                cp -r $HOME/workspace/lettuce-trees/$sy/$b/vendor/yu/* $romdir/vendor/yu
            else
                cp -r $HOME/workspace/lettuce-trees/$s/$b/vendor/yu/* $romdir/vendor/yu
            fi
            if ! [ -e $romdir/vendor/yu/lettuce/Android.mk ];then vt=1; else vt=0; fi
            echo "---------------------------------------------"
            echo -e "Copying \033[1mdevice/qcom/sepolicy\033[0m"
            if [ -d $romdir/device/qcom/sepolicy ];then
                echo -e " * device/qcom/sepolicy already \033[1mavailable\033[0m..."
                qs=N
            else
            #    mkdir -p $romdir/device/qcom
            #    mkdir -p $romdir/device/qcom/sepolicy
            #    cp -r $HOME/workspace/lettuce-trees/$s/$b/device/qcom/sepolicy/* $romdir/device/qcom/sepolicy
                git clone -qb $b $url/android_device_qcom_sepolicy.git device/qcom/sepolicy
                if [ -e $romdir/device/qcom/sepolicy/Android.mk ];then qs=0;else qs=1;fi
            fi
            echo "---------------------------------------------"
            echo -e "Copying \033[1mkernel/cyanogen/msm8916\033[0m"
            mkdir -p $romdir/kernel
            mkdir -p $romdir/kernel/cyanogen
            mkdir -p $romdir/kernel/cyanogen/msm8916
            if [ "$choi" = "y" -o "$choi" = "Y" ];then
                cp -r $HOME/workspace/lettuce-trees/$sy/$b/kernel/cyanogen/msm8916/* $romdir/kernel/cyanogen/msm8916
            else
                cp -r $HOME/workspace/lettuce-trees/$s/$b/kernel/cyanogen/msm8916/* $romdir/kernel/cyanogen/msm8916
            fi
            if ! [ -e $romdir/kernel/cyanogen/msm8916/AndroidKernel.mk ]; then kt=1; else kt=0; fi
            echo "---------------------------------------------"
            ctl=y
            while [ "$ctl" = "y" -o "$ctl" = "Y" ];do
                ls $romdir/vendor
                echo "---------------------------------------------"
                echo -en "Enter name of rom's \033[1mvendor\033[0m directory : "
                read vn
                echo "---------------------------------------------"
                if [ -d $romdir/vendor/$vn ];then
                    find $romdir/vendor/$vn -type f \( -name "*common*.mk" -o -name "*$vn*.mk" -o -name "main.mk" \) | cut --delimiter "/" --fields 6-
                else
                    echo -e "* \033[1mNO\033[0m such \033[1mdirectory\033[0m available...!!"
                fi
                echo "---------------------------------------------"
                echo -e "    (\033[1mSelect\033[0m from \033[1mabove list\033[0m)"
                echo -en "\033[1mHaven't\033[0m found required file...wanna \033[1mretry\033[0m(y/n) : "
                read ctl
                echo "---------------------------------------------"
            done
            echo $vn>$romdir/device/yu/lettuce/vendor.dat
            echo -en "Enter \033[1mpath/to/vendor/config/file\033[0m : "
            read vf
            echo "---------------------------------------------"
            echo -en "Want to inject \033[1mmore\033[0m(y/n) : "
            read inj
            echo "---------------------------------------------"
            if [ "$inj" = "y" -o "$inj" = "Y" ];then
                echo -en "Enter \033[1mpath/to/vendor/config/file\033[0m : "
                read svf
                echo "---------------------------------------------"
            fi
            sleep 1
            if ! [ -e $romdir/device/yu/lettuce/cm.mk ];then
                echo -e "* Creating \033[1m$(echo $vn).mk\033[0m"
                mv $romdir/device/yu/lettuce/lineage.mk $romdir/device/yu/lettuce/$(echo $vn).mk 2>/dev/null
                echo -e "* Creating \033[1mAndroidProducts.mk\033[0m"
                echo "PRODUCT_MAKEFILES := device/yu/lettuce/$(echo $vn).mk" > $romdir/device/yu/lettuce/AndroidProducts.mk
                echo "s/PRODUCT_NAME := lineage_lettuce/PRODUCT_NAME := $(echo $vn)_lettuce/">$romdir/tmp
                sed -f $romdir/tmp -i $romdir/device/yu/lettuce/$(echo $vn).mk
                rm $romdir/tmp
            else
                echo -e "* Creating \033[1m$(echo $vn).mk\033[0m"
                mv $romdir/device/yu/lettuce/cm.mk $romdir/device/yu/lettuce/$(echo $vn).mk 2>/dev/null
                echo -e "* Creating \033[1mAndroidProducts.mk\033[0m"
                echo "PRODUCT_MAKEFILES := device/yu/lettuce/$(echo $vn).mk" > $romdir/device/yu/lettuce/AndroidProducts.mk
                echo "s/PRODUCT_NAME := cm_lettuce/PRODUCT_NAME := $(echo $vn)_lettuce/">$romdir/tmp
                sed -f $romdir/tmp -i $romdir/device/yu/lettuce/$(echo $vn).mk
                rm $romdir/tmp
            fi
            if [ -z "$vf" ];then
                echo -e " * \033[1mNO\033[0m value given for \033[1mvendor file\033[0m..."
            else
                echo "s/vendor\/cm\/config\/common_full_phone.mk/">$romdir/tmp1
                echo "$(echo $vf)">$romdir/tmp2
                sed -i 's/\//\\\//g' $romdir/tmp2
                paste --delimiters "" $romdir/tmp1 $romdir/tmp2>$romdir/tmp
                sed -i 's/mk$/mk\//' $romdir/tmp
                sed -f $romdir/tmp -i $romdir/device/yu/lettuce/$(echo $vn).mk
                rm -r $romdir/tmp*
                flg=`grep -ci $(echo $vf) $romdir/device/yu/lettuce/$(echo $vn).mk`
                if ! [ $flg -eq 0 ];then echo -e "* inserted \033[1m$vf\033[0m";sleep 1;fi
                if [ -z "$svf" ];then
                    echo -e "* \033[1mNO\033[0m value given for \033[1m2nd\033[0m vendor file..."
                else
                    echo $vf>$romdir/tmp1
                    echo $svf>$romdir/tmp2
                    sed -i 's/\//\\\//g' $romdir/tmp1
                    sed -i 's/\//\\\//g' $romdir/tmp2
                    echo "/$(cat $romdir/tmp1)/a ">$romdir/tmp3
                    echo "\$(call inherit-product, $(cat $romdir/tmp2))">$romdir/tmp4
                    paste --delimiters "" $romdir/tmp3 $romdir/tmp4>$romdir/tmp5
                    sed -f $romdir/tmp5 -i $romdir/device/yu/lettuce/$(echo $vn).mk
                    rm -r $romdir/tmp*
                    flg=`grep -ci $(echo $svf) $romdir/device/yu/lettuce/$(echo $vn).mk`
                    if ! [ $flg -eq 0 ];then echo -e "* inserted \033[1m$svf\033[0m";fi
                fi
                sleep 1
                if [ -e $romdir/vendor/$vn/config/common_full_phone.mk ];then
                    echo $vf>$romdir/tmp1
                    sed -i 's/\//\\\//g' $romdir/tmp1
                    echo " \$(call inherit-product, vendor\/$(echo $vn)\/config\/common_full_phone.mk)">$romdir/tmp2
                    echo "/$(cat $romdir/tmp1)/a ">$romdir/tmp3
                    paste --delimiters "" $romdir/tmp3 $romdir/tmp2>$romdir/tmp4
                    sed -f $romdir/tmp4 -i $romdir/device/yu/lettuce/$(echo $vn).mk
                    flg=`grep -ci vendor/$(echo $vn)/config/common_full_phone.mk $romdir/device/yu/lettuce/$(echo $vn).mk`
                    if ! [ $flg -eq 0 ];then echo -e "* inserted \033[1mvendor/$(echo $vn)/config/common_full_phone.mk\033[0m";fi
                    rm -r $romdir/tmp*
                fi
                if [ -e $romdir/vendor/$vn/configs/common_full_phone.mk ];then
                    echo $vf>$romdir/tmp1
                    sed -i 's/\//\\\//g' $romdir/tmp1
                    echo " \$(call inherit-product, vendor\/$(echo $vn)\/configs\/common_full_phone.mk)">$romdir/tmp2
                    echo "/$(cat $romdir/tmp1)/a ">$romdir/tmp3
                    paste --delimiters "" $romdir/tmp3 $romdir/tmp2>$romdir/tmp4
                    sed -f $romdir/tmp4 -i $romdir/device/yu/lettuce/$(echo $vn).mk
                    flg=`grep -ci vendor/$(echo $vn)/configs/common_full_phone.mk $romdir/device/yu/lettuce/$(echo $vn).mk`
                    if ! [ $flg -eq 0 ];then echo -e "* inserted \033[1mvendor/$(echo $vn)/configs/common_full_phone.mk\033[0m";fi
                    rm -r $romdir/tmp*
                fi
            fi
            echo "---------------------------------------------"
            if [ -e $romdir/vendor/$vn/sepolicy/file_contexts ];then
                flag=`grep -ci /data/misc/radio vendor/$vn/sepolicy/file_contexts`
                str=`grep -i /data/misc/radio vendor/$vn/sepolicy/file_contexts`
                flag2=`grep -ci /data/misc/radio device/qcom/sepolicy/common/file_contexts`
                if [ $flag -gt 0 -a $flag2 -gt 0 ];then
                    echo -e "* Please \033[1mremove\033[0m [ \033[1m$str\033[0m ]\n  from \033[1mvendor/$vn/sepolicy/file_contexts\033[0m to avoid \033[1merrors\033[0m."
                    echo "---------------------------------------------"
                fi
            fi
            sleep 1
            if [ -e $romdir/build/core/tasks/kernel.mk ];then
                mv $romdir/build/core/tasks/kernel.mk $romdir/kernel.mk.bak
                if [ -e $HOME/workspace/lettuce-trees/kernel.mk ];then
                    cp $HOME/workspace/lettuce-trees/kernel.mk $romdir/build/core/tasks/kernel.mk 2>/dev/null
                    if [ $? -lt 1 ];then echo -e "* \033[1mkernel.mk\033[0m file replaced.";else echo -e "\tkernel.mk file wasn't replaced.";fi
                else
                    wget --quiet -O $romdir/build/core/tasks/kernel.mk https://github.com/AOSIP/platform_build/raw/n-mr1/core/tasks/kernel.mk
                    if [ $? -lt 1 ];then echo -e "* \033[1mkernel.mk\033[0m file replaced.";else echo -e "\tkernel.mk file wasn't replaced.";fi
                fi
            else
                if [ -e $romdir/vendor/$vn/build/tasks/kernel.mk ];then
                    mv $romdir/vendor/$vn/build/tasks/kernel.mk $romdir/kernel.mk.bak
                    if [ -e $HOME/workspace/lettuce-trees/kernel.mk ];then
                        cp $HOME/workspace/lettuce-trees/kernel.mk $romdir/vendor/$vn/build/tasks/kernel.mk 2>/dev/null
                        if [ $? -lt 1 ];then echo -e "* \033[1mkernel.mk\033[0m file replaced.";else echo -e "\tkernel.mk file wasn't replaced.";fi
                    else
                        wget -qO $romdir/vendor/$vn/build/tasks/kernel.mk https://github.com/AOSIP/platform_build/raw/n-mr1/core/tasks/kernel.mk
                        if [ $? -lt 1 ];then echo -e "* \033[1mkernel.mk\033[0m file replaced.";else echo -e "\tkernel.mk file wasn't replaced.";fi
                    fi
                fi
            fi
            #echo "---------------------------------------------"
            echo -e "* Fixing \033[1mderps\033[0m..."
            sed -i '/PRODUCT_BRAND/D' $romdir/device/yu/lettuce/full_lettuce.mk
            sed -i '/PRODUCT_DEVICE/a PRODUCT_BRAND := YU' $romdir/device/yu/lettuce/$(echo $vn).mk
            sleep 1
            sed -i '/config_deviceHardwareKeys/D' $romdir/device/yu/lettuce/overlay/frameworks/base/core/res/res/values/config.xml
            sed -i '/config_deviceHardwareWakeKeys/D' $romdir/device/yu/lettuce/overlay/frameworks/base/core/res/res/values/config.xml
            sed -i '/config_comboNetworkLocationProvider/D' $romdir/device/yu/lettuce/overlay/frameworks/base/core/res/res/values/config.xml
            if ! [ `grep -i "MEASUREMENT_COUNT" $romdir/system/media/audio_effects/include/audio_effects/effect_visualizer.h|cut -d " " -f 2` ];then
                sed -i '/#define MEASUREMENT_IDX_RMS  1/a #define MEASUREMENT_COUNT 2' $romdir/system/media/audio_effects/include/audio_effects/effect_visualizer.h
            fi
            sleep 1
            if [ -e $romdir/device/yu/lettuce/board-info.txt ];then
                echo -e "* Fixing \033[1mAssertions\033[0m..."
                rm $romdir/device/yu/lettuce/board-info.txt 2>/dev/null
                if [ $? -eq 0 ];then echo -e "* device/yu/lettuce/board-info.txt \033[1mremoved\033[0m";else echo -e "* \033[1munable\033[0m to remove device/yu/lettuce/board-info.txt";fi
                sed -i '/TARGET_BOARD_INFO_FILE/d' $romdir/device/yu/lettuce/BoardConfig.mk
                er=`grep -ci TARGET_BOARD_INFO_FILE $romdir/device/yu/lettuce/BoardConfig.mk`
                if [ $er -eq 0 ];then echo -e "* \033[1mBoardConfig.mk\033[0m modified";else echo -e "* \033[1munable\033[0m to edit \033[1mBoardConfig.mk\033[0m";fi
            fi
            #echo "---------------------------------------------"
            echo -e "* Creating \033[1mvendorsetup.sh\033[0m"
            if [ -e $romdir/device/yu/lettuce/vendorsetup.sh ]; then rm $romdir/device/yu/lettuce/vendorsetup.sh 2>/dev/null;fi
            sleep 1
cat <<EOF>$romdir/device/yu/lettuce/vendorsetup.sh
add_lunch_combo $(echo $vn)_lettuce-userdebug
EOF
            #echo "---------------------------------------------"
            echo -e "* Creating \033[1m$(echo $vn)-build.sh\033[0m"
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
        rm -rf $HOME/.cache &>/dev/null
        if [ \$err -eq 0 ]
        then
            lunch $(echo $vn)_lettuce-userdebug
        fi
        sleep 1
        make clean && make installclean && make clobber
        sleep 1
        make otapackage -j$(echo $jobs)
        sleep 1
        if [ -e $(echo $romdir)/out/target/product/lettuce/*lettuce*.zip ];then
            source build/envsetup.sh &>/dev/null
            rom=\`lunch $(echo $vn)_lettuce-userdebug|grep -i $(echo $vn)_version|cut -d "=" -f 2\`
            l=\`echo \$rom|grep -ic lettuce\`
            if [ -n "\$rom" ];then
                if [ \$l -eq 0 ];then
                    mv $(echo $romdir)/out/target/product/lettuce/*lettuce*.zip $(echo $romdir)/\$(echo \$rom)_lettuce.zip
                else
                    mv $(echo $romdir)/out/target/product/lettuce/*lettuce*.zip $(echo $romdir)/\$(echo \$rom).zip
                fi
            else
                mv $(echo $romdir)/out/target/product/lettuce/*lettuce*.zip $(echo $romdir)/
            fi
        fi
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
        if [ -e $(echo $romdir)/out/target/product/lettuce/*lettuce*.zip ];then
            source build/envsetup.sh &>/dev/null
            rom=\`lunch $(echo $vn)_lettuce-userdebug|grep -i $(echo $vn)_version|cut -d "=" -f 2\`
            l=\`echo \$rom|grep -ic lettuce\`
            if [ -n "\$rom" ];then
                if [ \$l -eq 0 ];then
                    mv $(echo $romdir)/out/target/product/lettuce/*lettuce*.zip $(echo $romdir)/\$(echo \$rom)_lettuce.zip
                else
                    mv $(echo $romdir)/out/target/product/lettuce/*lettuce*.zip $(echo $romdir)/\$(echo \$rom).zip
                fi
            else
                mv $(echo $romdir)/out/target/product/lettuce/*lettuce*.zip $(echo $romdir)/
            fi
        fi
        ;;
esac
EOF
                chmod a+x $romdir/$(echo $vn)-build.sh
            fi
            #echo "---------------------------------------------"
            echo -e "* Creating \033[1mremove_trees.sh\033[0m"
            if [ -e $romdir/remove_trees.sh ]; then rm -f $romdir/remove_trees.sh &>/dev/null;fi
cat <<EOF>$romdir/remove_trees.sh
echo "---------------------------------------------"
rm -rf $HOME/.ccache &>/dev/null
rm -rf $HOME/.cache &>/dev/null
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
rm -rf $romdir/kernel/cyanogen/msm8916 &>/dev/null
echo "---------------------------------------------"
#echo "- Removing caf HAL trees..."
#rm -rf $romdir/hardware/qcom/audio-caf/msm8916 &>/dev/null
#rm -rf $romdir/hardware/qcom/display-caf/msm8916 &>/dev/null
#rm -rf $romdir/hardware/qcom/media-caf/msm8916 &>/dev/null
#echo "---------------------------------------------"
EOF
            chmod a+x $romdir/remove_trees.sh
            echo "---------------------------------------------"
            echo -e "* run \033[1m./setup_lettuce.sh -c\033[0m to copy \033[1mCAF-HAL\033[0m trees if needed."
            echo -e "* also run \033[1m./setup_lettuce.sh -f\033[0m to \033[1mfix\033[0m device tree if \033[1mlunch\033[0m fails."
            sleep 1
            echo "---------------------------------------------"
            echo -e "\t\033[1mLOG\033[0m"
            echo "---------------------------------------------"
            if [ "$dt" = "1" ]; then echo -e "- device tree\t\t\033[1m[\033[1mFAILED\033[0m]\033[0m";else echo -e "- device tree\t\t\033[1m[\033[1mSUCCESS\033[0m]\033[0m";fi
            if [ "$st" = "1" ]; then echo -e "- shared tree\t\t\033[1m[\033[1mFAILED\033[0m]\033[0m";else echo -e "- shared tree\t\t\033[1m[\033[1mSUCCESS\033[0m]\033[0m";fi
            if [ "$vt" = "1" ]; then echo -e "- vendor_yu\t\t\033[1m[\033[1mFAILED\033[0m]\033[0m";else echo -e "- vendor_yu\t\t\033[1m[\033[1mSUCCESS\033[0m]\033[0m";fi
            if [ "$kt" = "1" ]; then echo -e "- kernel tree\t\t\033[1m[\033[1mFAILED\033[0m]\033[0m";else echo -e "- kernel tree\t\t\033[1m[\033[1mSUCCESS\033[0m]\033[0m";fi
            if [ "$qs" = "1" ]; then
                echo -e "- qcom-sepolicy tree\t\033[1m[\033[1mFAILED\033[0m]\033[0m"
            elif [ "$qs" = "N" ]; then
                echo -e "- qcom-sepolicy tree\t\033[1m[NOT REQUIRED]\033[0m"
            else
                echo -e "- qcom-sepolicy tree\t\033[1m[\033[1mSUCCESS\033[0m]\033[0m"
            fi
            if [ "$qc" = "1" ]; then
                echo -e "- qcom-common tree\t\033[1m[\033[1mFAILED\033[0m]\033[0m"
            elif [ "$qc" = "N" ]; then
                echo -e "- qcom-common tree\t\033[1m[NOT REQUIRED]\033[0m"
            else
                echo -e "- qcom-common tree\t\033[1m[\033[1mSUCCESS\033[0m]\033[0m"
            fi
            echo "---------------------------------------------"
        else
            echo -e "- Please \033[1msetup trees\033[0m properly.\n- To do run \033[1m./setup_lettuce -st\033[0m"
        fi
        exit 1
        ;;
    *)
        echo -e "\t---------------------------------------------"
        echo -e "\t|               \033[1mHELP MENU\033[0m                   |"
        echo -e "\t---------------------------------------------"
        echo -e "\t|   \033[1m-j\033[0m     Switch jdk versions              |"
        echo -e "\t|   \033[1m-c\033[0m     Copy some caf HAL trees          |"
        echo -e "\t|   \033[1m-f\033[0m     To fix lunch error               |"
        echo -e "\t|   \033[1m-t\033[0m     Switch toolchain for compilation |"
        echo -e "\t|   \033[1m-st\033[0m    Download device trees for later  |"
        echo -e "\t|          use                              |"
        echo -e "\t|   \033[1m-ct\033[0m    Copy device trees to working-dir |"
        echo -e "\t|   \033[1m-tc\033[0m    Download toolchain for later use |"
        echo -e "\t---------------------------------------------"
        exit 1
        ;;
esac