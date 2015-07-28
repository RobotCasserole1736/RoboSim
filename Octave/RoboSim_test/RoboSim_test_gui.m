%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Copyright (C) 2015 FRC Team 1736 
%%%
%%% File: RoboSim_test_gui.m
%%%
%%% Description: Simple GUI to send/recieve RoboSim serial packet data
%%%              Useful for debugging and basic setup
%%% 
%%% Inputs: Serial packets from Arduino on RoboSim
%%%         GUI user inputs
%%%
%%% Outputs: Serial packets to Arduino
%%%          GUI Display
%%%          log files  
%%%
%%%  Change Log:
%%%
%%%     7/25/2015 - Chris Gerth
%%%       -Created
%%%        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Octave environment setup
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%import serial modules
pkg load instrument-control
%Add path to folder for custom serial functions
addpath('..\SerialUtils\'); 
%Enable logging to file (mostly for headless runs)
diary "RoboSim_plant_log.txt"

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Global Variable Declarations
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%global vars for handles
global a1_sld
global a2_sld
global btn_DO0
global btn_DO1
global btn_DO2
global btn_DO3
global btn_DO4
global btn_DO5
global btn_DO6
global btn_DO7
global enc1_sld
global enc2_sld
global enc3_sld
global enc4_sld
global btn_enc1_dir
global btn_enc2_dir
global btn_enc3_dir
global btn_enc4_dir

%global vars for output states
global digital_outputs 
global analog_outputs %voltage, 0-5 V

%global vars for input states
global digital_inputs 

%global vars for encoder periods and dirs
global encoder_periods %ms
global encoder_dir_fwd %1 - fwd, 0 - rev

%global vars for motor voltages
global motor_voltages %voltage, -12 to 12 V

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Define Constants
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
loop_rate_sec = 0.1; %100ms loop period


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Main Script Initialization
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Log some things
disp(sprintf('\n\n'));
disp('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~');
disp('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~');
disp(['~~~~~~~~~~RoboSim Test GUI Log Started ', datestr(now)])
disp('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~');
disp('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~');

%Open serial port. Try a couple different ports...
s1 = serial_open_port("COM4",0.1);                    



%Initialize variables
digital_outputs = [0,0,0,0,0,0,0,0];
analog_outputs = [0, 0];     
motor_voltages = [0,0,0,0,0,0];                                
rx_packet = ['~',0x00,0x00,0x00,0x00,0x00,0x00,0x00];
tx_packet = [0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00];
encoder_periods = [32000, 32000, 32000, 32000];
encoder_dir_fwd = [0, 0, 0, 0];
loop_counter = 0;
loop_start_time = 0;
loop_end_time = 0;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% GUI Construction
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Create figure to hold GUI silently till we have added all the controls
f = figure('Visible', 'off');

% Create sliders for analog outputs
a1_sld = uicontrol('Style', 'slider','Min',0,'Max',5,'Value',0,'Position', [10 20 120 20],'Callback', @gui_callbacks); 
txt_a1 = uicontrol('Style','text','Position',[10 45 120 20],'String', 'A1 Output (V)');
a2_sld = uicontrol('Style', 'slider','Min',0,'Max',5,'Value',0,'Position', [210 20 120 20],'Callback', @gui_callbacks);   
txt_a2 = uicontrol('Style','text','Position',[210 45 120 20],'String', 'A2 Output (V)');      

% Create push buttons for digital outputs
btn_DO0 = uicontrol('Style', 'pushbutton', 'String', 'DO0','Position', [10  75 40 20],'Callback', @gui_callbacks,'Backgroundcolor','r');       
btn_DO1 = uicontrol('Style', 'pushbutton', 'String', 'DO1','Position', [60  75 40 20],'Callback', @gui_callbacks,'Backgroundcolor','r');  
btn_DO2 = uicontrol('Style', 'pushbutton', 'String', 'DO2','Position', [110 75 40 20],'Callback', @gui_callbacks,'Backgroundcolor','r');  
btn_DO3 = uicontrol('Style', 'pushbutton', 'String', 'DO3','Position', [160 75 40 20],'Callback', @gui_callbacks,'Backgroundcolor','r');  
btn_DO4 = uicontrol('Style', 'pushbutton', 'String', 'DO4','Position', [210 75 40 20],'Callback', @gui_callbacks,'Backgroundcolor','r');  
btn_DO5 = uicontrol('Style', 'pushbutton', 'String', 'DO5','Position', [260 75 40 20],'Callback', @gui_callbacks,'Backgroundcolor','r');  
btn_DO6 = uicontrol('Style', 'pushbutton', 'String', 'DO6','Position', [310 75 40 20],'Callback', @gui_callbacks,'Backgroundcolor','r');  
btn_DO7 = uicontrol('Style', 'pushbutton', 'String', 'DO7','Position', [360 75 40 20],'Callback', @gui_callbacks,'Backgroundcolor','r'); 
txt_DO = uicontrol('Style','text','Position',[130 100 140 20],'String', 'Digital Out (T/F)');    

% Create sliders for quad encoder outputs
enc3_sld = uicontrol('Style', 'slider','Min',1,'Max',32000,'Value',32000,'Position', [10 125 120 20],'Callback', @gui_callbacks); 
btn_enc3_dir = uicontrol('Style', 'pushbutton', 'String', 'Rev','Position', [135  125 40 20],'Callback', @gui_callbacks);  
txt_enc3 = uicontrol('Style','text','Position',[10 150 150 20],'String', 'Enc3 Period (ms)');
enc4_sld = uicontrol('Style', 'slider','Min',1,'Max',32000,'Value',32000,'Position', [210 125 120 20],'Callback', @gui_callbacks);   
btn_enc4_dir  = uicontrol('Style', 'pushbutton', 'String', 'Rev','Position', [335 125 40 20],'Callback', @gui_callbacks);  
txt_enc4 = uicontrol('Style','text','Position',[210 150 150 20],'String', 'Enc4 Period (ms)');   

enc1_sld = uicontrol('Style', 'slider','Min',1,'Max',32000,'Value',32000,'Position', [10 175 120 20],'Callback', @gui_callbacks); 
btn_enc1_dir = uicontrol('Style', 'pushbutton', 'String', 'Rev','Position', [135  175 40 20],'Callback', @gui_callbacks);  
txt_enc1 = uicontrol('Style','text','Position',[10 200 150 20],'String', 'Enc1 Period (ms)');
enc2_sld = uicontrol('Style', 'slider','Min',1,'Max',32000,'Value',32000,'Position', [210 175 120 20],'Callback', @gui_callbacks);   
btn_enc2_dir  = uicontrol('Style', 'pushbutton', 'String', 'Rev','Position', [335 175 40 20],'Callback', @gui_callbacks);  
txt_enc2 = uicontrol('Style','text','Position',[210 200 150 20],'String', 'Enc2 Period (ms)');  

%make the GUI visible! Woo! Seeing things is awesome! 
set(f, 'Visible', 'on');
%User can now click buttons, which trigger callbacks to be run asynchronously

%start timer for maintaining periodic loop rate
tic();

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% GUI Mainloop
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Main execution loop. persist while figure is not closed
while(isfigure(f))

    %mark loop start time
    loop_start_time = toc();

    %read packet from RoboSim
	  [rx_packet, read_ret_status] = serial_read_packet(s1,1);
    [digital_inputs, motor_voltages] = serial_decode_packet(rx_packet);
	
    disp(sprintf("\n~~~~~~~~~~~~~~~~~~%d\n",loop_counter));
    
    disp("~~~~~RX_DEBUG~~~~~")
    disp(sprintf("Debug: RX Packet = 0x%X 0x%X 0x%X 0x%X 0x%X 0x%X 0x%X 0x%X ", rx_packet(1),rx_packet(2),rx_packet(3),rx_packet(4),rx_packet(5),rx_packet(6),rx_packet(7),rx_packet(8)));
    disp("Debug: Digital Inputs = ")
    disp(digital_inputs)
    disp("Debug: Motor Voltages (V) = ")
    disp(motor_voltages)
    
	%assemble TX packet
	tx_packet = serial_assemble_packet(digital_outputs, analog_outputs, encoder_periods, encoder_dir_fwd);
	serial_write_packet(s1, tx_packet);
    
    disp("~~~~~TX_DEBUG~~~~~")
    disp("Debug: Digital Outputs = ")
    disp(digital_outputs)
    disp("Debug: Analog Outputs (V) = ")
    disp(analog_outputs)
    disp("Debug: Encoder Periods (ms) = ")
    disp(encoder_periods)
    disp("Debug: Encoder Dirs (1=rev, 0=fwd) = ")
    disp(encoder_dir_fwd)
    disp(sprintf("Debug: TX Packet = 0x%X 0x%X 0x%X 0x%X 0x%X 0x%X 0x%X 0x%X 0x%X 0x%X 0x%X 0x%X ", tx_packet(1),tx_packet(2),tx_packet(3),tx_packet(4),tx_packet(5),tx_packet(6),tx_packet(7),tx_packet(8),tx_packet(9),tx_packet(10),tx_packet(11),tx_packet(12)));
    fflush(stdout);
   
    
    if(loop_start_time + loop_rate_sec > toc())
        disp(sprintf('pause for %d s', (loop_start_time + loop_rate_sec) - toc()));
	    pause((loop_start_time + loop_rate_sec) - toc()); %Crucial pause - times the main loop, and gives the GUI a chance to register mouse clicks and update gui and stuff
    else
        warning("loop timing missed! Behind sample rate by %d s", toc() -(loop_start_time + loop_rate_sec) );
	    pause(0); %we still need to pause for a bit otherwise the GUI won't update.
    end
        
    loop_counter = loop_counter + 1;
end

%Once we hit here, it means the user has closed the figure window. Cleanup time!

                
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% GUI Cleanup
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

serial_close_port(s1);  
