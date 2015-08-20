%in_proc.m
% Input Processing
%
% This should run at the beginning of each simulation loop to read the inputs and populate model
% input interfaces.
%
% Created August 1, 2015 - Andrew Gurik & Chris Gerth
% 

% required physical inputs:
%   6x motor voltage
%   8x solenoid voltage

% these should read from the serial interface
in = ...
struct  (
        'motor_voltage',    [12,12,0,0,0,0],... % array of input motor voltages
        'solenoid_voltage', [0,0,0,0,0,0,0,0]   % array of input solenoid voltages
        );