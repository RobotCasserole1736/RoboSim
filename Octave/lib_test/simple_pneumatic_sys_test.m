%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Copyright (C) 2015 FRC Team 1736 
%%%
%%% File: simple_pneumatic_sys_test.m
%%%
%%% Description: test running a cylinder with a compressor/tank together.
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
valve_state_input =   [0   0    1   1     0     0     1     1  ]; 
valve_state_times =   [0   2-Ts 2   20-Ts 20    40-Ts 40    SimEndTime];
F_load = 0;

%calculated inputs
num_timesteps = SimEndTime/Ts;

%preallocate outputs
rod_pos = zeros(1,num_timesteps);
f_flow = zeros(1,num_timesteps);
r_flow = zeros(1,num_timesteps);
sys_press = zeros(1,num_timesteps);
sys_current = zeros(1,num_timesteps);
time_vector = 0:Ts:(SimEndTime - Ts);

%init state variables
cur_outflow_rate = 0;
cur_sys_press = 0;

%Run main testcase

%initalize
pneumatic_cylinder(0,0,0,1);
compressor_and_tank(0,0,1);
pressure_sensor(0,1);
h = waitbar(0, "Running Simulation...");

for i = 1:1:num_timesteps %iterate by timestep
	t = time_vector(i); %calculate time
	waitbar(i/num_timesteps, h, sprintf("Running Simulation. (%d/%d)",i, num_timesteps));

	
	%calculate current input values from TC input data
	cur_valve_state = interp1(valve_state_times, valve_state_input, t);
	
	cur_comp_enable = pressure_sensor(cur_sys_press, 0);
	
	if(cur_valve_state)
		cur_front_press = 0;
		cur_rear_press = cur_sys_press;
	else
		cur_front_press = cur_sys_press;
		cur_rear_press = 0;
	end
	
	[sys_press(i), sys_current(i)] = compressor_and_tank(cur_comp_enable, cur_outflow_rate, 0);
	[f_flow(i), r_flow(i), rod_pos(i)] = pneumatic_cylinder(cur_front_press, cur_rear_press, F_load, 0);
	
	if(cur_valve_state)
		cur_outflow_rate = r_flow(i);
	else
		cur_outflow_rate = f_flow(i);
	end
	
	cur_sys_press = sys_press(i);

end
delete(h);

%display results


subplot(5,1,1);
plot(valve_state_times, valve_state_input);
title('ValveState vs. Time (S)');
subplot(5,1,2);
plot(time_vector, rod_pos);
title('Rod Pos (m) vs. Time(S)');
subplot(5,1,3);
plot(time_vector, f_flow,time_vector,r_flow);
title('Flows (Lps) vs. Time (S)');
subplot(5,1,4);
plot(time_vector, sys_press/6.89475729);
title('SystemPressure (psi) vs. Time (S)');
subplot(5,1,5);
plot(time_vector, sys_current);
title('CurrentDraw (A) vs. Time (S)');