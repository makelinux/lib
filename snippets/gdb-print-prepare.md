gdb-print-prepare - prepares gdb script to print variables and structs at runtime
====


``` bash
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
```
