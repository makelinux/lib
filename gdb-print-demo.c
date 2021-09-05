#include <stdio.h>
/*
  Usage:

  Compile the file with debug info:
  make -B CFLAGS=-g gdb-print-demo

  Generate gdb script script.gdb:

  gdb-print-prepare gdb-print-demo.c > script.gdb

  Run the excucutable with gdb and the script:
  gdb --batch --quiet --command=script.gdb ./gdb-print

*/

int main()
{
	//gdb_print(*stdout)
	;
}
