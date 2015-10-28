% robot_init_15.m
% 2015 Robot Model Init
%
% Created August 1, 2015 - Andrew Gurik & Chris Gerth
% 

% robot config
% this is only set up for tank drive
robot_config = ...
struct  (
        'gear_ratio',           [1/12, 1/8],...     % gear ratio of the drivetrain [low, high]
        'encoder_ratio',        [1/12, 1/8],...     % ratio of the gearbox from the motor to the encoder [low, high]
        'wheel_diameter',       6 * 0.0254,...      % drive wheel diameter (meters)
        'weight',               150,...             % robot weight (pounds)
        'drive_motors_per_side', 2,...              % number of motors per side of drivetrain
        'mechanism_motors',     0,...               % total number of mechanism motors
        'scratch',              0
        );
		
robot_state = ...
struct  (
        'linear_accel_x',            0,... % acceleration of the robot in the x direction (m/s)
		'linear_accel_y',            0,... % acceleration of the robot in the y direction (m/s)
        'linear_accel_x_prev',       0,... % acceleration of the robot in the x direction (m/s) from the previous loop
		'linear_accel_y_prev',       0,... % acceleration of the robot in the y direction (m/s) from the previous loop
        'linear_vel_x',              0,... % velocity of the robot in the x direction (m/s)
		'linear_vel_y',              0,... % velocity of the robot in the y direction (m/s)
        'linear_vel_x_prev',         0,... % velocity of the robot in the x direction (m/s) from the previous loop
		'linear_vel_y_prev',         0,... % velocity of the robot in the y direction (m/s) from the previous loop
		'pos_x',                     0,... % position of the robot in x (m)
		'pos_y',                     0,... % position of the robot in y (m)
        'pos_x_prev',                0,... % position of the robot in x (m) from the previous loop
		'pos_y_prev',                0,... % position of the robot in y (m) from the previous loop
        'scratch',                   0
        );

% motor workspace
for ii = 1:2 %Left and right drive motors
	motor(ii) = ...
	struct  (
			'speed',        0,...   % motor speed in rad/s
			'torque',       0,...   % motor torque in Nm
			'voltage',      0,...   % motor voltage in Volts
			'load_torque',  0,...   % load on motor in Nm
			'speed_prev',   0,...   % 1-loop delayed motor speed in rad/s
			'scratch',      0
			);
end

