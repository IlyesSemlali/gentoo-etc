#!/bin/sh
# /etc/acpi/default.sh
# Default acpi script that takes an entry for all actions

set $*

group=${1%%/*}
action=${1#*/}
device=$2
id=$3
value=$4

log_unhandled() {
	logger "ACPI event unhandled: $*"
}

get_xsslock_pid () {
	ps axe | grep $1 | awk '{ if ($5 == "xss-lock") print $1 }'
}

get_open_displays() {
	for i in "$(w | grep 'tty.*xinit')"
	do
		echo $(w -s | awk -F '--' '{ print $2 }' | grep -o ':.')
	done
}

case "$group" in
	button)
		case "$action" in
			power)
				echo "$@" > /root/acpi_button
				;;

			lid)
				case $id in
					close)
						for DISPLAY in $(get_open_displays)
						do
							X_USER=$(ps aux | grep xinit | cut -d ' ' -f1 | head -n 1)
							kill $(get_xsslock_pid $DISPLAY) > /tmp/debug
							su $X_USER -c "xset dpms force off"
						done
						;;
					open)
						for DISPLAY in $(get_open_displays)
						do
							X_USER=$(ps aux | grep xinit | cut -d ' ' -f1 | head -n 1)
							su $X_USER -c "nohup xss-lock xlock > /dev/null" &
						done
						;;
				esac
				;;

			*)	log_unhandled $* ;;
		esac
		;;

	ac_adapter)
		case "$value" in
			# Add code here to handle when the system is unplugged
			# (maybe change cpu scaling to powersave mode).  For
			# multicore systems, make sure you set powersave mode
			# for each core!
			*0)
				cpufreq-set -g powersave
				;;

			# Add code here to handle when the system is plugged in
			# (maybe change cpu scaling to performance mode).  For
			# multicore systems, make sure you set performance mode
			# for each core!
			*1)
				cpufreq-set -g performance
				;;

			*)	log_unhandled $* ;;
		esac
		;;

	*)	log_unhandled $* ;;
esac
