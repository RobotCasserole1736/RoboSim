% field_robot_physics.m
% 2015 Field/robot interaction Model
%
% Created July 20, 2015 - Andrew Gurik & Chris Gerth
% 

%Check for collisions with walls:

if(robot_state.pos_x + robot_config.half_length > feild.half_height)
    disp("Colission with X wall occurred! Time:")
    disp(n)
    %adjust velocity, assuming semi-elastic colision with object of infinite mass (eg, big wall)
    robot_state.linear_vel_x_prev = robot_state.linear_vel_x;
    robot_state.linear_vel_x = -robot_state.linear_vel_x*(1-robot_config.bumper_p_absorption_factor);
    %calculate acceleration based off of new delta V
    robot_state.linear_accel_x_prev = robot_state.linear_accel_x;
    robot_state.linear_accel_x = robot_state.linear_vel_x - robot_state.linear_vel_x_prev;
    %Correct position to ensure robot stays inside arena
    robot_state.pos_x_prev = robot_state.pos_x;
    robot_state.pos_x = feild.half_height - robot_config.half_length;
    %Update motor speeds
    motor(1).speed = robot_state.linear_vel_x *...         % linear speed (m/s)
                    (1/robot_config.wheel_diameter*pi)*... % 1/wheel circumfrence (rev/m)
					(2*pi);                                % (rad/rev)
    motor(2).speed = robot_state.linear_vel_x *...         % linear speed (m/s)
                    (1/robot_config.wheel_diameter*pi)*... % 1/wheel circumfrence (rev/m)
					(2*pi);                                % (rad/rev)
elseif(robot_state.pos_x - robot_config.half_length < -feild.half_height)
    disp("Colission with X wall occurred! Time:")
    disp(n)
    %adjust velocity, assuming elastic colision with object of infinite mass (eg, big wall)
    robot_state.linear_vel_x_prev = robot_state.linear_vel_x;
    robot_state.linear_vel_x = -robot_state.linear_vel_x*(1-robot_config.bumper_p_absorption_factor);
    %calculate acceleration based off of new delta V
    robot_state.linear_accel_x_prev = robot_state.linear_accel_x;
    robot_state.linear_accel_x = robot_state.linear_vel_x - robot_state.linear_vel_x_prev;
    %Correct position to ensure robot stays inside arena
    robot_state.pos_x_prev = robot_state.pos_x;
    robot_state.pos_x = -feild.half_height + robot_config.half_length;
    %Update motor speeds
    motor(1).speed = robot_state.linear_vel_x *...         % linear speed (m/s)
                    (1/robot_config.wheel_diameter*pi)*... % 1/wheel circumfrence (rev/m)
					(2*pi);                                % (rad/rev)
    motor(2).speed = robot_state.linear_vel_x *...         % linear speed (m/s)
                    (1/robot_config.wheel_diameter*pi)*... % 1/wheel circumfrence (rev/m)
					(2*pi);                                % (rad/rev)
end


if(robot_state.pos_y + robot_config.half_width > feild.half_width)
    disp("Colission with Y wall occurred! Time:")
    disp(n)
    %adjust velocity, assuming elastic colision with object of infinite mass (eg, big wall)
    robot_state.linear_vel_y_prev = robot_state.linear_vel_y;
    robot_state.linear_vel_y = -robot_state.linear_vel_y*(1-robot_config.bumper_p_absorption_factor);
    %calculate acceleration based off of new delta V
    robot_state.linear_accel_y_prev = robot_state.linear_accel_y;
    robot_state.linear_accel_y = robot_state.linear_vel_y - robot_state.linear_vel_y_prev;
    %Correct position to ensure robot stays inside arena
    robot_state.pos_y_prev = robot_state.pos_y;
    robot_state.pos_y = feild.half_width - robot_config.half_length;
    %Update motor speeds
    motor(1).speed = robot_state.linear_vel_x *...         % linear speed (m/s)
                    (1/robot_config.wheel_diameter*pi)*... % 1/wheel circumfrence (rev/m)
					(2*pi);                                % (rad/rev)
    motor(2).speed = robot_state.linear_vel_x *...         % linear speed (m/s)
                    (1/robot_config.wheel_diameter*pi)*... % 1/wheel circumfrence (rev/m)
					(2*pi);                                % (rad/rev)
elseif(robot_state.pos_y - robot_config.half_width < -feild.half_width)
    disp("Colission with Y wall occurred! Time:")
    disp(n)
    %adjust velocity, assuming elastic colision with object of infinite mass (eg, big wall)
    robot_state.linear_vel_y_prev = robot_state.linear_vel_y;
    robot_state.linear_vel_y = -robot_state.linear_vel_y*(1-robot_config.bumper_p_absorption_factor);
    %calculate acceleration based off of new delta V
    robot_state.linear_accel_y_prev = robot_state.linear_accel_y;
    robot_state.linear_accel_y = robot_state.linear_vel_y - robot_state.linear_vel_y_prev;
    %Correct position to ensure robot stays inside arena
    robot_state.pos_y_prev = robot_state.pos_y;
    robot_state.pos_y = -feild.half_width + robot_config.half_length;
    %Update motor speeds
    motor(1).speed = robot_state.linear_vel_x *...         % linear speed (m/s)
                    (1/robot_config.wheel_diameter*pi)*... % 1/wheel circumfrence (rev/m)
					(2*pi);                                % (rad/rev)
    motor(2).speed = robot_state.linear_vel_x *...         % linear speed (m/s)
                    (1/robot_config.wheel_diameter*pi)*... % 1/wheel circumfrence (rev/m)
					(2*pi);                                % (rad/rev)
end




