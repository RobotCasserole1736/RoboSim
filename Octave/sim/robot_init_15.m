% robot_init_15.m
% 2015 Robot Model Init
%
% Created August 1, 2015 - Andrew Gurik & Chris Gerth
% 

% robot config
% this is only set up for tank drive
robot = ...
struct  (
        'gear_ratio',           [1/12, 1/8],...     % gear ratio of the drivetrain [low, high]
        'encoder_ratio',        [1/12, 1/8],...     % ratio of the gearbox from the motor to the encoder [low, high]
        'wheel_diameter',       6 * 0.0254,...      % drive wheel diameter (meters)
        'weight',               10,...             % robot weight (pounds)
        'drive_motors',         3,...               % number of motors per side of drivetrain
        'mechanism_motors',     0,...               % total number of mechanism motors
        'scratch',              0
        );

% motor workspace
for ii = 1:2
    for jj = 1:(robot.drive_motors)
        motor(ii,jj) = ...
        struct  (
                'speed',        0,...   % motor speed in rad/s
                'torque',       0,...   % motor torque in Nm
                'voltage',      0,...   % motor voltage in Volts
                'load_torque',  0,...   % load on motor in Nm
                'speed_prev',   0,...   % 1-loop delayed motor speed in rad/s
                'scratch',      0
                );
    end
end
