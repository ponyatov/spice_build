# component versions

SPICE_VER = 27

# component source code arhives (excluding git-cloned)

SPICE_GZ = 

# component download URLs

SPICE_URL = 

# directories

CWD = $(CURDIR)
SRC = $(CWD)/src
TMP = $(CWD)/tmp
GZ = $(CWD)/gz
DOC = $(CWD)/doc

# tools

PROC_NUM = $(shell grep processor /proc/cpuinfo| wc -l)

WGET = wget -c

# default

.PHONY: all
all: dirs src doc

# directory structure

.PHONY: dirs
dirs:
	mkdir -p $(GZ) $(DOC)
	ln -fs ~/src $(SRC) ; ln -fs ~/tmp $(TMP)
	
# make source code
	
.PHONY: src
src:

# SPICE

.PHONY: spice
spice:

# manuals

.PHONY: doc
doc: $(DOC)/ngspice-$(SPICE_VER)-manual.pdf
$(DOC)/ngspice-$(SPICE_VER)-manual.pdf:
	$(WGET) -O $@ https://downloads.sourceforge.net/project/ngspice/ng-spice-rework/$(SPICE_VER)/ngspice-$(SPICE_VER)-manual.pdf

# required development packages

.PHONY: packages
packages:
	sudo apt install git make wget gcc g++
