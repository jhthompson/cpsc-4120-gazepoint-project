set PYTHON=python

REM use Butterworth?
set SMOOTH=False

set WIDTH=1680 
set HEIGHT=1050
set HERTZ=60
set DIST=22.44
set SCREEN=22

set BASELINE_T=2.0
set END_T=180.0

set XTILES=16
set YTILES=16

set INDIR=../result/
set IMGDIR=../src/static/
set PLTDIR=./plots/
set OUTDIR=./data/
set RAWDIR=./data/raw/

%PYTHON% ./filter.py --smooth=%SMOOTH% --indir=%RAWDIR% --imgdir=%IMGDIR% --dist=%DIST% --screen=%SCREEN% --width=%WIDTH% --height=%HEIGHT% --hertz=%HERTZ% --xtiles=%XTILES% --ytiles=%YTILES% --baselineT=%BASELINE_T% --endT=%END_T%
