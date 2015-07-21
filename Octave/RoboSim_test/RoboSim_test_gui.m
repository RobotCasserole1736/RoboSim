pkg load instrument-control
%First, enable logging to file (mostly for headless runs)
diary "RoboSim_plant_log.txt"

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

%global vars for output states
global digital_outputs
global analog_outputs

%global vars for input states
global digital_inputs

%Log some things
disp(sprintf('\n\n'));
disp('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~');
disp('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~');
disp(['~~~~~~~~~~RoboSim Test GUI Log Started ', datestr(now)])
disp('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~');
disp('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~');


try
  % Opens serial port ttyUSB1 with baudrate of 115200 (config defaults to 8-N-1)
  s1 = serial("COM4", 115200); 
  set(s1, "parity", "N");    % Changes parity checking 
                            % possible values [E]ven, [O]dd, [N]one.
  set(s1, "stopbits", 1);    % Changes stop bits, possible
                            % values 1, 2.
  % Flush input and output buffers
  srl_flush(s1); 
catch err
  disp("Warning: issue while opening serial port");
  disp(lasterr);
end                            


%init some values
digital_outputs = [0,0,0,0,0,0,0,0];
analog_outputs = 0;                                     


tx_packet = ['~',0x00,0x00,0x00,0x00,0x00,0x00,0x00];

%Create figure silently till we have addded all the controls
f = figure('Visible', 'on');

% Create for analog outputs
a1_sld = uicontrol('Style', 'slider',...
        'Min',0,'Max',5,'Value',0,...
        'Position', [10 20 120 20],...
        'Callback', @gui_callbacks); 
% Add a text uicontrol to label the slider.
txt_a1 = uicontrol('Style','text',...
        'Position',[10 45 120 20],...
        'String', 'A1 Output (V)');
a2_sld = uicontrol('Style', 'slider',...
        'Min',0,'Max',5,'Value',0,...
        'Position', [210 20 120 20],...
        'Callback', @gui_callbacks);   
% Add a text uicontrol to label the slider.
txt_a2 = uicontrol('Style','text',...
        'Position',[210 45 120 20],...
        'String', 'A2 Output (V)');      

% Create push buttons for digital outputs
btn_DO0 = uicontrol('Style', 'pushbutton', 'String', 'DO0',...
    'Position', [10 60 20 20],...
    'Callback', @gui_callbacks);       
btn_DO1 = uicontrol('Style', 'pushbutton', 'String', 'DO1',...
    'Position', [40 60 20 20],...
    'Callback', @gui_callbacks);  
btn_DO2 = uicontrol('Style', 'pushbutton', 'String', 'DO2',...
    'Position', [70 60 20 20],...
    'Callback', @gui_callbacks);  
btn_DO3 = uicontrol('Style', 'pushbutton', 'String', 'DO3',...
    'Position', [100 60 20 20],...
    'Callback', @gui_callbacks);  
btn_DO4 = uicontrol('Style', 'pushbutton', 'String', 'DO4',...
    'Position', [130 60 20 20],...
    'Callback', @gui_callbacks);  
btn_DO5 = uicontrol('Style', 'pushbutton', 'String', 'DO5',...
    'Position', [160 60 20 20],...
    'Callback', @gui_callbacks);  
btn_DO6 = uicontrol('Style', 'pushbutton', 'String', 'DO6',...
    'Position', [190 60 20 20],...
    'Callback', @gui_callbacks);  
btn_DO7 = uicontrol('Style', 'pushbutton', 'String', 'DO7',...
    'Position', [220 60 20 20],...
    'Callback', @gui_callbacks');      

                
set(f, 'Visible', 'on');
                

try            
  % Close serial port
  fclose(s1);
catch err
  disp("Warning: issue while closing serial port");
  disp(lasterr);
end     
