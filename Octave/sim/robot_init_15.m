% robot_init_15.m
% 2015 Robot Model Init
%
% Created August 1, 2015 - Andrew Gurik & Chris Gerth
% 

% robot config
% this is only set up for tank drive
%
% Basic robot model:
%
%             FRONT
%         |-------------|  <
%         |             |   |
%         |             |   | half height     
%         |  ^       ^  |   |      
%         |  |   O   |  |  <      
%         | LDM     RDM |         
%         |             |  
%         |             |  
%         |-------------| 
%
%                 ^--^
%                 motor width
% 
%                 ^-----^
%                 half width
%             
%                 ^ +X direction
%                 |
%              <--+
%              +Y Direction
%             
%             
%         
robot_config = ...
struct  (
        %Drivetrain config
        'gear_ratio',           [1/12, 1/8],...     % gear ratio of the drivetrain [low, high]
        'encoder_ratio',        [1/12, 1/8],...     % ratio of the gearbox from the motor to the encoder [low, high]
        'wheel_diameter',       6 * 0.0254,...      % drive wheel diameter (meters)
        'drive_motors_per_side', 2,...              % number of motors per side of drivetrain
        'motor_width',          0.45,...            % distance from robot center to left/right drive wheel sets (m)
        %Overall physical characteristics
        'weight',               150,...             % robot weight (pounds)
        'half_width',           0.5,...             % distance from robot center to left/right bumpers (m)
        'half_height',          0.75,...            % distance from robot center to front/back bumpers (m)
        %Mechanism config
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
		'pos_x',                     0,... % position of the robot center point in x (m)
		'pos_y',                     0,... % position of the robot center point in y (m)
        'pos_x_prev',                0,... % position of the robot center point in x (m) from the previous loop
		'pos_y_prev',                0,... % position of the robot center point in y (m) from the previous loop
        'rotation',                  pi/4,... % rotation about the Z axis in radians
        'rotation_prev',             pi/4,... % rotation about the Z axis in radians
        'scratch',                   0
        );

% motor workspace
for ii = 1:2+robot_config.mechanism_motors %Left and right drive motors, plus mechanism motors
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

%% Initialize Robot Drawing
figure(1);
% draw Robot
%calculate robot drawing verticies
robot_TL_vertex = [robot_state.pos_x, robot_state.pos_y] + [-robot_config.half_width * cos(robot_state.rotation) +  -robot_config.half_height * sin(robot_state.rotation),   robot_config.half_height * cos(robot_state.rotation) + -robot_config.half_width * sin(robot_state.rotation)];
robot_TR_vertex = [robot_state.pos_x, robot_state.pos_y] + [ robot_config.half_width * cos(robot_state.rotation) +  -robot_config.half_height * sin(robot_state.rotation),   robot_config.half_height * cos(robot_state.rotation) +  robot_config.half_width * sin(robot_state.rotation)];
robot_BR_vertex = [robot_state.pos_x, robot_state.pos_y] + [ robot_config.half_width * cos(robot_state.rotation) +   robot_config.half_height * sin(robot_state.rotation),  -robot_config.half_height * cos(robot_state.rotation) +  robot_config.half_width * sin(robot_state.rotation)];
robot_BL_vertex = [robot_state.pos_x, robot_state.pos_y] + [-robot_config.half_width * cos(robot_state.rotation) +   robot_config.half_height * sin(robot_state.rotation),  -robot_config.half_height * cos(robot_state.rotation) + -robot_config.half_width * sin(robot_state.rotation)];
%Calculate a front-of-robot marker location
marker_coords = (robot_TL_vertex + robot_TR_vertex) ./ 2;
marker_radius = 0.5;
%create robot patch drawing object
robot_obj_handle= patch( [ robot_TL_vertex(1) robot_TR_vertex(1) robot_BR_vertex(1) robot_BL_vertex(1) ],[ robot_TL_vertex(2) robot_TR_vertex(2) robot_BR_vertex(2) robot_BL_vertex(2) ], 'r');
%Create marker object
robot_front_marker = rectangle("Position",[marker_coords(1)-marker_radius/2, marker_coords(2)-marker_radius/2,marker_radius,marker_radius], "Curvature", [1 1], "FaceColor",[0 .5 .5]);
