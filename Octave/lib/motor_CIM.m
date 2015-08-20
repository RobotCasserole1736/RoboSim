% motor_CIM.m
% CIM Motor Model
%
%   This function takes in the real motor voltage, load torque, previous torque, 
%   and previous speed. Then returns a new torque and new speed.
%
% Created July 20, 2015 - Andrew Gurik & Chris Gerth
% 
function [speed, torque] = motor_CIM(voltage, load_torque, torque_prev, speed_prev)

% access the Ts global
global Ts

%Constants, motor-specific.
%See http://files.andymark.com/CIM-motor-curve-am-0255.pdf
Rc = 0.3; %ohms, for full CIM motor. Didn't have an Ohmmeter that could measure this, so just kinda guessed.
Lc = 0.02; %henries, just a guess based on what made things look nice
Kt = 2.429/131.227; %Nm/A - for CIM motor. Calculated from Stall Torque/Stall Current
Ki = (12-(2.7*Rc))/(5310*2*pi/60); %V/(rad/s). Calculated from Vemf@FreeSpeed/(2pi/60*RPM@FreeSpeed). Steady-state Vemf = Vs - I@FreeSpeed*Rc, for Vs = 12

%The following are again total guesses, this data is not available anywhere I can find.
Kf = 0.25; %Kinetic rotational coefficent of friction in Nm-s for motor
Tfs = 0.2; %Static friction maximum torque magnititude
speed_mag_zero_limit = 10; %in rad/sec This and below define pratical deadzones for speed 

SystemMomentOfInertia = 0.555 * 0.0254^2; % kg-m^2 - just a guess the rotating member of CIM - model as 1.25lb, 1 in. radius solid cylinder

% torque calculation
torque = torque_prev + Ts*(Kt/Lc * (voltage - torque_prev*Rc/Kt - Ki*speed_prev));

%If motor is rotating, speed is increased by torque and decreased by friction
if(abs(speed_prev) > speed_mag_zero_limit)
    speed = speed_prev + Ts*(1/SystemMomentOfInertia * (torque_prev-load_torque) - Kf*speed_prev );
%If motor is stopped  
else
    %If torque has exceeded static friction, the motor may spin per normal equations
    if(abs(torque_prev) > Tfs )
        speed = speed_prev + Ts*(1/SystemMomentOfInertia * (torque_prev-load_torque) - Kf*speed_prev);
    %Else, motor sticks and speed remains zero
    else
        speed = 0;
    end
end