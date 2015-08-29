%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Copyright (C) 2015 FRC Team 1736 
%%%
%%% File: serial_detect_port.m
%%%
%%% Description: Sweeps through fixed list of serial ports, looking for valid connected RoboSim board
%%% 
%%% Inputs: N/A
%%%
%%% Outputs: port name
%%%
%%%  Change Log:
%%%
%%%     8/18/2015 - Chris Gerth
%%%       -Created
%%%        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function ret_port_name = serial_detect_port()

	%Fixed list of ports to try. First is most common, later are less common.
	port_list = {"COM3", "COM4", "COM2", "COM1", "COM5", "COM6", "COM7", "COM8", "COM9"};
	port_name_iter = "";
	timeout = 0.1; %100 ms second timeout on reading from port
	
    disp("Searching for Robosim...")
	for port_idx = 1:1:length(port_list)
		port_name_iter = port_list{port_idx};
		
		disp(sprintf("Attempting serial port %s", port_name_iter ));
		%Attempt to open serial port. Try next if not possible
		try
		  port_handle = 0;
		  %establish timeout
		  if(timeout == -1)
			temp = -1; %serial API requires timeout in tenths of a second
		  else
			temp = timeout*10; %serial API requires timeout in tenths of a second
		  end
		  
		  port_handle = serial(port_name_iter, 115200,temp); 
          set(port_handle, "bytesize", 8);
          set(port_handle, "parity", "E");
          set(port_handle, "stopbits", 2);

		  % Flush input and output buffers
		  srl_flush(port_handle); 
		  disp(sprintf('Successfully opened %s', port_name_iter));
		catch err
		  continue;
		end    

		%Attempt to get one valid packet over serial. Retry up to 15 times before we give up.
		ret_code = 0;
		packet = [];
		
		[packet, ret_code] = serial_read_packet(port_handle, 10);
		if(ret_code == 0) %got a good packet, we'll say this is our serial port
			disp(sprintf("Found RoboSim on %s", port_name_iter));
			serial_close_port(port_handle);
			ret_port_name = port_name_iter;
			return
	    else
			disp(sprintf("Could not find RoboSim on %s", port_name_iter));
			serial_close_port(port_handle);
			continue;
		end
		
		
	end
   
	disp("RoboSim not found! Is it pluged in and functional?");
	ret_port_name = -1;
	return
   
end