% robot_15.m
% 2015 Robot Model
%
% This is the physical model of the robot_config.
%
% Created July 20, 2015 - Andrew Gurik & Chris Gerth
% 

%% Drivetrain

%% Get Motor Voltage
%% scale by system voltage
% Left
motor(1).voltage = in.motor_voltage(1)*(robot_state.supply_voltage/robot_config.battery_nominal_voltage);
% Right
motor(2).voltage = in.motor_voltage(2)*(robot_state.supply_voltage/robot_config.battery_nominal_voltage);

%% Physics Model

% calculate new torques and currents for this loop
% Left
[motor(1).current, motor(1).torque] = motor_CIM(motor(1).voltage,...
                                                motor(1).torque,...
                                                motor(1).speed);
% Right
[motor(2).current, motor(2).torque] = motor_CIM(motor(2).voltage,...
                                                motor(2).torque,...
                                                motor(2).speed);

%Calculate the drivetrain's motion-inducing force magnititude
drivetrain_linear_force = (motor(1).torque + motor(2).torque)*...   %torque from motors (Nm)
                          robot_config.drive_motors_per_side*...    %multiplier for multiple drive motors per side (unitless)
                          (1/(robot_config.wheel_diameter))*...     %wheel lever arm (1/m)
                          (robot_calc_config.torque_ratio(1));      %torque ratio = 1/gear ratio (unitless)
                          
%Calculate the drivetrain's rotation-inducing force magnititude                         
drivetrain_rotational_torque = (-motor(1).torque + motor(2).torque)*...   %torque from motors (Nm)
                                robot_config.drive_motors_per_side*...    %multiplier for multiple drive motors per side (unitless)
                                (1/(robot_config.wheel_diameter))*...     %wheel lever arm (1/m)
                                robot_config.motor_width*...              %drivetrain force lever arm (m)
                                (robot_calc_config.torque_ratio(1));      %torque ratio = 1/gear ratio (unitless) 

%Calculate the force of friction exterted by the drivetrain
%Assuming only kinetic friction now  
delta_angle = atan2(robot_state.linear_vel_y,robot_state.linear_vel_x) - robot_state.rotation; %calculate any difference between the angle of motion, and the angle the wheels are pointed in
perp_vel= sqrt(robot_state.linear_vel_x^2 + robot_state.linear_vel_y^2)*sin(delta_angle);      %calculate the component of motion which is perpendicular to the direction the wheels are pointed at.
wheel_frictional_force = -robot_config.coef_fric_kin_wheel_floor_net*(perp_vel);               %F_fric = -coefficent of friction * velocity


%Calculate linear component of acceleration
%F/m = a in 2D                
robot_state.linear_accel_x = (drivetrain_linear_force*cos(robot_state.rotation)+wheel_frictional_force*-sin(robot_state.rotation))/robot_calc_config.mass_kg;
robot_state.linear_accel_y = (drivetrain_linear_force*sin(robot_state.rotation)+wheel_frictional_force*cos(robot_state.rotation))/robot_calc_config.mass_kg;
%T/I = alpha 
robot_state.rotational_accel = drivetrain_rotational_torque/robot_calc_config.moment_of_inertia;

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
                 -robot_state.rotational_vel*robot_config.motor_width) *...  % linear speed at wheel location(m/s)
                 (1/(robot_calc_config.wheel_circumference))*...             % 1/wheel circumfrence (rev/m)
                 (2*pi)*...                                                  % (rad/rev)
                 (1/(robot_config.gear_ratio(1)));                           % Gear ratio, inverse b/c motor rotates faster than wheels
                    
motor(2).speed = (robot_state.linear_vel_x*cos(robot_state.rotation) +...
                  robot_state.linear_vel_y*sin(robot_state.rotation) +...
                  robot_state.rotational_vel*robot_config.motor_width) *...  % linear speed at wheel location(m/s)
                 (1/(robot_calc_config.wheel_circumference))*...             % 1/wheel circumfrence (rev/m)
                 (2*pi)*...                                                  % (rad/rev)
                 (1/(robot_config.gear_ratio(1)));                           % Gear ratio, inverse b/c motor rotates faster than wheels

%Electrical calculations

%Sum the total current draw
robot_state.current_draw = (abs(motor(1).current) + abs(motor(2).current)) * robot_config.drive_motors_per_side + robot_config.nominal_current_draw;

%Update the battery charge based on current draw
robot_state.battery_charge = max(robot_state.battery_charge - robot_state.current_draw*Ts/3600,0); %Ts in seconds, charge in amp-HOURS

%Calculate the current-draw-induced voltage drop from nominal battery voltage using V=IR
%Does not account for the fact that the battery decreases voltage as it discharges
robot_state.supply_voltage = robot_config.battery_nominal_voltage - robot_state.current_draw * robot_config.battery_internal_resistance;


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
