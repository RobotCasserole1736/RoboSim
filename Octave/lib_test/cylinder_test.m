%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Copyright (C) 2015 FRC Team 1736 
%%%
%%% File: cylinder_test.m
%%%
%%% Description: test running the model of a pneumatic cylinder
%%% 
%%% Inputs:  user testcase
%%%
%%% Outputs: Plots of output data
%%%
%%%  Change Log:
%%%
%%%     9/5/2015 - Chris Gerth
%%%       -Created
%%%        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Add paths for plant component libraries
addpath('..\lib\'); 


global Ts;
%Declare constants
Ts = 0.1; %Sample time, seconds

%Define testcase
SimEndTime = 70; %seconds
cyl_rear_press_input =   [0   0    500   500   250   250   350   350       ]; 
cyl_rear_press_times =   [0   2-Ts 2     20-Ts 20    40-Ts 40    SimEndTime];
cyl_front_press_input =  [0   0    0     0     500   500   250   250       ]; 
cyl_front_press_times =  [0   2-Ts 2     20-Ts 20    40-Ts 40    SimEndTime];
F_load = 0;

%calculated inputs
num_timesteps = SimEndTime/Ts;

%preallocate outputs
rod_pos = zeros(1,num_timesteps);
f_flow = zeros(1,num_timesteps);
r_flow = zeros(1,num_timesteps);
time_vector = 0:Ts:(SimEndTime - Ts);

%Run main testcase

%initalize
pneumatic_cylinder(0,0,0,1);
h = waitbar(0, "Running Simulation...");

for i = 1:1:num_timesteps %iterate by timestep
	t = time_vector(i); %calculate time
	waitbar(i/num_timesteps, h, sprintf("Running Simulation. (%d/%d)",i, num_timesteps));

	
	%calculate current input values from TC input data
	cur_front_press = interp1(cyl_front_press_times, cyl_front_press_input, t);
	cur_rear_press  = interp1(cyl_rear_press_times, cyl_rear_press_input, t);
	
	
	[f_flow(i), r_flow(i), rod_pos(i)] = pneumatic_cylinder(cur_front_press, cur_rear_press, F_load, 0);

end
delete(h);

%display results


subplot(3,1,1);
plot(cyl_front_press_times, cyl_front_press_input/6.89475729,cyl_rear_press_times,cyl_rear_press_input/6.89475729);
title('Pressures (psi) vs. Time (S)');
subplot(3,1,2);
plot(time_vector, rod_pos);
title('Rod Pos (m) vs. Time(S)');
subplot(3,1,3);
plot(time_vector, f_flow,time_vector,r_flow);
title('Flows (Lps) vs. Time (S)');