log - safely prints messages to stderr
====


``` bash
log()
{
	# Note: echo "$@" > /dev/stderr - resets stderr
	( 1>&2 echo "$@" )
}
```
