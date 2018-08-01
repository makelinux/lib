str - readable string manipulations: ltrim, ltrim_max, rtrim, rtrim_max, subst, subst_all
====


```
str () 
{ 
    case $1 in 
        ltrim)
            echo "${2#$3}"
        ;;
        ltrim_max)
            echo "${2##$3}"
        ;;
        rtrim)
            echo "${2%$3}"
        ;;
        rtrim_max)
            echo "${2%%$3}"
        ;;
        subst)
            echo "${2/$3/$4}"
        ;;
        subst_all)
            echo "${2//$3/$4}"
        ;;
        ext)
            echo "${2#*.}"
        ;;
        rtrim_ext)
            echo "${2%%.*}"
        ;;
        base)
            local a=${2##*/};
            echo "${a%%.*}"
        ;;
    esac
}
```
