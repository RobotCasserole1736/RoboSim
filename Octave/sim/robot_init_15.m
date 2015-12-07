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
        'gear_ratio',           [1/8, 1/12],...     % gear ratio of the drivetrain [low, high]
        'encoder_ratio',        [1/8, 1/12],...     % ratio of the gearbox from the motor to the encoder [low, high]
        'wheel_diameter',       6 * 0.0254,...      % drive wheel diameter (meters)
        'drive_motors_per_side', 3,...              % number of motors per side of drivetrain
        'motor_width',          0.3,...             % distance from robot center to left/right drive wheel sets (m)
        %Wheel-floor interactions
        'coef_fric_kin_wheel_floor_net',   200,...  % net kinetic frictional coefficent for side-to-side motion against wheel's rotational axis
        %Robot-wall interactions
        'bumper_p_absorption_factor',      0.5,...  % How much of the momentum is absorbed by the bumpers in a wall-robot impact? (0 = none, 1 = all)
        %Overall physical characteristics
        'weight',               130,...             % robot weight (pounds)
        'half_width',           0.35,...            % distance from robot center to left/right bumpers (m)
        'half_length',          0.44,...            % distance from robot center to front/back bumpers (m)
        %Mechanism config
        'mechanism_motors',     0,...               % total number of mechanism motors
        %Electrical constraints                     
        'battery_capacity',     18,...              %Energy storage of main battery in Amp-Hours
        'battery_nominal_voltage', 12,...           %Battery nominal voltage. Usually 12, but can go lower to simulate dead battery behavior
        'battery_internal_resistance', 0.012,...    %Battery internal resistance. This is what causes battery voltage to drop under load.
        'nominal_current_draw', 0.5,...             %Background average current draw of roboRIO, cooling fans, lights, etc.
		'num_air_tanks', 2,...                      %number of pneumatic tanks available
		'nominal_air_leak_rate', 0.0005,...         %Volumetric leak rate from pneumatic system in L per s. Should be zero, but non-zero if our plumbing is bad.
        'scratch',              0
        );
		
robot_state = ...
struct  (
        %Macro linear motion 
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
        %Macro rotational motion
        'rotational_accel',          0,... % rotational acceleration about the Z axis (radians/s)/s
        'rotational_accel_prev',     0,... % rotation acceleration about the Z axis (radians/s)/s
        'rotational_vel',            0,... % rotation velocity about the Z axis (radians/s)
        'rotational_vel_prev',       0,... % rotation velocity about the Z axis (radians/s)
        'rotation',                  0,... % rotation about the Z axis (radians)
        'rotation_prev',             0,... % rotation about the Z axis (radians)
        %Electrical
        'battery_charge', robot_config.battery_capacity,... % current charge of battery (Amp Hours)
        'supply_voltage', robot_config.battery_nominal_voltage,... %system voltage available to all components (V)
        'current_draw',              0,... % Total current draw from the battery (A)
		'system_air_pressure',       0,... % Air pressure for pneumatic system in kPa
		'compressor_enabled_command', 0,... %set to 1 to turn the compressor on, 0 to turn it off. Overridden if sys press is too high.
		'compressor_enabled',        0,... %1 if compressor is actually running, 0 if off.
        'scratch',                   0
        );
        
%Physical properties of the robot which are derived from other constants
%Reason for this is to do the calcultion once and speed up the runtime loop
robot_calc_config = ...
struct  (
        %Drivetrain config
        'torque_ratio',           robot_config.gear_ratio.^-1,...      % Torque ratio of motor to wheels. 
        'wheel_circumference',    robot_config.wheel_diameter*pi,...   % drive wheel circumference (meters)
        'mass_kg',                0.453592*robot_config.weight,...     % mass of robot in kg. 
        'moment_of_inertia',     (1/12 * 0.453592*robot_config.weight * ((0.9*robot_config.half_length*2)^2 + (robot_config.motor_width*2)^2)),... %Wacked-up model of robot as a rectangular prisim for rotational inerita purposes
        'scratch',              0
        );

% motor workspace
for ii = 1:2+robot_config.mechanism_motors %Left and right drive motors, plus mechanism motors
	motor(ii) = ...
	struct  (
			'speed',        0,...   % motor speed in rad/s
			'torque',       0,...   % motor torque in Nm
			'voltage',      0,...   % motor voltage in Volts
			'current',      0,...   % motor current draw in Amps
			'scratch',      0
			);
end

%%Init pneumatic system internal variables
compressor_and_tank(0,0,robot_config.num_air_tanks,1);
pressure_sensor(0,1);

%% Initialize Robot Drawing
%figure(1);
% draw Robot

%calculate robot drawing verticies
robot_TL_vertex = [robot_state.pos_x, robot_state.pos_y] + [-robot_config.half_width * cos(robot_state.rotation) +  -robot_config.half_length * sin(robot_state.rotation),   robot_config.half_length * cos(robot_state.rotation) + -robot_config.half_width * sin(robot_state.rotation)];
robot_TR_vertex = [robot_state.pos_x, robot_state.pos_y] + [ robot_config.half_width * cos(robot_state.rotation) +  -robot_config.half_length * sin(robot_state.rotation),   robot_config.half_length * cos(robot_state.rotation) +  robot_config.half_width * sin(robot_state.rotation)];
robot_BR_vertex = [robot_state.pos_x, robot_state.pos_y] + [ robot_config.half_width * cos(robot_state.rotation) +   robot_config.half_length * sin(robot_state.rotation),  -robot_config.half_length * cos(robot_state.rotation) +  robot_config.half_width * sin(robot_state.rotation)];
robot_BL_vertex = [robot_state.pos_x, robot_state.pos_y] + [-robot_config.half_width * cos(robot_state.rotation) +   robot_config.half_length * sin(robot_state.rotation),  -robot_config.half_length * cos(robot_state.rotation) + -robot_config.half_width * sin(robot_state.rotation)];
%Calculate a front-of-robot marker location
marker_coords = (robot_TL_vertex + robot_TR_vertex) ./ 2;
marker_radius = 0.3;
%create robot patch drawing object
robot_obj_handle= patch( [ robot_TL_vertex(1) robot_TR_vertex(1) robot_BR_vertex(1) robot_BL_vertex(1) ],[ robot_TL_vertex(2) robot_TR_vertex(2) robot_BR_vertex(2) robot_BL_vertex(2) ], 'r');
%Create marker object
robot_front_marker = rectangle("Position",[marker_coords(1)-marker_radius/2, marker_coords(2)-marker_radius/2,marker_radius,marker_radius], "Curvature", [1 1], "FaceColor",[0 .5 .5], 'LineStyle', 'none');
