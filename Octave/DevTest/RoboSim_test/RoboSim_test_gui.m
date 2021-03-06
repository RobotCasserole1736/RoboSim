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
loop_rate_sec = 0.01; %80ms min loop period


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

%Look for RoboSim on the serial ports
ser_port_name = serial_detect_port();
if(ischar(ser_port_name) || ser_port_name ~= -1)
	%Open serial port.
	s1 = serial_open_port(ser_port_name,0.1);
else
	disp("Cannot find robosim! Serial coms will not take place!");
	s1 = -1;
end



%Initialize variables
digital_outputs = [0,0,0,0,0,0,0,0];
analog_outputs = [0, 0];     
motor_voltages = [0,0,0,0,0,0];                                
rx_packet = ['~',0x00,0x00,0x00,0x00,0x00,0x00,0x00];
old_rx_packet = ['~',0x00,0x00,0x00,0x00,0x00,0x00,0x00];
tx_packet = [0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00];
encoder_periods = [32000, 32000, 32000, 32000];
encoder_dir_fwd = [0, 0, 0, 0];
loop_counter = 0;
loop_start_time = 0;
loop_end_time = 0;
bad_reads_cnt = 0;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% GUI Construction
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Create figure to hold GUI silently till we have added all the controls
f = figure('Visible', 'off', 'Position', [100 100 400 500], 'name', 'RoboSim Test Gui', 'numberTitle', 'off');

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
enc3_sld = uicontrol('Style', 'slider','Min',0,'Max',500,'Value',0,'Position', [10 125 120 20],'Callback', @gui_callbacks); 
btn_enc3_dir = uicontrol('Style', 'pushbutton', 'String', 'Rev','Position', [135  125 40 20],'Callback', @gui_callbacks);  
txt_enc3 = uicontrol('Style','text','Position',[10 150 150 20],'String', 'Enc3 Freq (Hz)');
enc4_sld = uicontrol('Style', 'slider','Min',0,'Max',500,'Value',0,'Position', [210 125 120 20],'Callback', @gui_callbacks);   
btn_enc4_dir  = uicontrol('Style', 'pushbutton', 'String', 'Rev','Position', [335 125 40 20],'Callback', @gui_callbacks);  
txt_enc4 = uicontrol('Style','text','Position',[210 150 150 20],'String', 'Enc4 Freq (Hz)');   

enc1_sld = uicontrol('Style', 'slider','Min',0,'Max',500,'Value',0,'Position', [10 175 120 20],'Callback', @gui_callbacks); 
btn_enc1_dir = uicontrol('Style', 'pushbutton', 'String', 'Rev','Position', [135  175 40 20],'Callback', @gui_callbacks);  
txt_enc1 = uicontrol('Style','text','Position',[10 200 150 20],'String', 'Enc1 Freq (Hz)');
enc2_sld = uicontrol('Style', 'slider','Min',0,'Max',500,'Value',0,'Position', [210 175 120 20],'Callback', @gui_callbacks);   
btn_enc2_dir  = uicontrol('Style', 'pushbutton', 'String', 'Rev','Position', [335 175 40 20],'Callback', @gui_callbacks);  
txt_enc2 = uicontrol('Style','text','Position',[210 200 150 20],'String', 'Enc2 Freq (Hz)');  

%Outputs Label
outputs_label = uicontrol('Style','text','Position',[10 225 380 20],'String', '==============OUTPUTS==============','Backgroundcolor','c');    

%Create text outputs for voltages
voltage_disp_label = uicontrol('Style','text','Position',[120 375 120 20],'String', 'Voltage Inputs');    
voltage_disp1 = uicontrol('Style','text','Position',[10 350 120 20],'String', 'M1 : +00.000V');
voltage_disp2 = uicontrol('Style','text','Position',[210 350 120 20],'String', 'M2 : +00.000V');
voltage_disp3 = uicontrol('Style','text','Position',[10 325 120 20],'String', 'M3 : +00.000V');
voltage_disp4 = uicontrol('Style','text','Position',[210 325 120 20],'String', 'M4 : +00.000V');
voltage_disp5 = uicontrol('Style','text','Position',[10 300 120 20],'String', 'M5 : +00.000V');
voltage_disp6 = uicontrol('Style','text','Position',[210 300 120 20],'String', 'M6 : +00.000V');

%Create indicators for digital inputs
dig_inputs_label = uicontrol('Style', 'text', 'Position', [120 450 120 20],'String', 'Digital Inputs');
dig_input_1 = uicontrol('Style', 'text', 'Position', [10 425 20 20],'Backgroundcolor','r','String', '0');
dig_input_2 = uicontrol('Style', 'text', 'Position', [40 425 20 20],'Backgroundcolor','r','String', '1');
dig_input_3 = uicontrol('Style', 'text', 'Position', [70 425 20 20],'Backgroundcolor','r','String', '2');
dig_input_4 = uicontrol('Style', 'text', 'Position', [100 425 20 20],'Backgroundcolor','r','String', '3');
dig_input_5 = uicontrol('Style', 'text', 'Position', [130 425 20 20],'Backgroundcolor','r','String', '4');
dig_input_6 = uicontrol('Style', 'text', 'Position', [160 425 20 20],'Backgroundcolor','r','String', '5');
dig_input_7 = uicontrol('Style', 'text', 'Position', [190 425 20 20],'Backgroundcolor','r','String', '6');
dig_input_8 = uicontrol('Style', 'text', 'Position', [220 425 20 20],'Backgroundcolor','r','String', '7');

%Inputs Label
inputs_label = uicontrol('Style','text','Position',[10 475 380 20],'String', '==============INPUTS==============','Backgroundcolor','c');   

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
    disp(bad_reads_cnt);
    %read packet from RoboSim
    old_rx_packet = rx_packet;
	[rx_packet, read_ret_status] = serial_read_packet(s1,10);
    if(read_ret_status !=0 )
        bad_reads_cnt = bad_reads_cnt + 1;
        rx_packet = old_rx_packet;
    end
        
    [digital_inputs, motor_voltages] = serial_decode_packet(rx_packet);
	
    disp(sprintf("~~~~~~~~~~~~~~~~~~%d\n",loop_counter));
    
    disp(sprintf("Debug: RX Packet = 0x%X 0x%X 0x%X 0x%X 0x%X 0x%X 0x%X 0x%X ", rx_packet(1),rx_packet(2),rx_packet(3),rx_packet(4),rx_packet(5),rx_packet(6),rx_packet(7),rx_packet(8)));
	%assemble TX packet
	tx_packet = serial_assemble_packet(digital_outputs, analog_outputs, encoder_periods, encoder_dir_fwd);
	serial_write_packet(s1, tx_packet);
    
    disp(sprintf("Debug: TX Packet = 0x%X 0x%X 0x%X 0x%X 0x%X 0x%X 0x%X 0x%X 0x%X 0x%X 0x%X 0x%X ", tx_packet(1),tx_packet(2),tx_packet(3),tx_packet(4),tx_packet(5),tx_packet(6),tx_packet(7),tx_packet(8),tx_packet(9),tx_packet(10),tx_packet(11),tx_packet(12)));
    fflush(stdout);
    
    
    %update gui with rxed packet data
    %voltages
    set(voltage_disp1, 'String', sprintf('M1 : %+7.3fV', motor_voltages(1)))
    set(voltage_disp2, 'String', sprintf('M2 : %+7.3fV', motor_voltages(2)))
    set(voltage_disp3, 'String', sprintf('M3 : %+7.3fV', motor_voltages(3)))
    set(voltage_disp4, 'String', sprintf('M4 : %+7.3fV', motor_voltages(4)))
    set(voltage_disp5, 'String', sprintf('M5 : %+7.3fV', motor_voltages(5)))
    set(voltage_disp6, 'String', sprintf('M6 : %+7.3fV', motor_voltages(6)))
    %digital
    if(digital_inputs(1))
        set(dig_input_1,'Backgroundcolor','g')
    else
        set(dig_input_1,'Backgroundcolor','r')
    end
    
    if(digital_inputs(2))
        set(dig_input_2,'Backgroundcolor','g')
    else              
        set(dig_input_2,'Backgroundcolor','r')
    end
    
    if(digital_inputs(3))
        set(dig_input_3,'Backgroundcolor','g')
    else              
        set(dig_input_3,'Backgroundcolor','r')
    end
    
    if(digital_inputs(4))
        set(dig_input_4,'Backgroundcolor','g')
    else              
        set(dig_input_4,'Backgroundcolor','r')
    end
    
    if(digital_inputs(5))
        set(dig_input_5,'Backgroundcolor','g')
    else              
        set(dig_input_5,'Backgroundcolor','r')
    end
    
    if(digital_inputs(6))
        set(dig_input_6,'Backgroundcolor','g')
    else              
        set(dig_input_6,'Backgroundcolor','r')
    end
    
    if(digital_inputs(7))
        set(dig_input_7,'Backgroundcolor','g')
    else              
        set(dig_input_7,'Backgroundcolor','r')
    end
    
    if(digital_inputs(8))
        set(dig_input_8,'Backgroundcolor','g')
    else              
        set(dig_input_8,'Backgroundcolor','r')
    end
    
   
    
    if(loop_start_time + loop_rate_sec > toc())
        %disp(sprintf('pause for %d s', (loop_start_time + loop_rate_sec) - toc()));
	    pause((loop_start_time + loop_rate_sec) - toc()); %Crucial pause - times the main loop, and gives the GUI a chance to register mouse clicks and update gui and stuff
    else
        %warning("loop timing missed! Behind sample rate by %d s", toc() -(loop_start_time + loop_rate_sec) );
	    pause(0); %we still need to pause for a bit otherwise the GUI won't update.
    end
        
    loop_counter = loop_counter + 1;
end

%Once we hit here, it means the user has closed the figure window. Cleanup time!

                
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% GUI Cleanup
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Write one final packet to put RoboSim into a zero-output state
disp("shutting down RoboSim...")

disp("Closing serial port and exiting...")
serial_close_port(s1);  
