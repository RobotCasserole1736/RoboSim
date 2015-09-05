%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Copyright (C) 2015 FRC Team 1736 
%%%
%%% File: Compressor_tank_test.m
%%%
%%% Description: test running the compressor model
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
SimEndTime = 15; %seconds
comp_enable_input = [0 0 1 1];
comp_enable_times = [0 1-Ts 1 SimEndTime];
comp_outflow_rate_Lps_input = [0 0];
comp_outflow_rate_Lps_times = [0 SimEndTime];


%calculated inputs
num_timesteps = SimEndTime/Ts;

%preallocate outputs
sys_press = zeros(1,num_timesteps);
sys_current = zeros(1,num_timesteps);
time_vector = 0:Ts:(SimEndTime - Ts);

%Run main testcase

%initalize
compressor_and_tank(0,0,1);
h = waitbar(0, "Running Simulation...");

for i = 1:1:num_timesteps %iterate by timestep
	t = time_vector(i); %calculate time
	waitbar(i/num_timesteps, h, sprintf("Running Simulation. (%d/%d)",i, num_timesteps));

	
	%calculate current input values from TC input data
	cur_comp_enable = interp1(comp_enable_times, comp_enable_input, t);
	cur_outflow_rate = interp1(comp_outflow_rate_Lps_times, comp_outflow_rate_Lps_input, t);
	
	[sys_press(i), sys_current(i)] = compressor_and_tank(cur_comp_enable, cur_outflow_rate, 0);

end
delete(h);

%display results


subplot(3,1,1);
plot(comp_enable_times, comp_enable_input);
title('Enable (Bool) vs. Time (S)');
subplot(3,1,2);
plot(time_vector, sys_press/6.89475729);
title('SystemPressure (psi) vs. Time (S)');
subplot(3,1,3);
plot(time_vector, sys_current);
title('CurrentDraw (A) vs. Time (S)');