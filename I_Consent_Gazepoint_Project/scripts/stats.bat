set R="C:\Program Files\R\R-3.5.0\bin\R.exe"

REM stats
%R% --vanilla < f_AOI.R > f_AOI.out
%R% --vanilla < f_general.R > f_general.out
%R% --vanilla --args 4 < tm.R > tm.out
%R% --vanilla < K_coefficient.R > K_coefficient.out

