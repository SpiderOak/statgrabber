# This exists mainly for the purpose of "make install." The whole thing
# is interpreted code, so there's no real build requirement

PREFIX=/usr/local
PERL_LIB_DIR := $(shell perl -MConfig -e 'print $$Config::Config{"sitelibexp"}')
PYTHON_LIB_DIR := /usr/lib/python2.5/site-packages

all:
	echo There is no build step for statgrabber. Please 'make install'

install:
	-test -e /etc/init.d && cp init.d/statgrabber /etc/init.d
	-rm -f $(PREFIX)/sbin/statgrabber $(PREFIX)/sbin/statgrabber.pl
	cp statgrabber.pl $(PREFIX)/sbin/
	ln -s statgrabber.pl $(PREFIX)/sbin/statgrabber
	mkdir -p $(PERL_LIB_DIR)
	cp Statgrabber.pm $(PERL_LIB_DIR)
	mkdir -p $(PYTHON_LIB_DIR)
	cp Statgrabber.py $(PYTHON_LIB_DIR)
