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
export NUMCPUS=`grep -c '^processor' /proc/cpuinfo`

unset usage
declare -A usage

cmd()
{
	usage[$1]="$2"
}

cmd lib-help "shows help for Lib.sh"
lib-help()
{
	echo -e "List of available commands:\n"

	for i in "${!usage[@]}"
	do
		echo "$i - ${usage[$i]}"
	done
}

lib-snippets()
{
	for i in "${!usage[@]}"
	do
		(
		echo -e "$i - ${usage[$i]}\n====\n\n"
		echo -e "\`\`\` bash"
		if [ $(type -t $i) == alias ]; then
			a=$(type $i); echo alias ${a/ is aliased to \`/=\'}
		else
			#type "$i" | (read; cat)
			awk "/cmd $i/{f=1;next}; { if (f && /$^/)exit}; f" lib.sh
		fi
		echo "\`\`\`"
		) > "snippets/$i.md"
	done
}

###############################################################################
#	Short useful definitions and aliases

GREP_OPTIONS="--devices=skip --color=auto " # avoid hanging grep on devices
export GREP_COLORS='ms=01;38:mc=01;31:sl=02;38:cx=:fn=32:ln=32:bn=32:se=36' # print matched text in bold
export HISTIGNORE="&:ls:[bf]g:exit"

cmd ps-all "lists all processes"
alias ps-all='ps -AF'

cmd ps-threads "lists processes with threads"
alias ps-threads="ps -ALf"

cmd ps-tree "lists process tree via ps, see also pstree -p"
alias ps-tree="ps -ejH"

cmd ps-cpu "lists most CPU consuming processes"
alias ps-cpu="ps -e -o pcpu,pid,comm --sort -%cpu | head -n 5"

cmd ps-mem "lists most memory consuming processes"
alias ps-mem="ps -e -o pmem,vsz,rss,pid,comm --sort -%mem | head -n 5"

cmd default-eth "provides default Ethernet interface"
alias default-eth='ip route | awk "/default/ { print \$5 }"'

cmd external-ip "Provides external IP"
alias external-ip="dig +short myip.opendns.com @resolver1.opendns.com"

cmd ps-wchan "shows what processes are waiting for, used in debugging blocked processes"
alias ps-wchan="ps -e -o pid,comm,wchan"

cmd ls-size "list files with sizes in bytes, shorter than ls -l"
#alias ls-size='ls -s --block-size=1 -1'
#alias ls-size='stat -c "%s$tab%n"'
ls-size() { stat -c "%s$tab%n" `\ls "$@"`; }

cmd mplayer-rotate-right "play video rotated right, used to play vertically captured videos"
alias mplayer-rotate-right="mplayer -vf rotate=1"

cmd hist "handy history, up to one screen length"
alias hist='history $((LINES-2))'

cmd deb-list "list content of specified deb file"
alias deb-list="dpkg-deb --contents"

cmd quotation-highlight "highlight text in quotation marks (\"quotation\")"
ansi_rev=$'\e[7m'
ansi_norm=$'\e[0m'
alias quotation-highlight=' sed "
	s|\\\\\\\\|:dbs:|g;
	s|\\\\\"|:bsq:|g;
	s|\\\\\"|:quotation:|g;
	s|\"\([^\"]*\?\)\"| $ansi_rev\1$ansi_norm |g;
	s|:quotation:|\\\\\"|g;
	s|:bsq:|\\\\\\\"|g;
	s|:dbs:|\\\\\\\\|g"'

cmd keyboard-shortcuts "bash keyboard shortcuts. See also man readline."
alias keyboard-shortcuts='(bind -P | grep -v "is not bound" | nl |
	sed "
		s| can be found on|:|;
		s|.$||;
		s|, \+| |g;
		s|\\\C-|^|g
		s|\\\e|+|g;" \
		| pr --omit-header --expand-tabs --columns=2 -w $COLUMNS \
		| expand; \
		echo \"^\" = Ctrl, \"+\" = Escape) | quotation-highlight '

cmd tcpdump-text "tcpdump of payload in text"
alias tcpdump-text="sudo tcpdump -l -s 0 -A '(((ip[2:2] - ((ip[0]&0xf)<<2)) - ((tcp[12]&0xf0)>>2)) != 0) and'"

cmd make-debug "verbose make"
alias make-debug="remake --debug=bv SHELL='/bin/bash -vx' "

# git helpers

cmd git-diff "handy git diff"
alias git-diff='git diff --relative --no-prefix -w'

cmd git-prompt "sets shell prompt to show git branch"
git-prompt()
{
	PS1='[\u@\h \W$(__git_ps1 " (%s)")]\$ '
}

cmd git-fixup "interactive fix up of specified number of last git commits"
git-fixup()
{
	git rebase -i HEAD~$1 .
}

cmd git-ign-add "add files' names with path to appropriate .gitignore list"
git-ign-add()
{
	for a in $*; do
		echo "$a"
		(cd `dirname "$a"`; \ls -d `basename "$a"` -1 >> .gitignore; git add .gitignore )
	done
}

cmd log "safely prints messages to stderr"
log()
{
	# Note: echo "$@" > /dev/stderr - resets stderr
	( 1>&2 echo "$@" )
}

cmd trap-err "traps command failures, print return value and returns, better than set -o errexit"
trap-err()
{
	trap 'echo -e $"\e[2;31mFAIL \e[0;39m ret=$? ${BASH_SOURCE[0]}:${LINENO} ${FUNCNAME[*]}" > /dev/stderr;return $ret 2> /dev/null' ERR
}

###############################################################################
#	Shell functions

cmd system-status-short "shows short summary of system resources (RAM,CPU) usage"
system-status-short()
{
	grep -e MemTotal: -e MemAvailable: /proc/meminfo
	paste <(mpstat|grep %usr|sed "s/ \+/\n/g") <(mpstat|grep all|sed "s/ \+/\n/g") | \grep -e idle -e iowait -e sys
	ps-cpu
	ps-mem
}

cmd system-status-long "shows long system status and statistics by running various system utilities"
system-status-long()
{
	grep "" /etc/issue /etc/*release
	getconf LONG_BIT
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
	sudo -n parted -l || sudo -n flisk -l
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

cmd shell-type "tries to identify type of current shell"
shell-type()
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

cmd ps-of "specified process info"
ps-of()
{
	# ps u -C "$1"
	ps u `pidof "$@"`
}

cmd proc-mem-usage "returns percentage memory usage by specified process"
proc-mem-usage()
{
	ps h -o pmem -C "$1"
}

cmd dir-diff "compare listings of two specified directories"
dir-diff()
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
	log retry
	sleep 1
	done
}

cmd duplicates 'finds duplicate files. To follow symbolic links run duplicate -L $DIR'
duplicates()
{
	# Features:
	# * Fast - because it checks sizes first
	# and filters same linked files by checking inode (%i)
	# * Sorts files by size to help you to delete biggest files first
	#
	# Troubleshooting:
	# on out of memory define TMPDIR
	#
	find "$@" -type f -not -regex '.*/\.svn/.*' -printf "%10i\t%10s\t%p\n" \
		| sort -n \
		| uniq --unique -w10 \
		| cut -f 2,3 | sort -n \
		| uniq --all-repeated -w 10 \
		| cut -f 2 \
		| perl -pe "s/\n/\0/g" \
		| xargs -0 -i{} sha1sum "{}" | sort \
		| uniq --all-repeated=separate -w32 \
		| cut -d ' ' -f 3-
}

cmd for-each "applies an operation to set of arguments one by one"
for-each()
{
	op=$1
	shift
	for arg in "$@"; do
		eval "$op" \"$arg\"
	done
}

cmd str "readable string manipulations: ltrim, ltrim-max, rtrim, rtrim-max, subst, subst-all"
str()
{
	case $1 in
		(ltrim) echo "${2#$3}" ;;
		(ltrim-max) echo "${2##$3}";;
		(rtrim) echo "${2%$3}";;
		(rtrim-max) echo "${2%%$3}";;
		(subst) echo "${2/$3/$4}";;
		(subst-all) echo "${2//$3/$4}";;
		(ext) echo "${2#*.}";;
		(rtrim-ext) echo "${2%%.*}";; # path without extension
		(base) # just filename without path and extension
			expr \
				match "$2" '.*/\(.*\)\.tar' \| \
				match "$2" '.*/\(.*\)\.' \| \
				match "$2" '.*/\(.*\)'
			;;
	esac
	# More: https://www.tldp.org/LDP/abs/html/string-manipulation.html
}

cmd postfix-extract "return filename postfix: path/name[-_]postfix.ext -> postfix"
postfix-extract()
{
	a=${1%.*}
	echo "${a##*[-_]}"
}

cmd unzip-dir "handy unzip to directory with name of zip-file"
unzip-dir()
{
	unzip "$@" -d `str base "$1"`
}

cmd mac-to-ip "looks for LAN IP for MAC"
mac-to-ip()
{
	(
		(for b in $(ip addr ls | awk '/inet .* brd/ {print $4}'); do
			ping -q -c 1 -b $b &> /dev/null
		done ) &
	) 2> /dev/null
	while ! a=$(arp -n | grep -i "$1"); do sleep 1; log 'waitig' ; done;
	echo "$a" | (read a1 a2; echo $a1)
}

cmd ip-to-mac "show MAC address for specified IP in LAN"
ip-to-mac()
{
	if which arping > /dev/null; then
		arping -c 1 "$1" 2> /dev/null | perl -ne '/.*\[(.*)\].*/ && print "$1\n"'
	else
		ping -c 1 -w 1 "$1" &> /dev/null
		arp -na | grep "$1" | cut -f 4 -d ' '
	fi
}

cmd fs-usage "show biggest directories and optionally files on a filesystem, for example on root: fs-usage -a /"
fs-usage()
{
	du --time --one-file-system "$@" | sort -n | tail -n $((LINES-2))
	df "$@"
}

cmd PATH-append "appends argument to PATH, if required"
PATH-append()
{
	if [[ ":$PATH:" == *":$1:"* ]]
	then
		echo "$1 is already in path"
	else
		export PATH="$PATH:$1"
	fi
}

cmd PATH-insert "inserts argument to head of PATH, if required"
PATH-insert()
{
	if [[ ":$PATH:" == *":$1:"* ]]
	then
		echo "$1 is already in path"
	else
		export PATH="$1:$PATH"
	fi
}

cmd PATH-remove "removes argument from PATH"
PATH-remove()
{
	PATH=$(echo ":$PATH:"| sed "s|:$1:|:|g" | sed "s|::||g;s|^:||;s|:$||")
}

cmd PATH-append "prints PATH in readable format"
PATH-show()
{
	echo $PATH | sed "s/:/\n/g"
}

cmd gcc-set "append a string to a file if it not yet present there"
file-append-once()
{
	mkdir -p $(dirname "$1")
	grep --quiet --line-regexp --fixed-strings "$2" "$1" && return
	test -w "$1" && echo "$2" >> "$1" || echo "$2" | sudo tee -a "$1"
}

cmd gcc-set "set specified [cross] compiler as default in environment"
gcc-set()
{
	#export PATH=/usr/sbin:/usr/bin:/sbin:/bin:
	PATH-append $(dirname $(which "$1"))
	export CROSS_COMPILE=$(expr match "$(basename $1)" '\(.*-\)')
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
	$CC -v 2>&1 | grep 'gcc version'
}

cmd get-source "replace substring arg1 to substring arg2 in directory arg3"
replace()
{
	grep "$1" "$3" \
		-rl --exclude .orig --exclude .git --binary-files=without-match --exclude-dir=.svn --exclude-dir=.git -P \
		| xargs sed -i "s|$1|$2|g"
}

cmd get-source "download and unpack an open source tarball"
get-source()
{
	case $1 in
		(git* | *.git) git clone $1 ;;
		(svn*) git checkout $1 ;;
		(*)
			fn=$(basename $1)
			n=${fn%%.tar.*}
			! test -f ~/Downloads/"$fn" && (expr match "$1" "^http" || expr match "$1" "^ftp" ) > /dev/null && wget -P ~/Downloads/ $1
			[ -e "$n" ] || aunpack -q ~/Downloads/"$fn"
		esac
	}

cmd gnu-build "universal complete build and install of gnu package"
gnu-build()
{
	[ "$CC" ] || CC=gcc
	get-source $1
	shift
	pushd $n
	if [ -d debian ]; then
		dpkg-buildpackage -rfakeroot -uc -b
		return
	fi
	test -e configure || autoreconf --install
	if [ -e configure ]; then
		configure_opt="$configure_opt_init -q"
		if [ -n "$DESTDIR" ]; then
			configure_opt+=" --prefix=/ --includedir=/include "
		fi
		configure_opt+=" CPPFLAGS='${CPPFLAGS}'"
		configure_opt+=" LDFLAGS='${LDFLAGS}'"
		if [ -n "${CROSS_COMPILE}" ]; then
			configure_opt+=" --host=${CROSS_COMPILE%-}"
		fi
		test "${staging}" && configure_opt+=" --with-sysroot=${staging}"
		configure_opt+=" $* "
		mkdir -p $($CC -dumpmachine)-build
		pushd $_
		test -e Makefile || ( echo "Configuring $configure_opt" && eval ../configure $configure_opt )
		make -j$NUMCPUS --load-average=$NUMCPUS -ws \
			&& make -k install || sudo -H make -k install
		ret=$?
		popd
	fi
	ls
	if [ -e Makefile.PL ]; then
		perl Makefile.PL
		make
		sudo make -k install
		ret=$?
	fi
	popd
	return $ret
}

cmd alternative-config-build "build of package, alternatively to gnu-build"
alternative-config-build()
{
	[ "$CC" ] || CC=gcc
	get-source $1
	shift
	mkdir -p $n/$($CC -dumpmachine)-build~ # '~' to skip by lndir
	pushd $_
	lndir -silent ..
	./configure -q "$@"
	make -j$NUMCPUS --load-average=$NUMCPUS -ws &&
		make install
	ret=$?
	popd
	return $ret
}

cmd build-env "configure staging build environment"
build-env()
{
	staging=$(readlink --canonicalize $1)
	PKG_CONFIG_DIR= #https://autotools.io/pkgconfig/cross-compiling.html
	PKG_CONFIG_SYSROOT_DIR=$staging
	#export PKG_CONFIG_PATH=$staging/lib/pkgconfig
	PKG_CONFIG_LIBDIR=$PKG_CONFIG_SYSROOT_DIR/lib/pkgconfig
	DESTDIR=$staging # used by make install
	CPPFLAGS=-I${staging}/include
	LDFLAGS=-L${staging}/lib
	LDFLAGS+=' '-Wl,-rpath-link=${staging}/lib
	export staging PKG_CONFIG_DIR PKG_CONFIG_SYSROOT_DIR DESTDIR CPPFLAGS LDFLAGS
}

cmd glib-arm-build "demonstration of arm compilation of glib from the scratch"
glib-arm-build()
{
	gcc-set /usr/bin/arm-linux-gnueabi-gcc
	build-env staging-$($CC -dumpmachine)
	alternative-config-build http://zlib.net/zlib-1.2.8.tar.gz --prefix=/
	gnu-build ftp://sourceware.org/pub/libffi/libffi-3.2.1.tar.gz
	cp -a ${staging}/lib/libffi-*/include ${staging}/
	export glib_cv_stack_grows=no glib_cv_uscore=no ac_cv_func_posix_getpwuid_r=yes ac_cv_func_posix_getgrgid_r=yes
	gnu-build http://ftp.gnome.org/pub/gnome/sources/glib/2.48/glib-2.48.1.tar.xz --with-pcre=internal
	file -L staging-$($CC -dumpmachine)/lib/libglib-2.0.so
	return $?
}

cmd staging-dir-fix "fix parameter libdir in *.la files in staging cross-compilation directory"
staging-dir-fix()
{
	sed -i "s|^libdir='//\?lib'|libdir='`readlink --canonicalize "$1"`/lib'|" \
		`grep --no-messages --recursive --files-with-matches --include *.la "libdir='//\?lib" "$1"`
	grep -r --include *.la "libdir=" "$1"
}

cmd mem-drop-caches "drop caches and free this memory. Practically not required"
alias mem-drop-caches="sync; echo 3 | sudo tee /proc/sys/vm/drop-caches"

cmd gdb-print-prepare "prepares gdb script to print variables and structs at runtime"
gdb-print-prepare()
{
	# usage:
	# mark print points with empty standalone defines:
	# gdb_print(huge_struct);
	# gdb-print-prepare $src > app.gdb
	# gdb --batch --quiet --command=app.gdb $app
	cat  <<-EOF
	set auto-load safe-path /
	EOF
	grep --with-filename --line-number --recursive '^\s\+gdb_print(.*);' $1 | \
	while IFS=$'\t ;()' read line func var rest; do
		cat  <<-EOF
		break ${line%:}
		commands
		silent
		where 1
		echo \\n$var\\n
		print $var
		cont
		end
		EOF
	done
	cat  <<-EOF
	run
	bt
	echo ---\\n
	EOF
}

cmd wget-as-me "Run wget with cookies from firefox to access authenticated data"
wget-as-me()
{
	sqlite3 -separator "$tab" $(ls -1t $HOME/.mozilla/firefox/*.default*/cookies.sqlite | head -1) \
		'select host, "TRUE", path, "FALSE", expiry, name, value from moz_cookies' \
		> ~/.mozilla/cookies.txt
	wget -q --load-cookies ~/.mozilla/cookies.txt "$@"
	ret=$?
	#( 1>&2 echo echo ret=$ret )
	return $ret
}

cmd calc "calculate with bc specified floating point expression"
calc()
{
	# see also http://www.isthe.com/chongo/tech/comp/calc/
	echo "scale=4;" "$@" | bc
}

cmd md5sum-make "create md5 files for each specified file separately"
md5sum-make()
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
	echo -n "Running: $@ : "
	eval "$@" && echo -e "$? \033[2;32mOK \033[0;39m" || echo -e "$? \033[2;31mFail \033[0;39m"
}

# used in lib-sh-demo only
v()
{
	echo ">" "$@"
	eval "$@"
}

# used in lib-sh-demo only
eq()
{
	a="$1"
	echo -n "$a "
	shift
	if [ "$a" == $(eval "$@") ]; then echo -n '= '; else echo -n '!= '; fi
	echo "$@"
}

cmd lib-sh-demo "run lib.sh functions for demonstration and testing"
lib-sh-demo()
{
	eq '4.tar.gz' str ext '1/2/3.4.tar.gz'
	eq '3' str base '1/2/3.4.tar.gz'
	v postfix-extract path/name-postfix.ext
	v for-each echo aaa bbb ccc
	mkdir -p dup/sub
	echo 1 > dup/1
	cp dup/1 dup/1.1
	cp dup/1 dup/sub/
	echo 2 > dup/2

	v duplicates dup
	check true
	check false
	#not supported
	#v 'wget-as-me "http://mail.google.com/mail?nocheckbrowser&ui=html" -O- \
	#	| lynx -stdin -dump -width=$COLUMNS | grep ^Inbox -A 10'
}

cmd doxygen-bootstrap "generic handy doxygen wrapper"
doxygen-bootstrap()
{
	if [ ! -e Doxyfile ]; then
		command doxygen -g
		cat > Doxyfile <<-EOF
		PROJECT_NAME = "$(basename $PWD)"
		EXTRACT_ALL            = YES
		EXTRACT_STATIC         = YES
		RECURSIVE              = YES
		EXCLUDE                = html
		GENERATE_TREEVIEW      = YES
		GENERATE_LATEX         = NO
		HAVE_DOT               = YES
		DOT_FONTSIZE           = 15
		CALL_GRAPH             = YES
		CALLER_GRAPH           = YES
		INTERACTIVE_SVG        = YES
		#DOT_TRANSPARENT        = YES
		DOT_MULTI_TARGETS      = NO
		DOT_CLEANUP            = NO
		OPTIMIZE_OUTPUT_FOR_C  = YES
		DOT_FONTNAME           = Ubuntu
		EOF
		# command doxygen -u
	fi
	command doxygen "$@" 2> doxygen.log
	xdg-open html/index.html || firefox html/index.html
}

cmd load-watch "kills memory and cpu hogs when load average is too high"
load-watch()
{
	local nproc=$(getconf _NPROCESSORS_ONLN)
	echo
	while true; do
		echo -n ${CSI}A
		echo -n $(date "+%T $SECONDS ") " "
		local load
		free=$( grep MemAvailable: /proc/meminfo | (read a b c d e; echo $((b/1024))) )
		IFS="/ " read -a load < /proc/loadavg
		local loadproc=$((10#${load/./}00/${nproc}00)) # '10#' is to force decimal, because 'load' starts from 0
		local pcpu=$(echo $(ps --no-headers -e -o pid,comm,pcpu --sort -%cpu | head -n 1))
		local pmem=$(echo $(ps --no-headers -e -o pid,comm,pmem --sort -%mem | head -n 1))
		echo -n "load=$load $loadproc% running=${load[3]} free=$free MB, $pcpu% cpu, $pmem% mem"
		echo "${CSI}K"
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

if [ -n "$*" ]; then
	eval "$*" # execute arguments
	#echo $* finished, ret=$?
else
	if [ "$0" != "$BASH_SOURCE" ]; then
		echo Lib.sh functions are loaded into the shell environment
	else
		echo Lib.sh - a library of shell utility functions
		echo To get help run \"$BASH_SOURCE lib-help\"
	fi
fi
