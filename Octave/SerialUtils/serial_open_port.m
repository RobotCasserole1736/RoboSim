%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Copyright (C) 2015 FRC Team 1736 
%%%
%%% File: serial_open_port.m
%%%
%%% Description: opens a serial port to "port_name" with proper arduino settings
%%% 
%%% Inputs: port name - something like "COM4"
%%%
%%% Outputs: handle to created port
%%%
%%%  Change Log:
%%%
%%%     7/25/2015 - Chris Gerth
%%%       -Created
%%%        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function port_handle = serial_open_port(port_name, timeout = -1)

    %Attempt to open serial port. Toss warning and continue if not possible.
    try
      port_handle = 0;
      % Opens serial port ttyUSB1 with baudrate of 115200 (config defaults to 8-N-1)

      %establish timeout
      if(timeout == -1)
        temp = -1; %serial API requires timeout in tenths of a second
      else
        temp = timeout*10; %serial API requires timeout in tenths of a second
      end
      
      port_handle = serial(port_name, 115200,temp); 
      set(port_handle, "parity", "N");    % Changes parity checking 
                                % possible values [E]ven, [O]dd, [N]one.
      set(port_handle, "stopbits", 1);    % Changes stop bits, possible
                                % values 1, 2.

      % Flush input and output buffers
      srl_flush(port_handle); 
      disp(sprintf('Successfully opened %s', port_name));
    catch err
      disp("Warning: issue while opening serial port");
      disp(lasterr);
      port_handle = -1;
    end      
        
end