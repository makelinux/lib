ps-mem - lists most memory consuming processes
====


```
alias ps-mem='ps -e -o pmem,vsz,rss,pid,comm --sort -%mem | head -n 5'
```
