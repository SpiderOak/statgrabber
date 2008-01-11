# This exists mainly for the purpose of "make install." The whole thing
# is interpreted code, so there's no real build requirement

PREFIX=/usr/local
PERL_LIB_DIR := $(shell perl -MConfig -e 'print $$Config::Config{"sitelibexp"}')

all:
	@echo There is no build step for statgrabber. Please \'make install\'.
	@echo To install only the libraries or binaries, use \'make install-lib\'
	@echo or \'make install-bin\', respectively.

install: install-lib install-bin

install-lib:
	mkdir -p $(PERL_LIB_DIR)
	cp Statgrabber.pm $(PERL_LIB_DIR)
	python setup.py install

install-bin:
	-test -e /etc/init.d && cp init.d/statgrabber /etc/init.d
	-rm -f $(PREFIX)/sbin/statgrabber $(PREFIX)/sbin/statgrabber.pl
	cp statgrabber.pl $(PREFIX)/sbin/
	ln -s statgrabber.pl $(PREFIX)/sbin/statgrabber
