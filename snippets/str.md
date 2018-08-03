str - readable string manipulations: ltrim, ltrim-max, rtrim, rtrim-max, subst, subst-all
====


``` bash
str()
{
	case $1 in
		(ltrim) echo "${2#$3}" ;;
		(ltrim-max) echo "${2##$3}";;
		(rtrim) echo "${2%$3}";;
		(rtrim-max) echo "${2%%$3}";;
		(subst) echo "${2/$3/$4}";;
		(subst-all) echo "${2//$3/$4}";;
		(ext) echo "${2#*.}";;
		(rtrim-ext) echo "${2%%.*}";; # path without extension
		(base) # just filename without path and extension
			local a=${2##*/}
			echo "${a%%.*}"
			;;
	esac
	# More: https://www.tldp.org/LDP/abs/html/string-manipulation.html
}
```
