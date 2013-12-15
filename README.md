lib.sh - Library of shell functions
===
Usage:

Load commands to shell:
 . lib.sh

Run a command with subshell:
 lib.sh <command> <arguments...>


List of available commands:
 ps-all - lists all processes
 ps-threads - lists processes with threads
 ps-tree - lists process tree via ps, see also pstree -p
 ps-cpu - lists most CPU consuming processes
 ps-mem - lists most memory consuming processes
 ps-wchan - shows what processes are waiting for, used in debugging blocked processes
 ls-size - list files with sizes in bytes, shorter than ls -l
 hist - handy history, up to one screen length
 deb-list - list content of specified deb file
 git-diff - handy git diff
 git-diff-HEAD - show the differences between your working directory and the most recent commit
 git-diff-last-commit - shows last git commit
 git_prompt - sets shell prompt to show git branch
 system_status_short - shows short summary of system resources (RAM,CPU) usage
 system_status_long - shows long system status and statistics by running various system utilities
 shell_type - tries to identify type of current shell
 git_fixup - interactive fixup of specified number of last git commits
 ps_of - specified process info
 proc_mem_usage - returns percentage memory usage by sc
 tcpdump-text - tcpdump of payload in text
 lib_help - shows help for Lib.sh
 dir_diff - compare listings of two specified directories
 retry - retry argument operation till success
 git_ign_add - add files' names with path to appropriate .gitignore list
 duplicate - finds duplicate files. To follow symbolic links run duplicate -L $DIR
 for_each - applies an operation to set of arguments one by one
 ext_get - extracts extension from specified filename
 ext_strip - returns filename without extension
 name_get - returns just filename without path and extension
 postfix_extract - return filename postfix:  path/name[-_]postfix.ext -> postfix
 unzip_dir - handy unzip to directory with name of zip-file
 mac_to_ip - looks in LAN IP for MAC
 ip_to_mac - show MAC address for specified IP in LAN
 fs_usage - show biggest directories and optionally files on a filesystem, for exampe on root: fs_usage -a /
 gcc_set - set specified compiler as default (in variable CC) and cross compiler
 mem_drop_caches - drop chaches and free this memory. Practically not required
 mem_avail_kb - Returns available for allocation RAM, which is sum of MemFree, Buffers and Cached memory
 wget_as_me - Run wget with cookies from firefox to access authenticated data
 calc - calculate with bc specified floating point expression
 md5sum_make - create md5 files for each specified file separately
 check - runs verbosely specified command and prints return status
 lib_sh_demo - run lib.sh functions for demonstration and testing

