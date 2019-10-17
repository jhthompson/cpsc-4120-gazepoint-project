set PYTHON=python

set WIDTH=1680
set HEIGHT=1050
set HERTZ=60
set DIST=22.44 REM 57 cm
set SCREEN=22

set INDIR=../../data/tutorial_etra18/
set IMGDIR= ../../stimulus/static/screenshots/

set PLTDIR=./plots/
set OUTDIR=./data/
set RAWDIR=./data/raw/

REM raw

REM %PYTHON% tsv2raw.py --removeblinks --indir=%INDIR% --group=adhd_ctrl --outdir=%RAWDIR% --width=%WIDTH% --height=%HEIGHT% --dist=%DIST%
REM %PYTHON% tsv2raw.py --removeblinks --indir=%INDIR% --group=pcl --outdir=%RAWDIR% --width=%WIDTH% --height=%HEIGHT% --dist=%DIST%
REM %PYTHON% tsv2raw.py --removeblinks --indir=%INDIR% --group=ctrl --outdir=%RAWDIR% --width=%WIDTH% --height=%HEIGHT% --dist=%DIST%
REM %PYTHON% tsv2raw.py --removeblinks --indir=%INDIR% --group=adhd --outdir=%RAWDIR% --width=%WIDTH% --height=%HEIGHT% --dist=%DIST%
REM %PYTHON% tsv2raw.py --removeblinks --indir=%INDIR% --group=adhd_ctrl --outdir=%RAWDIR% --width=%WIDTH% --height=%HEIGHT% --dist=%DIST%
REM %PYTHON% tsv2raw.py --removeblinks --indir=%INDIR% --group=aspd --outdir=%RAWDIR% --width=%WIDTH% --height=%HEIGHT% --dist=%DIST%
%PYTHON% tsv2raw.py --removeblinks --indir=%INDIR% --group=pilot --outdir=%RAWDIR% --width=%WIDTH% --height=%HEIGHT% --dist=%DIST%
