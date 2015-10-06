@echo off
REM Assume octave is installed either on C:\Octave or B:\Octave, 
REM and that test gui script is located in this directory

IF EXIST B:\ GOTO :RUN_FROM_B_DRIVE

C:\Octave\Octave-4.0.0\octave.vbs --no-gui --persist sim_main.m
exit

:RUN_FROM_B_DRIVE
B:\Octave\Octave-4.0.0\octave.vbs --no-gui --persist sim_main.m