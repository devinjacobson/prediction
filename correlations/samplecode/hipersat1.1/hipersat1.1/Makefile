include system/make.common

BIN=$(HIPERSAT)/bin
DOC=$(HIPERSAT)/doc

HIPERSAT_TOOLS = $(addprefix $(BIN)/,$(TOOLS))

all: HiPerSATClean objects tool $(HIPERSAT) $(BIN) $(DOC) $(HIPERSAT_TOOLS) docs eeglabs

objects:
	cd src; make all

tool:
	cd tools; make all

HiPerSATClean:
	rm -rf $(HIPERSAT)

$(HIPERSAT):
	mkdir $(HIPERSAT)

$(BIN):
	mkdir $(BIN)

$(DOC):
	mkdir $(DOC)

$(BIN)/%: bin/%
	cp $< $@

docs:
	cp doc/*.txt $(DOC)/.
	cp INSTALL $(DOC)/.
	cp LICENSE $(DOC)/.
	cp README $(HIPERSAT)/.

eeglabs:
	cp -R eeglab $(HIPERSAT)/.

clean:
	cd src; make clean; cd ../tools; make clean; cd ..; rm -rf $(HIPERSAT); cd server; make clean
