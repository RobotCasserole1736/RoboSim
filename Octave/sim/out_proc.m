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
global s1
global use_serial

%% pass outputs
lmv(i) = motor(1,1).voltage;
lms(i) = motor(1,1).speed;
lmt(i) = motor(1,1).torque;
lml(i) = motor(1,1).load_torque;
rmv(i) = motor(2,1).voltage;
rms(i) = motor(2,1).speed;
rmt(i) = motor(2,1).torque;
rml(i) = motor(2,1).load_torque;
t(i) = n;

%% serial write

if (use_serial)
    %TX packet stubbed to zeros for now.
	tx_packet = serial_assemble_packet([0,0,0,0,0,0,0,0], [0,0], [32000, 32000, 32000, 32000], [0,0,0,0]);
	serial_write_packet(s1, tx_packet);
end

%% visual processing
% draw robot