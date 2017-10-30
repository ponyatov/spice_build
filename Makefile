CWD = $(CURDIR)
SRC = $(CWD)/src
TMP = $(CWD)/tmp
GZ = $(CWD)/gz

PROC_NUM = $(shell grep processor /proc/cpuinfo| wc -l)

WGET = wget -c

.PHONY: all
all: dirs src

.PHONY: dirs
dirs:
	mkdir -p $(GZ)
	ln -fs ~/src $(SRC) ; ln -fs ~/tmp $(TMP)
	
.PHONY: src
src:

.PHONY: packages
packages:
	sudo apt install git make
