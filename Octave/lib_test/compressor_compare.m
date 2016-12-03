%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Copyright (C) 2015 FRC Team 1736 
%%%
%%% File: compressor_compare.m
%%%
%%% Description: test running a cylinder with a compressor/tank together, deltaing compressor performance
%%% 
%%% Inputs:  user testcase
%%%
%%% Outputs: Plots of output data
%%%
%%%  Change Log:
%%%
%%%     12/3/2016 - Chris Gerth
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
SimEndTime = 41; %seconds
valve_state_input =   [0   0     1    1     0     0     1     1  ]; 
valve_state_times =   [0   15-Ts 15   25-Ts 25    35-Ts 35    SimEndTime];
F_load = 0;
tank_count = 1;

%calculated inputs
num_timesteps = SimEndTime/Ts;

%preallocate outputs
v_rod_pos = zeros(1,num_timesteps);
v_f_flow = zeros(1,num_timesteps);
v_r_flow = zeros(1,num_timesteps);
v_sys_press = zeros(1,num_timesteps);
v_sys_current = zeros(1,num_timesteps);

am_rod_pos = zeros(1,num_timesteps);
am_f_flow = zeros(1,num_timesteps);
am_r_flow = zeros(1,num_timesteps);
am_sys_press = zeros(1,num_timesteps);
am_sys_current = zeros(1,num_timesteps);

time_vector = 0:Ts:(SimEndTime - Ts);

%init state variables
cur_outflow_rate = 0;
cur_sys_press = 0;

%Run main testcase
h = waitbar(0, "Running Simulation...");

%First, Vaiar compressor

%initalize
pneumatic_cylinder(0,0,0,1);
compressor_and_tank(0,0,tank_count,1,1);
pressure_sensor(0,1);
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
	
	[v_sys_press(i), v_sys_current(i)] = compressor_and_tank(cur_comp_enable, cur_outflow_rate, tank_count, 1, 0);
	[v_f_flow(i), v_r_flow(i), v_rod_pos(i)] = pneumatic_cylinder(cur_front_press, cur_rear_press, F_load, 0);
	
	if(cur_valve_state)
		cur_outflow_rate = v_r_flow(i);
	else
		cur_outflow_rate = v_f_flow(i);
	end
	
	cur_sys_press = v_sys_press(i);

end

%Second, Andymark compressor

%initalize
pneumatic_cylinder(0,0,0,1);
compressor_and_tank(0,0,tank_count,2,1);
pressure_sensor(0,1);
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
	
	[am_sys_press(i), am_sys_current(i)] = compressor_and_tank(cur_comp_enable, cur_outflow_rate, tank_count, 2, 0);
	[am_f_flow(i), am_r_flow(i), am_rod_pos(i)] = pneumatic_cylinder(cur_front_press, cur_rear_press, F_load, 0);
	
	if(cur_valve_state)
		cur_outflow_rate = am_r_flow(i);
	else
		cur_outflow_rate = am_f_flow(i);
	end
	
	cur_sys_press = am_sys_press(i);

end




delete(h);


%display results


subplot(4,1,1);
plot(valve_state_times, valve_state_input);
title('ValveState (extend/retract) vs. Time (S)');
subplot(4,1,2);
plot(time_vector, v_rod_pos, time_vector, am_rod_pos);
legend('Vaiar 090', 'Andymark 1.1');
title('Rod Pos (m) vs. Time(S)');
subplot(4,1,3);
plot(time_vector, v_sys_press/6.89475729,time_vector, am_sys_press/6.89475729);
title('SystemPressure (psi) vs. Time (S)');
subplot(4,1,4);
plot(time_vector, v_sys_current,time_vector, am_sys_current);
title('CurrentDraw (A) vs. Time (S)');