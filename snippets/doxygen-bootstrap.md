doxygen-bootstrap - generic handy doxygen wrapper
====


``` bash
doxygen-bootstrap()
{
	if [ ! -e Doxyfile ]; then
		command doxygen -g
		cat > Doxyfile <<-EOF
		PROJECT_NAME = "$(basename $PWD)"
		EXTRACT_ALL            = YES
		EXTRACT_STATIC         = YES
		RECURSIVE              = YES
		EXCLUDE                = html
		GENERATE_TREEVIEW      = YES
		GENERATE_LATEX         = NO
		HAVE_DOT               = YES
		DOT_FONTSIZE           = 15
		CALL_GRAPH             = YES
		CALLER_GRAPH           = YES
		INTERACTIVE_SVG        = YES
		DOT_TRANSPARENT        = YES
		DOT_MULTI_TARGETS      = NO
		DOT_CLEANUP            = NO
		OPTIMIZE_OUTPUT_FOR_C  = YES
		DOT_FONTNAME           = Ubuntu
		EOF
		# command doxygen -u
	fi
	command doxygen "$@" 2> doxygen.log
	xdg-open html/index.html || firefox html/index.html
}
```
