clean:
	if [ -f ../Makefile ] ; then cd .. ; make distclean ; fi
	rm -f `find .. -name "*~" -or -name "*.[oa]" -or -name "\#*\#" -or -name TAGS -or -name core`

dist: clean
	sh -c 'cd .. ; X=`pwd` ; X=`basename $$X` ; cd .. ; tar czvvf /tmp/$$X.tar.gz $$X --exclude CVS --exclude dist'
