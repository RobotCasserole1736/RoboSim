% sim_init.m
% Initialize Simulation Function
%
%   Contains initial and config values for the simulaion
%
% Created July 20, 2015 - Andrew Gurik & Chris Gerth
% 

%% Preload
clf;    % clear figure
%uncomment the path when we move to a library architecture:
%addpath("../lib");   % add the lib path to the sim

global Ts
global simTime
Ts = 0.1;
simTime = .5;

%% Load model
field_15; % load the field
robot_init_15; % Initialize Robot

%% Set Defaults

%% Physical size constants
robot_width = 2; %ft
robot_length = 3; %ft

% Initial Robot coordinates
robot_x_pos = 0; %ft
robot_y_pos = 0; %ft
robot_rotation = 0; %radians wrt. +y axis. 0 radians means robot is pointed straight up. 90 is pointed to the left

%initial voltage interfaces
motor_voltage = zeros(1,6);
solenoid_voltage = zeros(1,8);
left_load = 0;
right_load = 0;

%% Initialize Drawing
figure(1);
% set up figure axis
axis([-field_width/2 field_width/2 -field_length/2 field_length/2], "equal", "nolabel", "manual", "tic", "on");
% draw field
rectangle("Position", [-field_width/2 field_length/2 field_width field_length]);


% initialize plot vectors
t = zeros(1,simTime/Ts+1);
lms = lmt= rms = rmt = t;

%loop counter
i =1;


