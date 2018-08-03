ps-cpu - lists most CPU consuming processes
====


``` bash
alias ps-cpu='ps -e -o pcpu,pid,comm --sort -%cpu | head -n 5'
```
