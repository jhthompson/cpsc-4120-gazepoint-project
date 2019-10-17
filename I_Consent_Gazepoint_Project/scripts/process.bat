set PYTHON=python

REM use Butterworth?
set SMOOTH=False

set WIDTH=1024
set HEIGHT=768
set HERTZ=500
set DIST=23.62
set SCREEN=19

set BASELINE_T=2.0
set END_T=180.0

set XTILES=16
set YTILES=16

set INDIR=../../data/tutorial_etra18/
set IMGDIR=../../stimulus/static/screenshots/
set PLTDIR=./plots/
set OUTDIR=./data/
set RAWDIR=./data/raw/

%PYTHON% ./filter.py --smooth=%SMOOTH% --indir=%RAWDIR% --imgdir=%IMGDIR% --dist=%DIST% --screen=%SCREEN% --width=%WIDTH% --height=%HEIGHT% --hertz=%HERTZ% --xtiles=%XTILES% --ytiles=%YTILES% --baselineT=%BASELINE_T% --endT=%END_T%
