log - safely prints messages to stderr
====


```
log () 
{ 
    ( echo "$@" 1>&2 )
}
```
