% sim_main.m
% Main Function
%
% This is the top level function for RoboSim.
%
% Created July 20, 2015 - Andrew Gurik & Chris Gerth
% 

global Ts 
global use_serial

%% INITIALIZE

%Clear all pre-existing variables
clear;
clc;
%import serial modules
pkg load instrument-control
%Add paths for execution
addpath('..\SerialUtils\');  % Serial coms utilities
addpath('..\lib\');          % component model libraries
%Enable logging to file (mostly for headless runs)
diary "RoboSim_plant_log.txt"

sim_init;
h = waitbar(0, "Running Simulation...");

%start timer for maintaining periodic loop rate
tic();

%% MAIN SIMULATION LOOP
for n = 0:Ts:simTime
    %mark loop start time
    loop_start_time = toc();
    waitbar(i/(simTime/Ts+1), h, sprintf("Running Simulation. (%d/%d)",i, (simTime/Ts+1)));

    %% get inputs
    in_proc;

    %% run robot plant
    robot_15;
    
    %% check robot field interactions
    field_robot_physics;

    %% set outputs
    out_proc;

    if(use_serial || enforce_realtime)
        %enforce real-time execution only if running serial
        if(loop_start_time + Ts > toc())
            %disp(sprintf('pause for %d s', (loop_start_time + Ts) - toc()));
            pause((loop_start_time + Ts) - toc()); %Crucial pause - times the main loop, and gives the GUI a chance to register mouse clicks and update gui and stuff
        else
            warning("Real-Time loop timing missed! Behind sample rate by %d s", toc() -(loop_start_time + Ts) );
            pause(0); %we still need to pause for a bit otherwise the GUI won't update.
        end
    end
        
    
    % increment loop counter
    i=i+1;

end

%% POST PROCESSING
post_proc;