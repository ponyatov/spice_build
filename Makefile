CWD = $(CURDIR)
SRC = $(CWD)/src
TMP = $(CWD)/tmp

.PHONY: all
all: dirs src

.PHONY: dirs
dirs:
	ln -fs ~/src $(SRC) ; ln -fs ~/tmp $(TMP)
	
.PHONY: src
src:

.PHONY: packages
packages:
	sudo apt install git make
