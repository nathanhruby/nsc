VER=$(shell cd .. ; basename `pwd`)

dist: clean
	mkdir tmp
	( cd ../.. ; tar cf - $(VER) --exclude CVS --exclude dist ) | ( cd tmp ; tar xf - )
	( cd tmp/$(VER) ; rm -rf cf cf.ucw ; mv cf.dist cf )
	( cd tmp ; tar czvvf /tmp/$(VER).tar.gz $(VER) )
	rm -rf tmp

clean:
	if [ -f ../Makefile ] ; then cd .. ; make distclean ; fi
	rm -f `find .. -name "*~" -or -name "*.[oa]" -or -name "\#*\#" -or -name TAGS -or -name core`
	rm -rf tmp

#dist: clean
#	sh -c 'cd .. ; X=`pwd` ; X=`basename $$X` ; cd .. ; tar czvvf /tmp/$$X.tar.gz $$X --exclude CVS --exclude dist'
