% motor_CIM.m
% CIM Motor Model
%
%   This function takes in the real motor voltage (V), previous torque (Nm), 
%   and previous speed (rad/s). Then returns a new torque (Nm) and current draw (A).
%
% Created July 20, 2015 - Andrew Gurik & Chris Gerth
% 
function [current, torque] = motor_CIM(voltage, torque_prev, speed_prev)

% access the Ts global
global Ts

%Constants, motor-specific.
%See http://files.andymark.com/CIM-motor-curve-am-0255.pdf
Rc = 0.3; %ohms, for full CIM motor. Didn't have an Ohmmeter that could measure this, so just kinda guessed.
Lc = 0.02; %henries, just a guess based on what made things look nice
Kt = 2.429/131.227; %Nm/A - for CIM motor. Calculated from Stall Torque/Stall Current
Ki = (12-(2.7*Rc))/(5310*2*pi/60); %V/(rad/s). Calculated from Vemf@FreeSpeed/(2pi/60*RPM@FreeSpeed). Steady-state Vemf = Vs - I@FreeSpeed*Rc, for Vs = 12

% torque calculation
torque = torque_prev + Ts*(Kt/Lc * (voltage - torque_prev*Rc/Kt - Ki*speed_prev));

%current calculation
current = torque / Kt;

