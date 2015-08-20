% robot_15.m
% 2015 Robot Model
%
% This is the physical model of the robot.
%
% Created July 20, 2015 - Andrew Gurik & Chris Gerth
% 

% mass (kg)
mass_kg = 0.453592*robot.weight; % pounds to kilograms

%% Drivetrain

%% Get Motor Voltage
for ii = 1:robot.drive_motors
    % Left
    motor(1,ii).voltage = in.motor_voltage(ii);
    % Right
    motor(2,ii).voltage = in.motor_voltage(ii + robot.drive_motors);
end

%% Physics Model
%physics model should determine load somehow

% robot inertia
% F = ma
for ii = 1:robot.drive_motors
    % Left (Nm)
    inertia =   (mass_kg) *...                                          % mass (kg)
                (motor(1,ii).speed - motor(1,ii).speed_prev)/Ts *...    % acceleration  (rad/s/s)
                (1/2/pi) * ...                                          %               (rev/rad)
                (robot.wheel_diameter*pi) * ...                         %               (m/rev)
                (robot.gear_ratio(1));                                  % gear ratio - NEED TO FIGURE THIS OUT FOR gear_ratio AND encoder_ratio
            
    motor(1,ii).load_torque =   (inertia / 2 / robot.drive_motors) *... % inertial force (N)
                                (robot.wheel_diameter/2) *...           % wheel radius - lever arm (m)
                                (robot.gear_ratio(1));                  % gear ratio
                                
    % Right (Nm)
    inertia =   (mass_kg) *...                                          % mass (kg)
                (motor(2,ii).speed - motor(2,ii).speed_prev)/Ts *...    % acceleration  (rad/s/s)
                (1/2/pi) * ...                                          %               (rev/rad)
                (robot.wheel_diameter*pi) * ...                         %               (m/rev)
                (robot.gear_ratio(1));                                  % gear ratio - NEED TO FIGURE THIS OUT FOR gear_ratio AND encoder_ratio
            
    motor(2,ii).load_torque =   (inertia / 2 / robot.drive_motors) *... % inertial force (N)
                                (robot.wheel_diameter/2) *...           % wheel radius - lever arm (m)
                                (robot.gear_ratio(1));                  % gear ratio
end

%% load torque overrides
%left_motor.load_torque = .1; % left_load;
%right_motor.load_torque = 0; %right_load;


% repopulate speed_prev
for ii = 1:robot.drive_motors
    % Left
    motor(1,ii).speed_prev = motor(1,ii).speed;
    % Right
    motor(2,ii).speed_prev = motor(2,ii).speed;
end

% calculate new speed and torque
for ii = 1:robot.drive_motors
    % Left
    [motor(1,ii).speed, motor(1,ii).torque] = motor_CIM(motor(1,ii).voltage,...
                                                        motor(1,ii).load_torque,...
                                                        motor(1,ii).torque,...
                                                        motor(1,ii).speed_prev);
    % Right
    [motor(2,ii).speed, motor(2,ii).torque] = motor_CIM(motor(2,ii).voltage,...
                                                        motor(2,ii).load_torque,...
                                                        motor(2,ii).torque,...
                                                        motor(2,ii).speed_prev);
end
