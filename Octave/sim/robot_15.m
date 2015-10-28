% robot_15.m
% 2015 Robot Model
%
% This is the physical model of the robot_config.
%
% Created July 20, 2015 - Andrew Gurik & Chris Gerth
% 

% mass (kg)
mass_kg = 0.453592*robot_config.weight; % pounds to kilograms

%% Drivetrain

%% Get Motor Voltage
% Left
motor(1).voltage = in.motor_voltage(1);
% Right
motor(2).voltage = in.motor_voltage(2);

%% Physics Model

% calculate new torques for this loop
% Left
[garbage, motor(1).torque] = motor_CIM(motor(1).voltage,...
										  0,...
										  motor(1).torque,...
										  motor(1).speed);
% Right
[garbage, motor(2).torque] = motor_CIM(motor(2).voltage,...
										 0,...
										 motor(2).torque,...
										 motor(2).speed);

robot_x_force_net = (motor(1).torque + motor(2).torque)*...   %torque from motors (Nm)
                    robot_config.drive_motors_per_side*...    %multiplier for multiple drive motors per side (unitless)
                    (1/(robot_config.wheel_diameter))*...     %wheel lever arm (1/m)
					(1/robot_config.gear_ratio(1));           %torque ratio = 1/gear ratio (unitless)
                    
robot_y_force_net = 0;

%F/m = a					
robot_state.linear_accel_x = robot_x_force_net/mass_kg;
robot_state.linear_accel_y = robot_y_force_net/mass_kg;

%Discrete-time integration of acceleration to get velocity
robot_state.linear_vel_x = robot_state.linear_vel_x + robot_state.linear_accel_x*Ts;
robot_state.linear_vel_y = robot_state.linear_vel_y + robot_state.linear_accel_y*Ts;

motor(1).speed = robot_state.linear_vel_x *...             % linear speed (m/s)
                    (1/robot_config.wheel_diameter*pi)*... % 1/wheel circumfrence (rev/m)
					(2*pi);                                % (rad/rev)
motor(2).speed = robot_state.linear_vel_x *...             % linear speed (m/s)
                    (1/robot_config.wheel_diameter*pi)*... % 1/wheel circumfrence (rev/m)
					(2*pi);                                % (rad/rev)

%Discrete-time integration of velocity to get pos
robot_state.pos_x = robot_state.pos_x + robot_state.linear_vel_x*Ts;
robot_state.pos_y = robot_state.pos_y + robot_state.linear_vel_y*Ts;

% repopulate speed_prev
% Left
motor(1).speed_prev = motor(1).speed;
% Right
motor(2).speed_prev = motor(2).speed;

%update robot state
robot_state.linear_vel_x_prev = robot_state.linear_vel_x;
robot_state.linear_vel_y_prev = robot_state.linear_vel_y;
robot_state.pos_x_prev = robot_state.pos_x;
robot_state.pos_y_prev = robot_state.pos_y;
