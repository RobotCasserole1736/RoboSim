% sim_main.m
% Main Function
%
% This is the top level function for RoboSim.
%
% Created July 20, 2015 - Andrew Gurik & Chris Gerth
% 

%% INITIALIZE
sim_init;

%% MAIN SIMULATION LOOP
for n = 0:Ts:simTime

    %% get inputs
    in_proc;

    %% run plant
    robot_15;

    %% set outputs
    out_proc;

    % increment loop counter
    i=i+1;

end

%% POST PROCESSING
post_proc;