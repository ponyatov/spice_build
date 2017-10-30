.PHONY: all
all: dirs

.PHONY: dirs
dirs:
	ln -fs ~/src src ; ln -fs ~/tmp tmp

.PHONY: packages
packages:
	sudo apt install git make
