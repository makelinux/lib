duplicates - finds duplicate files. To follow symbolic links run duplicate -L $DIR
====


``` bash
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
	set -o noglob
	find "$@" $find_exclude -type f \
		-printf "%10i\t%10s\t%p\n" \
		| sort -n \
		| uniq --unique -w10 \
		| cut -f 2,3 | sort -n \
		| uniq --all-repeated -w 10 \
		| cut -f 2 \
		| perl -pe "s/\n/\0/g" \
		| xargs -0 -i{} sha1sum "{}" | sort \
		| uniq --all-repeated=separate -w32 \
		| cut -d ' ' -f 3-
	set +o noglob
}
```
