# component versions

SPICE_VER = 27

# component name with version

SPICE = ngspice-$(SPICE_VER)
FEMM = xfemm
KICAD = kicad

# component source code arhives (excluding git-cloned)

SPICE_GZ  = $(SPICE).tar.gz
SPICE_PDF = $(SPICE)-manual.pdf

FEMM_PDF  = femm-42-manual.pdf 

# component download URLs

SPICE_URL = https://downloads.sourceforge.net/project/ngspice/ng-spice-rework/$(SPICE_VER)
FEMM_PDF_URL = http://www.femm.info/Archives/doc/manual42.pdf

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
all: dirs doc src spice femm kicad

# directory structure

.PHONY: dirs
dirs:
	mkdir -p $(GZ) $(DOC)
	ln -fs ~/src $(SRC) ; ln -fs ~/tmp $(TMP)
	
# make source code

.PHONY: gz
gz: $(GZ)/$(SPICE_GZ)

.PHONY: src
src: \
	$(SRC)/$(SPICE)/configure $(TMP)/$(FEMM)/README.txt \
	$(SRC)/$(KICAD)/README.txt

$(SRC)/%/configure: $(GZ)/%.tar.gz
	cd $(SRC) ; tar zx < $< && touch $@

# SPICE

.PHONY: spice
spice: spice/bin/ngspice $(DOC)/$(SPICE_PDF)
spice/bin/ngspice: $(SRC)/$(SPICE)/configure
	rm -rf $(TMP)/$(SPICE) ; mkdir $(TMP)/$(SPICE) ; cd $(TMP)/$(SPICE) ;\
	$< --prefix=$(CWD)/$@ && $(MAKE) -j$(PROC_NUM) && $(MAKE) install
$(GZ)/$(SPICE_GZ):
	$(WGET) -O $@ $(SPICE_URL)/$(SPICE_GZ)
	
# FEMM

.PHONY: femm
femm: femm/fsolver $(DOC)/$(FEMM_PDF)
femm/fsolver: $(TMP)/$(FEMM)/cfemm/bin/fsolver
	cp -r $(TMP)/$(FEMM)/cfemm/bin femm
$(TMP)/$(FEMM)/cfemm/bin/fsolver: $(TMP)/$(FEMM)/README.txt
	cd $(TMP)/$(FEMM)/cfemm ; $(MAKE) clean ;\
	cmake . && $(MAKE) -j$(PROC_NUM)
$(TMP)/$(FEMM)/README.txt:
	hg clone http://hg.code.sf.net/p/xfemm/hgrepo $(TMP)/$(FEMM)
	
# KiCAD

.PHONY: kicad
kicad: $(SRC)/$(KICAD)/README.txt
	rm -rf $(TMP)/$(KICAD) ; mkdir $(TMP)/$(KICAD) ; cd $(TMP)/$(KICAD) ;\
	cmake -DCMAKE_INSTALL_PREFIX=$(CWD)/kicad $(SRC)/$(KICAD) &&\
	$(MAKE) -j$(PROC_NUM) && $(MAKE) install
$(SRC)/$(KICAD)/README.txt:
	git clone --depth=1 https://git.launchpad.net/kicad $(SRC)/$(KICAD) 

# manuals

.PHONY: doc
doc: $(DOC)/$(SPICE_PDF) $(DOC)/$(FEMM_PDF)
$(DOC)/$(SPICE_PDF):
	$(WGET) -O $@ $(SPICE_URL)/$(SPICE_PDF)
$(DOC)/$(FEMM_PDF):
	$(WGET) -O $@ $(FEMM_PDF_URL)

# required development packages

.PHONY: packages
packages:
	sudo apt install git make wget gcc g++ mercurial\
		libwxgtk3.0-dev libglew-dev libglm-dev \
		libcurl4-openssl-dev libssl-dev libcairo2-dev \
		libboost-dev libboost-test-dev
