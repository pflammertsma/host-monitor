#!/bin/bash

host=$1
timeout=10
notification_timeout=0

down=-2

if [ -z $host ]; then
    echo "Usage: `basename $0` [HOST]"
    exit 1
fi

last=0

while :; do
    timestamp=$(date +%s)
	diff=$(($timestamp-$last))
    if [ $notification_timeout -gt 0 ] && [ $diff -gt $notification_timeout ]; then
    	last=$timestamp
        if [ $down -ne -2 ]; then
        	down=-1
        fi
	fi
    result=`ping -W 1 -c 1 $host | grep 'bytes from '`
    if [ $? -gt 0 ]; then
        echo -e "`date +'%Y/%m/%d %H:%M:%S'` - host $host is \033[0;31mdown\033[0m"
        if [ $down -ne 1 ]; then
            title="$host DOWN"
            msg="$host is not responding to ping"
            if [ $down -ne -1 ]; then
                notify-send --urgency=critical --icon=software-update-urgent "$title" "$msg"
            else
                notify-send "$msg"
            fi
        	down=1
    	fi
    	sleep $(($timeout-1))
    else
        echo -e "`date +'%Y/%m/%d %H:%M:%S'` - host $host is \033[0;32mok\033[0m -`echo $result | cut -d ':' -f 2`"
        if [ $down -ne 0 ]; then
            title="$host UP"
            msg="Host $host is responding to ping"
            if [ $down -ne -1 ]; then
                notify-send --urgency=critical --icon=emblem-default "$title" "$msg"
            else
                notify-send "$msg"
            fi
        	down=0
    	fi
        sleep $timeout # avoid ping rain
    fi
done
