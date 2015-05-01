#!/bin/bash

timeout=10

while [[ $# > 1 ]]; do
    key="$1"
    case $key in
        -t|--timeout)
            timeout="$2"
            shift
        ;;
        *)
            # unknown option
        ;;
    esac
    shift
done

host=$1
notification_timeout=0

down=-2

if [ -z $host ]; then
    echo "Usage: `basename $0` [OPTION] HOST"
    echo "Where OPTION is any of:"
    echo "    -t, --timeout"
    echo "        timeout in milliseconds"
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
    fi
    now=$(date +%s)
    diff=$(($now-$timestamp))
    # avoid ping rain
    sleep $((timeout-diff))
done
