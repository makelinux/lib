dts-tags - extacts tags (ctags format) from device tree source files
====


``` bash
dts-tags()
{
	grep -oH '\w\+:' "$@" | awk -F: '{print $2"\t"$1"\t/"$2":"}' | LC_ALL=C sort
}
```
