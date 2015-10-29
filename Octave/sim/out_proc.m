%out_proc.m
% Output Processing
%
% This should run at the end of each simulation loop to read and process output interfaces.
%
% Created August 1, 2015 - Andrew Gurik & Chris Gerth
% 

% required physical outputs:
%   8 digital
%   2 analog
%   4 quadrature
global s1
global use_serial

%% pass outputs
lmv(i) = motor(1).voltage;
lms(i) = motor(1).speed;
lmt(i) = motor(1).torque;
rmv(i) = motor(2).voltage;
rms(i) = motor(2).speed;
rmt(i) = motor(2).torque;

rb_x_vel(i) = robot_state.linear_vel_x;
rb_x_pos(i) = robot_state.pos_x;
rb_y_vel(i) = robot_state.linear_vel_y;
rb_y_pos(i) = robot_state.pos_y;
rb_rot_vel(i) = robot_state.rotational_vel;

t(i) = n;

%% serial write

if (use_serial)
    %TX packet stubbed to zeros for now.
	tx_packet = serial_assemble_packet([0,0,0,0,0,0,0,0], [0,0], [32000, 32000, 32000, 32000], [0,0,0,0]);
	serial_write_packet(s1, tx_packet);
end

%% visual processing
% draw robot

%calculate robot drawing verticies. Must rotate coords. back to what octave expects
robot_TL_vertex = [-robot_state.pos_y, robot_state.pos_x] + [-robot_config.half_width * cos(robot_state.rotation) +  -robot_config.half_length * sin(robot_state.rotation),   robot_config.half_length * cos(robot_state.rotation) + -robot_config.half_width * sin(robot_state.rotation)];
robot_TR_vertex = [-robot_state.pos_y, robot_state.pos_x] + [ robot_config.half_width * cos(robot_state.rotation) +  -robot_config.half_length * sin(robot_state.rotation),   robot_config.half_length * cos(robot_state.rotation) +  robot_config.half_width * sin(robot_state.rotation)];
robot_BR_vertex = [-robot_state.pos_y, robot_state.pos_x] + [ robot_config.half_width * cos(robot_state.rotation) +   robot_config.half_length * sin(robot_state.rotation),  -robot_config.half_length * cos(robot_state.rotation) +  robot_config.half_width * sin(robot_state.rotation)];
robot_BL_vertex = [-robot_state.pos_y, robot_state.pos_x] + [-robot_config.half_width * cos(robot_state.rotation) +   robot_config.half_length * sin(robot_state.rotation),  -robot_config.half_length * cos(robot_state.rotation) + -robot_config.half_width * sin(robot_state.rotation)];
marker_coords = (robot_TL_vertex + robot_TR_vertex) ./ 2;
set(robot_obj_handle, 'XData', [ robot_TL_vertex(1) robot_TR_vertex(1) robot_BR_vertex(1) robot_BL_vertex(1) ]);
set(robot_obj_handle, 'YData', [ robot_TL_vertex(2) robot_TR_vertex(2) robot_BR_vertex(2) robot_BL_vertex(2) ]);
set(robot_front_marker, "Position",[marker_coords(1)-marker_radius/2, marker_coords(2)-marker_radius/2,marker_radius,marker_radius]);
drawnow("expose"); %force update the figure with the new robot state