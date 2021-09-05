gdb-print-prepare - utility to print C,C++ variables and structs at runtime
====


``` bash
gdb-print-prepare()
{
	if [[ $# == 0 ]]; then
		cat <<-EOF
 
		Usage:
 
		Mark print points in C or C++ sources with pseudo comment:
		// gdb_print(big_struct)
		gdb-print-prepare \$src > app.gdb
		gdb --batch --quiet --command=app.gdb \$app
 
		See file gdb-print-demo.c for example.
 
		EOF
		return
	fi
	cat <<-EOF
	set auto-load safe-path /
	EOF
	grep --with-filename --line-number --recursive --only-matching 'gdb_print(.*)' $1 | \
	while IFS=$'\t :;()' read file line func var rest; do
		cat <<-EOF
		break $file:$line
		commands
		silent
		where 1
		echo \\n$var\\n
		print $var
		cont
		end
		EOF
	done
	cat <<-EOF
	run
	echo ---\\n
	EOF
}
```
