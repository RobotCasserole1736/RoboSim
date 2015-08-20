%out_proc.m
% Output Processing
%
% This should run at the end of each simulation loop to read and process output interfaces.
%
% Created August 1, 2015 - Andrew Gurik & Chris Gerth
% 

% required physical outputs:
%   8 digital
%   2 analog
%   4 quadrature

%% pass outputs
lms(i) = motor(1,1).speed;
lmt(i) = motor(1,1).torque;
lml(i) = motor(1,1).load_torque;
rms(i) = motor(2,1).speed;
rmt(i) = motor(2,1).torque;
rml(i) = motor(2,1).load_torque;
t(i) = n;

%% serial write

%% visual processing
% draw robot