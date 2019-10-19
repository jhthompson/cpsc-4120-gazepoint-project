set PYTHON=py -2

REM collate
%PYTHON% -W ignore collate-fxtn-aois.py
%PYTHON% -W ignore collate-anns.py
%PYTHON% -W ignore collate-aois.py
