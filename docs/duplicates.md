duplicates - finds duplicate files. To follow symbolic links run duplicate -L $DIR
====


```
duplicates () 
{ 
    find "$@" -type f -not -regex '.*/\.svn/.*' -printf "%10i\t%10s\t%p\n" | sort -n | uniq --unique -w10 | cut -f 2,3 | sort -n | uniq --all-repeated -w 10 | cut -f 2 | perl -pe "s/\n/\0/g" | xargs -0 -i{} sha1sum "{}" | sort | uniq --all-repeated=separate -w32 | cut -d ' ' -f 3-
}
```
