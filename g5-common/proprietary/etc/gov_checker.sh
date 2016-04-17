#!/system/bin/sh

count=0
LOOP_COUNT=0
if [ "$#" -ne 2 ]; then
    LOOP_COUNT=5
else
    LOOP_COUNT=$2
fi

while [ "$count" -ne "$LOOP_COUNT" ]
do
    if [ "$(getprop dev.bootcomplete)" -eq "1" ]; then
        sleep $1
        interactive=0
        for i in 0 1 2 3
        do
            gov="$(cat /sys/devices/system/cpu/cpu$i/cpufreq/scaling_governor)"
            echo "[power_debug] cpu$i: $gov" > /dev/kmsg
            if [ "performance" == "$gov" ]; then
                echo "[power_debug] cpu$i's gov is $gov. Set interactive." > /dev/kmsg
                echo "interactive" > /sys/devices/system/cpu/cpu$i/cpufreq/scaling_governor
            elif [ "interactive" == "$gov" ]; then
                interactive=$(( interactive + 1 ))
            fi
        done
        echo "[power_debug] count = $count, $interactive" > /dev/kmsg
        if [ "$interactive" -eq "4" ]; then
            echo "[power_debug] gov_checker is done." > /dev/kmsg
            break
        fi
    else
        sleep $1
    fi
    count=$(( count + 1 ))
done
echo "If device satisfy belows, please send dmesg to H1-BSP-POWER@lge.com" > /dev/kmsg
echo "1. Device is cool enough." > /dev/kmsg
echo "2. Battery level > 30" > /dev/kmsg
echo "Thanks." > /dev/kmsg
