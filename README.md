lib.sh - Library of shell functions
===
Usage:

Load commands to shell:
* . lib.sh

Run a command with subshell:
* lib.sh \<command\> \<arguments...\>
* lib_help - shows help for Lib.sh

List of available commands:
* ps-all - lists all processes
* ps-threads - lists processes with threads
* ps-tree - lists process tree via ps, see also pstree -p
* ps-cpu - lists most CPU consuming processes
* ps-mem - lists most memory consuming processes
* default-eth - provides default Ethernet interface
* external-ip - Provides external IP
* ps-wchan - shows what processes are waiting for, used in debugging blocked processes
* ls-size - list files with sizes in bytes, shorter than ls -l
* mplayer-rotate-right - play video rotated right, used to play vertically captured videos
* hist - handy history, up to one screen length
* deb-list - list content of specified deb file
* quotation-highlight - highlight text in quotation marks ("quotation")
* keyboard-shortcuts - bash keyboard shortcuts. See also man readline.
* tcpdump-text - tcpdump of payload in text
* make-debug - verbose make
* git-diff - handy git diff
* git-prompt - sets shell prompt to show git branch
* git-fixup - interactive fix up of specified number of last git commits
* git-ign-add - add files' names with path to appropriate .gitignore list
* log - safely prints messages to stderr
* trap-err - traps command failures, print return value and returns, better than set -o errexit
* system-status-short - shows short summary of system resources (RAM,CPU) usage
* system-status-long - shows long system status and statistics by running various system utilities
* shell-type - tries to identify type of current shell
* ps-of - specified process info
* proc-mem-usage - returns percentage memory usage by specified process
* dir-diff - compare listings of two specified directories
* retry - retry argument operation till success
* duplicates - finds duplicate files. To follow symbolic links run duplicate -L $DIR
* for-each - applies an operation to set of arguments one by one
* str - readable string manipulations: ltrim, ltrim-max, rtrim, rtrim-max, subst, subst-all
* postfix-extract - return filename postfix: path/name[-_]postfix.ext -> postfix
* unzip-dir - handy unzip to directory with name of zip-file
* mac-to-ip - looks for LAN IP for MAC
* ip-to-mac - show MAC address for specified IP in LAN
* fs-usage - show biggest directories and optionally files on a filesystem, for example on root: fs-usage -a /
* PATH-append - prints PATH in readable format
* PATH-insert - inserts argument to head of PATH, if required
* PATH-remove - removes argument from PATH
* PATH-append - prints PATH in readable format
* gcc-set - set specified [cross] compiler as default in environment
* gcc-set - set specified [cross] compiler as default in environment
* get-source - download and unpack an open source tarball
* get-source - download and unpack an open source tarball
* gnu-build - universal complete build and install of gnu package
* alternative-config-build - build of package, alternatively to gnu-build
* build-env - configure staging build environment
* glib-arm-build - demonstration of arm compilation of glib from the scratch
* staging-dir-fix - fix parameter libdir in *.la files in staging cross-compilation directory
* mem-drop-caches - drop caches and free this memory. Practically not required
* gdb-print-prepare - prepares gdb script to print variables and structs at runtime
* wget-as-me - Run wget with cookies from firefox to access authenticated data
* calc - calculate with bc specified floating point expression
* md5sum-make - create md5 files for each specified file separately
* check - runs verbosely specified command and prints return status
* lib-sh-demo - run lib.sh functions for demonstration and testing
* doxygen-bootstrap - generic handy doxygen wrapper
* load-watch - kills memory and cpu hogs when load average is too high
* dts-tags - extacts tags (ctags format)from device tree source files
