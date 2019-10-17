UNAME           = $(shell uname)

ifeq ($(UNAME),Linux)
#PYTHON = /opt/modules/python/2.7/bin/python2.7
PYTHON = /usr/bin/python2
endif

ifeq ($(UNAME),Darwin)
#PYTHON = /usr/local/bin/python
#PYTHON = /usr//bin/python
#PYTHON = /sw//bin/python2.7
#PYTHON = python2
PYTHON = /opt/local/bin/python2.7
endif

# use Butterworth?
SMOOTH = False

WIDTH = 1024
HEIGHT = 768
#WIDTH = 1280
#HEIGHT = 1024
HERTZ = 500
DIST = 23.62 # 60 cm
SCREEN = 19

BASELINE_T = 2.0
END_T = 180.0

#XTILES = 4
#YTILES = 3
#XTILES = 8
#YTILES = 4
XTILES = 8
YTILES = 3
#XTILES = 8
#YTILES = 6
#XTILES = 8
#YTILES = 8
#XTILES = 16
#YTILES = 12
#XTILES = 16
#YTILES = 16

INDIR = ../result/
IMGDIR = ../src/

PLTDIR = ./plots/
OUTDIR = ./data/
RAWDIR = ./data/raw/

#all: dirs raw process graph
#all: process collate
all: dirs raw process collate stats
#all: dirs raw graph
# all: dirs raw process collate 

off:
	@echo "Currently turned off so as not to trigger the whole run."
	@echo "If you want to, run individual targets, e.g.:"
	@echo "   make dirs"
	@echo "   make raw"
	@echo "   make process"
	@echo "   make collate"
	@echo "   make stats"

dirs:
	mkdir -p data
	mkdir -p data/raw
	mkdir -p figs
	mkdir -p plots
	mkdir -p graphs

# old: from exp2
#raw: radhd_ctrl rpcl radhd rctrl raspd
raw: rpilot
rpilot:
	$(PYTHON) ./tsv2raw.py --removeblinks --indir=$(INDIR) --group=pilot --outdir=$(RAWDIR) --width=$(WIDTH) --height=$(HEIGHT) --dist=$(DIST)
rpcl:
	$(PYTHON) ./tsv2raw.py --removeblinks --indir=$(INDIR) --group=pcl --outdir=$(RAWDIR) --width=$(WIDTH) --height=$(HEIGHT) --dist=$(DIST)
rctrl:
	$(PYTHON) ./tsv2raw.py --removeblinks --indir=$(INDIR) --group=ctrl --outdir=$(RAWDIR) --width=$(WIDTH) --height=$(HEIGHT) --dist=$(DIST)
radhd:
	$(PYTHON) ./tsv2raw.py --removeblinks --indir=$(INDIR) --group=adhd --outdir=$(RAWDIR) --width=$(WIDTH) --height=$(HEIGHT) --dist=$(DIST)
raspd:
	$(PYTHON) ./tsv2raw.py --removeblinks --indir=$(INDIR) --group=aspd --outdir=$(RAWDIR) --width=$(WIDTH) --height=$(HEIGHT) --dist=$(DIST)

process:
	$(PYTHON) ./filter.py --smooth=$(SMOOTH) --indir=$(RAWDIR) --imgdir=$(IMGDIR) --dist=$(DIST) --screen=$(SCREEN) --width=$(WIDTH) --height=$(HEIGHT) --hertz=$(HERTZ) --xtiles=$(XTILES) --ytiles=$(YTILES) --baselineT=$(BASELINE_T) --endT=$(END_T)
#	$(PYTHON) ./filter-sacc.py --smooth=$(SMOOTH) --indir=$(RAWDIR) --imgdir=$(IMGDIR) --dist=$(DIST) --screen=$(SCREEN) --width=$(WIDTH) --height=$(HEIGHT) --hertz=$(HERTZ) --xtiles=$(XTILES) --ytiles=$(YTILES) --baselineT=$(BASELINE_T) --endT=$(END_T)

graph:
	$(PYTHON) ./graph.py --smooth=$(SMOOTH) --indir=$(RAWDIR) --imgdir=$(IMGDIR) --dist=$(DIST) --screen=$(SCREEN) --width=$(WIDTH) --height=$(HEIGHT) --hertz=$(HERTZ) --xtiles=$(XTILES) --ytiles=$(YTILES) --baselineT=$(BASELINE_T) --endT=$(END_T) --outdir=$(OUTDIR) --pltdir=$(PLTDIR) --image="grey-1280x1024.png"

collate:
	$(PYTHON) ./collate-amfo.py
	$(PYTHON) ./collate-sacc.py
	$(PYTHON) ./collate-msac.py
	$(PYTHON) ./collate-msrt.py
	$(PYTHON) ./collate-pICA.py
	$(PYTHON) ./collate-fxtn.py
	$(PYTHON) ./collate-fxtn-aois.py

fits:
	R --vanilla < msac.R > msac.out
	R --vanilla < sacc.R > sacc.out
	R --vanilla < msac-sacc.R > msac-sacc.out
#	R --vanilla < msrt.R > msrt.out
#	R --vanilla < pICA.R > pICA.out
#	R --vanilla < pcpd.R > pcpd.out
#	R --vanilla < bpcpd.R > bpcpd.out
#	@echo "Nothing to do yet."

stats:
	R --vanilla --args 4 < tm.R > tm.out
	R --vanilla < f_AOI.R > f_AOI.out
	R --vanilla < f_general.R > f_general.out

#	R --vanilla < f_msac.R > f_msac.out
#	R --vanilla < f_msrt.R > f_msrt.out
#	R --vanilla < f_pICA.R > f_pICA.out

#	R --vanilla < f_pcpd.R > f_pcpd.out
#	R --vanilla < f_bpcpd.R > f_bpcpd.out
#	R --vanilla < f_sacc.R > f_sacc.out
#	R --vanilla < amfo.R > amfo.out

clean: 
	rm -f *.pyc 
	rm -rf plots
	rm -rf data
	rm -rf graphs
	rm -rf figs
	rm -f *.out
	rm -f *.pdf
	rm -rf figs/TMS
