%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Copyright (C) 2015 FRC Team 1736 
%%%
%%% File: plant_main.m
%%%
%%% Description: Main entry point for the plant model for RoboSim
%%% 
%%% Inputs: Serial packets from Arduino on RoboSim
%%%         Configuration of plant model.
%%%
%%% Outputs: Serial packets to Arduino
%%%          GUI animation of robot state
%%%          log files  
%%%
%%%  Change Log:
%%%
%%%     7/16/2015 - Chris Gerth
%%%       -Created
%%%        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%declare globals
global motor_voltages
global digital_inputs
global digital_outputs
global analog_outputs
global encoder_outputs

%Arduino->Plant Packet Definition:
% byte (0 rxed first, n rxed last)
% 0 - start of packet marker - always '~'
% 1 - bit-packed digital inputs
% 2 - motor 1 voltage - signed int8, 0.09375 V/bit
% 3 - motor 2 voltage - signed int8, 0.09375 V/bit
% 4 - motor 3 voltage - signed int8, 0.09375 V/bit
% 5 - motor 4 voltage - signed int8, 0.09375 V/bit
% 6 - motor 5 voltage - signed int8, 0.09375 V/bit
% 7 - motor 6 voltage - signed int8, 0.09375 V/bit

%Plant->Arduino Packet Definition:
% byte (0 txed first, n rxed last)
% 0 - start of packet marker - always '~'
% 1 - bit-packed digital outputs
% 2 - analog output 1 - 0.019607 volts/bit (0-5V range)
% 3 - analog output 2 - 0.019607 volts/bit (0-5V range)
% 4 - Quad Encoder 1 output MSB (1ms/bit)
% 5 - Quad Encoder 1 output LSB
% 6 - Quad Encoder 2 output MSB (1ms/bit)
% 7 - Quad Encoder 2 output LSB
% 8 - Quad Encoder 3 output MSB (1ms/bit)
% 9 - Quad Encoder 3 output LSB
% 10 - Quad Encoder 4 output MSB (1ms/bit)
% 11 - Quad Encoder 4 output LSB
%Note - quad encoder outpus are in ms per full period of quadrature output.
%Values are signed, where positive times yeild foreward motion, and negative
%times yeild backward motion. Any specified period longer than 30 seconds
%(ie, value > 30,000 or < -30,000) will mean "Stopped"

%First, enable logging to file (mostly for headless runs)
diary "RoboSim_plant_log.txt"

%Log some things
disp(sprintf('\n\n'));
disp('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~');
disp('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~');
disp(['~~~~~~~~~~RoboSim Plant Log Started ', datestr(now)])
disp('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~');
disp('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~');

disp('Loading packages...');
%Load instrument control package for serial support
pkg load instrument-control

%clear out the existing figure
clf;

disp('Setting up data...');
%Physical size constants
field_width = 50; %ft
field_height = 75; %ft
robot_width = 2; %ft
robot_height = 1; %ft

%Current simulation loop
timestep = 0; 

%Flag to set if loop should continue or not
continue_flag = 1;

%Robot coordinates
robot_x_pos = 0; %ft
robot_y_pos = 0; %ft
robot_rotation = 0; %radians wrt. +y axis. 0 radians means robot is pointed straight up. 90 is pointed to the left


%set up figure axis and draw field
axis([-field_width/2 field_width/2 -field_height/2 field_height/2], "equal", "nolabel", "manual", "tic", "on");
rectangle("Position", [-field_width/2 field_height/2 field_width field_height]);
robot_obj_handle= patch([0,0,0,0],[0,0,0,0],'r'); %initialize robot object handle

%Open serial port for coms with RoboSim
disp('Opening Serial port...');
%TODO

%main loop
disp('Starting main loop. Close window to end');

%When user closes the GUI, an error will be thrown. Catch this error and exit gracefully.
try
    while(continue_flag)

        %gather inputs

        %update state
        robot_rotation = robot_rotation + 2*pi/120;
        robot_x_pos = cos(robot_rotation)*20;
        robot_y_pos = sin(robot_rotation)*20;

        %calculate robot drawing verticies
        robot_TL_vertex = [robot_x_pos, robot_y_pos] + [-robot_width/2 * cos(robot_rotation) +  -robot_height/2 * sin(robot_rotation),   robot_height/2 * cos(robot_rotation) + -robot_width/2 * sin(robot_rotation)];
        robot_TR_vertex = [robot_x_pos, robot_y_pos] + [ robot_width/2 * cos(robot_rotation) +  -robot_height/2 * sin(robot_rotation),   robot_height/2 * cos(robot_rotation) +  robot_width/2 * sin(robot_rotation)];;
        robot_BR_vertex = [robot_x_pos, robot_y_pos] + [ robot_width/2 * cos(robot_rotation) +   robot_height/2 * sin(robot_rotation),  -robot_height/2 * cos(robot_rotation) +  robot_width/2 * sin(robot_rotation)];;
        robot_BL_vertex = [robot_x_pos, robot_y_pos] + [-robot_width/2 * cos(robot_rotation) +   robot_height/2 * sin(robot_rotation),  -robot_height/2 * cos(robot_rotation) + -robot_width/2 * sin(robot_rotation)];;

        %transmit packet


        %Clear the drawing in prep for the next loop
        delete(robot_obj_handle); 
        %draw robot on screen
        robot_obj_handle= patch( [ robot_TL_vertex(1) robot_TR_vertex(1) robot_BR_vertex(1) robot_BL_vertex(1) ],[ robot_TL_vertex(2) robot_TR_vertex(2) robot_BR_vertex(2) robot_BL_vertex(2) ], 'r');
        


        %Drawing utility section - do not edit!
        drawnow("expose"); %force update the figure with the new state 
        usleep(10000); %Pause to make this execute on a 10-ms loop

        %Finally, incriment timestep before next loop
        timestep = timestep + 1;


    end
catch err
    %Close serial port
    disp('Closing Serial port...');
    %TODO

    %exited loop, plant model is done. Goodbye...
    disp('Plant model execution complete!');
end