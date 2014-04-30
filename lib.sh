#!/bin/bash

# Author: Constantine Shulyupin const@makelinux.com
#
# Copyright © 2013
#
# GPL License

usage="\
lib.sh - Library of shell functions
===
Usage:

Load commands to shell:
 . lib.sh

Run a command with subshell:
 lib.sh <command> <arguments...>
"

###############################################################################
#	Common stuff

MYSHELL=`/bin/ps -p $$ -o command=| sed "s:$0::;s:busybox ::"`
export tab=$'\t'

cmd()
{
	usage="$usage $1 - $2\n"
}

cmd lib_help "shows help for Lib.sh"
lib_help()
{
	echo -e "$usage"
}

###############################################################################
#	Short useful definitions and aliases

export GREP_OPTIONS="--devices=skip " # avoid hanging grep on devices
export GREP_COLORS='ms=01;38:mc=01;31:sl=02;38:cx=:fn=32:ln=32:bn=32:se=36' # print matched text in bold
export HISTIGNORE="&:ls:[bf]g:exit"

usage="$usage\nList of available commands:\n"

cmd ps-all "lists all processes"
alias ps-all='ps -AF'

cmd ps-threads "lists processes with threads"
alias ps-threads="ps -ALf"

cmd ps-tree "lists process tree via ps, see also pstree -p"
alias ps-tree="ps -ejH"

cmd ps-cpu "lists most CPU consuming processes"
alias ps-cpu="ps -e -o pcpu,pid,comm --sort -%cpu  | head -n 5"

cmd ps-mem "lists most memory consuming processes"
alias ps-mem="ps -e  -o pmem,vsz,rss,pid,comm --sort -%mem  | head -n 5"

cmd ps-wchan "shows what processes are waiting for, used in debugging blocked processes"
alias ps-wchan="ps -e -o pid,comm,wchan"

cmd ls_size "list files with sizes in bytes, shorter than ls -l"
#alias ls-size='ls -s --block-size=1 -1'
#alias ls-size='stat -c "%s$tab%n"'
ls_size() { stat -c "%s$tab%n" `\ls "$@"`; }

cmd mplayer-rotate-right "play video rotated right, used to play vertically captured videos"
alias mplayer-rotate-right="mplayer -vf rotate=1"

cmd hist "handy history, up to one screen length"
alias hist='history $((LINES-2))'

cmd deb-list "list content of specified deb file"
alias deb-list="dpkg-deb --contents"

ansi_rev=$'\e[7m'
ansi_norm=$'\e[0m'
cmd quotation_highlight "higlight text in quotation marks (\"quotation\")"
alias quotation_highlight=' sed "
	s|\\\\\\\\|:dbs:|g;
	s|\\\\\"|:bsq:|g;
	s|\\\\\"|:quotation:|g;
	s|\"\([^\"]*\?\)\"| $ansi_rev\1$ansi_norm |g;
	s|:quotation:|\\\\\"|g;
	s|:bsq:|\\\\\\\"|g;
	s|:dbs:|\\\\\\\\|g"'
cmd readline-bindings "shows current readline bindings, used as shell keyboard shortcuts, in more readable format, see also man readline"
alias readline-bindings='(bind -P | grep -v "is not bound" | nl |
	sed "
		s| can be found on|:|;
		s|.$||;
		s|, \+| |g;
		s|\\\C-|^|g
		s|\\\e|+|g;" \
		| pr --omit-header --expand-tabs --columns=2 -w $COLUMNS \
		| expand; \
		echo \"^\" = Ctrl, \"+\" = Escape) | quotation_highlight '

cmd tcpdump-text "tcpdump of payload in text"
alias tcpdump-text="sudo tcpdump -l -s 0 -A '(((ip[2:2] - ((ip[0]&0xf)<<2)) - ((tcp[12]&0xf0)>>2)) != 0)'"

cmd make-debug "verbose make"
alias make-debug="remake --debug=bv SHELL='/bin/bash -vx' "

# git helpers

cmd git-diff "handy git diff"
alias git-diff='git diff --relative --no-prefix -w'

cmd git-diff-HEAD "show the differences between your working directory and the most recent commit"
alias git-diff-HEAD="git diff HEAD"

cmd git-diff-last-commit "shows last git commit"
alias git-diff-last-commit="git log -p -n 1"

cmd git_prompt "sets shell prompt to show git branch"
git_prompt()
{
	PS1='[\u@\h \W$(__git_ps1 " (%s)")]\$ '
}

cmd git_fixup "interactive fixup of specified number of last git commits"
git_fixup()
{
	git rebase -i HEAD~$1 .
}

cmd git_ign_add "add files' names with path to appropriate .gitignore list"
git_ign_add()
{
	for a in $*;  do
		echo "$a"
		(cd `dirname "$a"`; \ls -d `basename "$a"` -1  >> .gitignore; git add .gitignore )
	done
}
cmd trap_err "traps command failures, print reuturn value and returns, better than set -o errexit"
trap_err()
{
	trap 'echo -e $"\e[2;31mFAIL \e[0;39m ret=$? ${BASH_SOURCE[0]}:${LINENO}" > /dev/stderr;return 2> /dev/null' ERR
}

###############################################################################
#	Shell functions

cmd system_status_short "shows short summary of system resources (RAM,CPU) usage"
system_status_short()
{
	echo "Available RAM: "$((`mem_avail_kb`/1024))"M" \
	       	$((100*`mem_avail_kb`/`head -1</proc/meminfo | sed "s/ \+/ /g" | cut -d' ' -f 2`))"%"
	paste <(mpstat|grep %usr|sed "s/ \+/\n/g") <(mpstat|grep all|sed "s/ \+/\n/g") | \grep -e idle -e iowait -e sys
	ps-cpu
	ps-mem
}

cmd system_status_long "shows long system status and statistics by running various system utilities"
system_status_long()
{
	grep "" /etc/issue /etc/*release
	top -bn1 | head --lines 20
	echo
	free -m
	echo
	iostat -m
	echo
	mpstat
	echo
	vmstat -S M -s
	echo
	df --all --human-readable
	echo
	lsblk
	echo
	lscpu
	echo
	lsusb
	echo
	lspci
	echo
	lshw -short
}

cmd shell_type "tries to identify type of current shell"
shell_type()
{
	# adopted from http://stackoverflow.com/questions/5166657/how-do-i-tell-what-type-my-shell-is
	# see also http://www.in-ulm.de/~mascheck/various/whatshell/whatshell.sh.html
	# also can be useful:
	# ps -p $$ -o comm=
	# ps -p $$ -o command=
	if test -n "$ZSH_VERSION"; then
		echo zsh
	elif test -n "$BASH_VERSION"; then
		echo bash
	elif test -n "$KSH_VERSION"; then
		echo ksh
	else
		/bin/ps -p $$ -o command=| sed "s@$0@@;s@busybox @@"
	fi
}

cmd ps_of "specified process info"
ps_of()
{
	# ps u -C "$1"
	ps u `pidof "$@"`
}

cmd proc_mem_usage "returns percentage memory usage by specified process"
proc_mem_usage()
{
	ps h -o pmem -C "$1"
}

cmd dir_diff "compare listings of two specified directories"
dir_diff()
{
	find "$1" -type f -printf "%P\n" | sort > "$1/list.tmp"
	find "$2" -type f -printf "%P\n" | sort > "$2/list.tmp"
	kdiff3 "$1/list.tmp" "$2/list.tmp"
}

cmd retry "retry argument operation till success"
retry()
{
	# see also "watch"
	while ( ! "$@" ) do
	echo retry
	sleep 1
	done
}

cmd duplicates 'finds duplicate files. To follow symbolic links run duplicate -L $DIR'
duplicates()
{
	# Features:
	# Fast because checks sizes first
	# and filters same linked files by checking inode (%i)
	# - Sorts files by size to help you to delete biggest files first

	# Troubleshooting:
	# on out of memory define TMPDIR

	find "$@" -type f -not -regex '.*/\.svn/.*' -printf "%10i\t%10s\t%p\n" \
		| sort -n \
		| uniq --unique -w10 \
		| cut -f 2,3 | sort -n \
		| uniq --all-repeated -w 10 \
		| cut -f 2 \
		| perl -pe "s/\n/\0/g" \
		| xargs -0 -i{} sha1sum "{}" | sort \
		| uniq --all-repeated=separate -w32 | cut -d ' ' -f 3
}

cmd for_each "applies an operation to set of arguments one by one"
for_each()
{
	op=$1
	shift
	for arg in "$@"; do
	eval "$op" \"$arg\"
	done
}

cmd ext_get "extracts extension from specified filename"
ext_get()
{
	echo "${1##*.}"
}

cmd ext_strip "returns filename without extension"
ext_strip()
{
	echo "${1%.*}"
}

cmd name_get "returns just filename without path and extension"
name_get()
{
	a=${1##*/}
	echo "${a%.*}"
}

cmd postfix_extract "return filename postfix:  path/name[-_]postfix.ext -> postfix"
postfix_extract()
{
	a=${1%.*}
	echo "${a##*[-_]}"
}

cmd unzip_dir "handy unzip to directory with name of zip-file"
unzip_dir()
{
	unzip "$@" -d `name_get "$1"`
}

cmd mac_to_ip "looks in LAN IP for MAC"
mac_to_ip()
{
	ping -q -c 4 -b 255.255.255.255 &> /dev/null
	arp -n | grep -i "$1" | cut -f 1 -d ' '
}

cmd ip_to_mac "show MAC address for specified IP in LAN"
ip_to_mac()
{
	if which arping > /dev/null; then
		arping -c 1 "$1" 2> /dev/null | perl -ne '/.*\[(.*)\].*/ && print "$1\n"'
	else
		ping -c 1 -w 1 "$1" &> /dev/null
		arp -na | grep "$1" | cut -f 4 -d ' '
	fi
}

cmd fs_usage "show biggest directories and optionally files on a filesystem, for example on root: fs_usage -a /"
fs_usage()
{
	du --one-file-system "$@" | sort -n | tail -n $((LINES-2))
	df "$@"
}

cmd PATH_add "adds argument to PATH, if required"
PATH_add()
{
	if [[ ":$PATH:" == *":$1:"* ]]
	then
		echo "$1 is already in path"
	else
		export PATH="$PATH:$1"
	fi
}

cmd gcc_set "set specified [cross] compiler as default in environment"
gcc_set()
{
	#export PATH=/usr/sbin:/usr/bin:/sbin:/bin:
	gcc=`readlink --canonicalize "$1"`
	path=`dirname "$gcc"`
	PATH_add "$path"
	file=`basename "$gcc"`
	export CROSS_COMPILE=${file%-*}- # delete shortest from the end
	export CC=${CROSS_COMPILE}gcc
	export AR=${CROSS_COMPILE}ar
	export LD=${CROSS_COMPILE}ld
	export AS=${CROSS_COMPILE}as
	export CPP=${CROSS_COMPILE}cpp
	export CXX=${CROSS_COMPILE}c++
	echo Using:
	which "$CC"
	mach=`$CC -dumpmachine`
	export ARCH=${mach%%-*}
	PS1='$ARCH \w \$ '
	$CC -v 2>&1  | grep 'gcc version'
}

cmd mem_drop_caches "drop chaches and free this memory. Practically not required"
alias mem_drop_caches="sync; echo 3 | sudo tee /proc/sys/vm/drop_caches"

cmd mem_avail_kb "Returns available for allocation RAM, which is sum of MemFree, Buffers and Cached memory"
mem_avail_kb()
{
	# also free | grep cache | awk '/[0-9]/{ print $4" KB" }'
	echo $(($(echo `sed -n '2p;3p;4p' <  /proc/meminfo | sed "s/ \+/ /g" | cut -d' ' -f 2 ` | sed "s/ /+/g") ))
}

cmd wget_as_me "Run wget with cookies from firefox to access authenticated data"
wget_as_me()
{
	sqlite3 -separator "$tab" $HOME/.mozilla/firefox/*.default*/cookies.sqlite \
		'select host, "TRUE", path, "FALSE", expiry, name, value from moz_cookies' \
		> ~/.mozilla/cookies.txt
	wget -q --load-cookies ~/.mozilla/cookies.txt "$@"
}

cmd calc "calculate with bc specified floating point expression"
calc()
{
	# see also http://www.isthe.com/chongo/tech/comp/calc/
	echo "scale=4;" "$@" | bc
}

cmd md5sum_make "create md5 files for each specified file separately"
md5sum_make()
{
	while [ -n "$1" ]; do
	md5sum "$1" > "$1.md5"
	echo "$1.md5"
	shift
	done
}

cmd check "runs verbosely specified command and prints return status"
check()
{
	echo -n "Runnung: $@ : "
	eval "$@" && echo -e "$? \033[2;32mOK \033[0;39m" || echo -e "$? \033[2;31mFail \033[0;39m"
}

# used in lib_sh_demo only
v()
{
	echo ">" "$@"
	eval "$@"
}

cmd lib_sh_demo "run lib.sh functions for demonstration and testing"
lib_sh_demo()
{
	v ext_get aaa.bbb
	v ext_strip aaa.bbb
	v name_get path/name.ext
	v postfix_extract path/name_postfix.ext
	v for_each echo  aaa bbb ccc
	mkdir -p dup/sub
	echo 1 > dup/1
	cp dup/1 dup/1.1
	cp dup/1 dup/sub/
	echo 2 > dup/2

	v duplicate dup
	v mem_avail_kb
	check true
	check false
	v 'wget_as_me "http://mail.google.com/mail?nocheckbrowser&ui=html" -O- \
		| lynx -stdin -dump -width=$COLUMNS | grep ^Inbox -A 10'
}

if [ -n "$*" ]; then
	eval "$*" # execute arguments
	#echo $* finished, ret=$?
else
	if [ `which "$0"` = "$SHELL" ]; then
		echo Lib.sh functions are loaded into the shell environment
	else
		echo Lib.sh - a library of shell utility functions
		echo To get help run \"`basename "$0"` lib_help\"
	fi
fi
