@ECHO OFF
ECHO Converting '%1.m' to '%1.sce'
IF EXIST %~dp0sed\sed.exe (
  %~dp0sed\sed -f %~dp0_m2s.sed  < %1.m > %1.sce
) ELSE (
  sed -f %~dp0_m2s.sed  < %1.m > %1.sce
)