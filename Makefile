# component versions

SPICE_VER = 27

# component name with version

SPICE = ngspice-$(SPICE_VER)

# component source code arhives (excluding git-cloned)

SPICE_GZ  = $(SPICE).tar.gz
SPICE_PDF = $(SPICE)-manual.pdf 

# component download URLs

SPICE_URL = https://downloads.sourceforge.net/project/ngspice/ng-spice-rework/$(SPICE_VER)

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
all: dirs doc src

# directory structure

.PHONY: dirs
dirs:
	mkdir -p $(GZ) $(DOC)
	ln -fs ~/src $(SRC) ; ln -fs ~/tmp $(TMP)
	
# make source code

.PHONY: gz
gz: $(GZ)/$(SPICE_GZ)

.PHONY: src
src:

$(SRC)/%/configure: $(GZ)/%.tar.gz
	cd $(SRC) ; tar zx < $< && touch $@

# SPICE

.PHONY: spice
spice: spice/bin/ngspice
spice/bin/ngspice: $(SRC)/$(SPICE)/configure
	rm -rf $(TMP)/$(SPICE) ; mkdir $(TMP)/$(SPICE) ; cd $(TMP)/$(SPICE) ;\
	$< --prefix=$(CWD)/$@ && $(MAKE) -j$(PROC_NUM) && $(MAKE) install
$(GZ)/$(SPICE_GZ):
	$(WGET) -O $@ $(SPICE_URL)/$(SPICE_GZ)

# manuals

.PHONY: doc
doc: $(DOC)/$(SPICE_PDF)
$(DOC)/$(SPICE_PDF):
	$(WGET) -O $@ $(SPICE_URL)/$(SPICE_PDF)

# required development packages

.PHONY: packages
packages:
	sudo apt install git make wget gcc g++
