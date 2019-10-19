set PYTHON=py -2
set WIDTH=1680
set HEIGHT=1050
::set WIDTH=2048
::set HEIGHT=1536
::set HERTZ=150
set HERTZ=60
set DIST=25.59
set SCREEN=13
::set XTILES=16
::set YTILES=12
set XTILES=4
set YTILES=2

REM use Butterworth?
set SMOOTH=False

set INDIR=../../exp/1680x1050/demo/
set IMGDIR=../../stimulus/1680x1050/

set PLTDIR=./plots/
set OUTDIR=./data/
set RAWDIR=./data/raw/

REM process
%PYTHON% graph.py --smooth=%SMOOTH% --indir=%RAWDIR% --imgdir=%IMGDIR% --dist=%DIST% --screen=%SCREEN% --width=%WIDTH% --height=%HEIGHT% --hertz=%HERTZ% --xtiles=%XTILES% --ytiles=%YTILES% --outdir=%OUTDIR% --pltdir=%PLTDIR%
