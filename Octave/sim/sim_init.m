% sim_init.m
% Initialize Simulation Function
%
%   Contains initial and config values for the simulaion
%
% Created July 20, 2015 - Andrew Gurik & Chris Gerth
% 

%% Preload

%Log some things
disp(sprintf('\n\n'));
disp('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~');
disp('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~');
disp(['~~~~~~~~~~RoboSim Plant Model Log Started ', datestr(now)])
disp('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~');
disp('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~');


clf;    % clear figure
%uncomment the path when we move to a library architecture:
%addpath("../lib");   % add the lib path to the sim

global Ts %sample time (seconds)
global simTime %total length os simulation run
global s1 %serial port for robosim coms
global use_serial


Ts = 0.05;
simTime = 5;
use_serial = 0; %if set to 1, robosim hardware will be used for IO. Otherwise, test vectors in a purely PC environment will be used.
enforce_realtime = 1; %if set to 1, delays simulation to display in real-time. if 0, runs sim as fast as the PC can.
                      %Sim is always real-time if serial is used.

%% Load model
field_init_15; % load the field
robot_init_15; % Initialize Robot


%% Set Defaults

% initialize plot vectors (only time for now?)
t = zeros(1,simTime/Ts+1);
lmv = zeros(1,simTime/Ts+1);
lms = zeros(1,simTime/Ts+1);
lmt = zeros(1,simTime/Ts+1);
rmv = zeros(1,simTime/Ts+1);
rms = zeros(1,simTime/Ts+1);
rmt = zeros(1,simTime/Ts+1);
rb_x_vel = zeros(1,simTime/Ts+1);
rb_x_pos = zeros(1,simTime/Ts+1);
rb_y_vel = zeros(1,simTime/Ts+1);
rb_y_pos = zeros(1,simTime/Ts+1);
rb_rot_vel = zeros(1,simTime/Ts+1);
rb_cur_draw = zeros(1,simTime/Ts+1);
rb_bat_chg = zeros(1,simTime/Ts+1);
rb_sply_v = zeros(1,simTime/Ts+1);
rb_sys_press = zeros(1,simTime/Ts+1);



%loop counter
i = 1;

%initalize serial connection
if(use_serial)
    %Look for RoboSim on the serial ports
    ser_port_name = serial_detect_port();
    if(ischar(ser_port_name) || ser_port_name ~= -1)
        %Open serial port.
        s1 = serial_open_port(ser_port_name,0.1);
    else
        disp("Cannot find robosim! Serial coms will not take place!");
        s1 = -1;
    end
else
    s1 = -1;
end


