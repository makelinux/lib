load-watch - kills memory and cpu hogs when load average is too high
====


``` bash
csi=$'\e['
load-watch()
{
	local nproc=$(getconf _NPROCESSORS_ONLN)
	echo
	while true; do
		echo -n ${csi}A
		echo -n $(date "+%T $SECONDS ") " "
		local load
		free=$( grep MemAvailable: /proc/meminfo | (read a b c d e; echo $((b/1024))) )
		IFS="/ " read -a load < /proc/loadavg
		local loadproc=$((10#${load/./}00/${nproc}00)) # '10#' is to force decimal, because 'load' starts from 0
		local pcpu=$(echo $(ps --no-headers -e -o pid,comm,pcpu --sort -%cpu | head -n 1))
		local pmem=$(echo $(ps --no-headers -e -o pid,comm,pmem --sort -%mem | head -n 1))
		echo -n "load=$load $loadproc% running=${load[3]} free=$free MB, $pcpu% cpu, $pmem% mem"
		echo "${csi}K"
		test -w /proc/${pcpu%% *}/oom_score_adj && echo 1000 > /proc/${pcpu%% *}/oom_score_adj
		test -w /proc/${pmem%% *}/oom_score_adj && echo 1000 > /proc/${pmem%% *}/oom_score_adj
		if [ \( ${load[3]} -gt $((1 * ${nproc})) \) -a \( $loadproc -gt 200 \) ]; then
			echo killing "${pcpu} "
			echo
			kill "${pcpu%% *}"
		fi
		if [ $free -lt 200 ]; then
			echo killing "${pmem} "
			echo
			kill "${pmem%% *}"
		fi
		SECONDS=0
		read -t 5
	done
}
```
