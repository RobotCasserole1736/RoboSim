%A test of Octave's ability to animate a rectangle on a figure.

clf;

%Physical size constants
field_width = 50; %ft
field_height = 75; %ft
robot_width = 2; %ft
robot_height = 1; %ft


%Robot coordinates
robot_x_pos = 0; %ft
robot_y_pos = 0; %ft
robot_rotation = 0; %radians wrt. +y axis. 0 radians means robot is pointed straight up. 90 is pointed to the left


%set up figure axis and draw field
axis([-field_width/2 field_width/2 -field_height/2 field_height/2], "equal", "nolabel", "manual", "tic", "on");
rectangle("Position", [-field_width/2 field_height/2 field_width field_height]);


%test loop for drawing
for i = 1:1:300
  robot_rotation = robot_rotation + 2*pi/120;
  robot_x_pos = cos(robot_rotation)*20;
  robot_y_pos = sin(robot_rotation)*20;
  robot_TL_vertex = [robot_x_pos, robot_y_pos] + [-robot_width/2 * cos(robot_rotation) +  -robot_height/2 * sin(robot_rotation),   robot_height/2 * cos(robot_rotation) + -robot_width/2 * sin(robot_rotation)];
  robot_TR_vertex = [robot_x_pos, robot_y_pos] + [ robot_width/2 * cos(robot_rotation) +  -robot_height/2 * sin(robot_rotation),   robot_height/2 * cos(robot_rotation) +  robot_width/2 * sin(robot_rotation)];;
  robot_BR_vertex = [robot_x_pos, robot_y_pos] + [ robot_width/2 * cos(robot_rotation) +   robot_height/2 * sin(robot_rotation),  -robot_height/2 * cos(robot_rotation) +  robot_width/2 * sin(robot_rotation)];;
  robot_BL_vertex = [robot_x_pos, robot_y_pos] + [-robot_width/2 * cos(robot_rotation) +   robot_height/2 * sin(robot_rotation),  -robot_height/2 * cos(robot_rotation) + -robot_width/2 * sin(robot_rotation)];;

  h = patch( [ robot_TL_vertex(1) robot_TR_vertex(1) robot_BR_vertex(1) robot_BL_vertex(1) ],[ robot_TL_vertex(2) robot_TR_vertex(2) robot_BR_vertex(2) robot_BL_vertex(2) ], 'r');
  drawnow("expose");
  usleep(10000)
  delete(h)
end