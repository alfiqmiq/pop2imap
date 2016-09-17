
# $Id: Makefile,v 1.3 2015/04/17 17:51:52 gilles Exp gilles $	

TARGET=pop2imap

.PHONY: help usage all

help: usage

usage:
	@echo "      $(TARGET) $(VERSION), You can do :"
	@echo make install # as root
	@echo make testf   # run tests
	@echo make testv   # run tests verbosely
	@echo make all     

all: test ChangeLog README VERSION

.PHONY: test testp testf

.test: $(TARGET) tests.sh
	sh tests.sh 1>/dev/null
	touch .test

testv:
	sh -x tests.sh

test: .test

testf: clean_test test

testp :
	perl -c $(TARGET)

ChangeLog: $(TARGET)
	rlog $(TARGET) > ChangeLog

README: $(TARGET)
	perldoc -t $(TARGET) > README

VERSION: $(TARGET) Makefile
	./$(TARGET) --version > VERSION

.PHONY: clean clean_tilde clean_test   

clean: clean_tilde clean_test

clean_test:
	rm -f .test

clean_tilde:
	rm -f *~

.PHONY: install dist

install: testp
	cp $(TARGET) /usr/bin/$(TARGET)
	chmod 755 /usr/bin/$(TARGET)

DIST_NAME=$(TARGET)-$(VERSION)
DIST_FILE=$(DIST_NAME).tgz
VERSION=$(shell ./$(TARGET) --version)

dist: cidone clean clean_dist all INSTALL  
	echo making tarball $(DIST_FILE)
	mkdir -p dist
	mkdir -p ../prepa_dist/$(DIST_NAME)
	rsync -aCv --delete ./  ../prepa_dist/$(DIST_NAME)
	cd ../prepa_dist && tar czfv $(DIST_FILE) $(DIST_NAME)
	cp -f ../prepa_dist/$(DIST_FILE) dist/
	cd dist && md5sum $(DIST_FILE) > $(DIST_FILE).md5
	cd dist && md5sum -c $(DIST_FILE).md5



.PHONY: cidone clean_dist

cidone:
	rcsdiff RCS/*

clean_dist:
	rm -f dist/*

# Local goals

.PHONY: lfo


lfo: cidone dist 
	rsync -av --delete . \
	/home/gilles/public_html/www.linux-france.org/html/prj/$(TARGET)/
	sh ~/memo/lfo-rsync

ks: cidone
	rsync -av --delete . \
	gilles@ks.lamiral.info:public_html/$(TARGET)/

