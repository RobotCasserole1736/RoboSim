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

%Calculate the drivetrain's motion-inducing force magnititude
drivetrain_linear_force = (motor(1).torque + motor(2).torque)*...   %torque from motors (Nm)
                          robot_config.drive_motors_per_side*...    %multiplier for multiple drive motors per side (unitless)
                          (1/(robot_config.wheel_diameter))*...     %wheel lever arm (1/m)
					      (1/robot_config.gear_ratio(1));           %torque ratio = 1/gear ratio (unitless)
                          
%Calculate the drivetrain's rotation-inducing force magnititude                         
drivetrain_rotational_torque = (-motor(1).torque + motor(2).torque)*...   %torque from motors (Nm)
                                robot_config.drive_motors_per_side*...   %multiplier for multiple drive motors per side (unitless)
                                (1/(robot_config.wheel_diameter))*...    %wheel lever arm (1/m)
                                robot_config.motor_width*...             %drivetrain force lever arm (m)
					            (1/robot_config.gear_ratio(1));          %torque ratio = 1/gear ratio (unitless) 

%Calculate the force of friction exterted by the drivetrain
%Assuming only kinetic friction now  
delta_angle = atan2(robot_state.linear_vel_y,robot_state.linear_vel_x) - robot_state.rotation;
perp_vel= sqrt(robot_state.linear_vel_x^2 + robot_state.linear_vel_y^2)*sin(delta_angle);
wheel_frictional_force = -robot_config.coef_fric_kin_wheel_floor_net*...   % coefficent of friction
                         (perp_vel);

%Calculate linear component of acceleration
%F/m = a in 2D				
robot_state.linear_accel_x = (drivetrain_linear_force*cos(robot_state.rotation)+wheel_frictional_force*-sin(robot_state.rotation))/mass_kg;
robot_state.linear_accel_y = (drivetrain_linear_force*sin(robot_state.rotation)+wheel_frictional_force*cos(robot_state.rotation))/mass_kg;
%T/I = alpha with a totally fudged-up moment of inertia calculation modeling the robot as a uniform rectangular prisim of some dimensions roughly related to the actual dimensions.
robot_state.rotational_accel = drivetrain_rotational_torque/(1/12 * mass_kg * ((0.9*robot_config.half_length*2)^2 + (robot_config.motor_width*2)^2));

%Discrete-time integration of accelerations to get velocities
robot_state.linear_vel_x = robot_state.linear_vel_x + robot_state.linear_accel_x*Ts;
robot_state.linear_vel_y = robot_state.linear_vel_y + robot_state.linear_accel_y*Ts;
robot_state.rotational_vel = robot_state.rotational_vel + robot_state.rotational_accel*Ts;

%Discrete-time integration of velocity to get pos
robot_state.pos_x = robot_state.pos_x + robot_state.linear_vel_x*Ts;
robot_state.pos_y = robot_state.pos_y + robot_state.linear_vel_y*Ts;
robot_state.rotation = robot_state.rotation + robot_state.rotational_vel*Ts;

motor(1).speed = (robot_state.linear_vel_x*cos(robot_state.rotation) +...
                  robot_state.linear_vel_y*sin(robot_state.rotation) +...
                 -robot_state.rotational_vel*robot_config.motor_width) *...    % linear speed at wheel location(m/s)
                    (1/robot_config.wheel_diameter*pi)*...             % 1/wheel circumfrence (rev/m)
					(2*pi)*...                                         % (rad/rev)
                    1/robot_config.gear_ratio(1);                      % Gear ratio, inverse b/c motor rotates faster than wheels
                    
motor(2).speed = (robot_state.linear_vel_x*cos(robot_state.rotation) +...
                  robot_state.linear_vel_y*sin(robot_state.rotation) +...
                  robot_state.rotational_vel*robot_config.motor_width) *...     % linear speed at wheel location(m/s)
                    (1/robot_config.wheel_diameter*pi)*...             % 1/wheel circumfrence (rev/m)
					(2*pi)*...                                         % (rad/rev)
                    1/robot_config.gear_ratio(1);                      % Gear ratio, inverse b/c motor rotates faster than wheels


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
