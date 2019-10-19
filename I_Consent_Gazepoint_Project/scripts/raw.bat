set PYTHON=py -2

set INDIR=../../exp/1680x1050/demo/
set IMGDIR=../../stimulus/1680x1050/

set PLTDIR=./plots/
set OUTDIR=./data/
set RAWDIR=./data/raw/

REM raw
%PYTHON% csv2raw.py --indir=%INDIR% --outdir=%RAWDIR%
