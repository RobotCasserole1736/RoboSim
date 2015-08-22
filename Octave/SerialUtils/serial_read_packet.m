%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Copyright (C) 2015 FRC Team 1736 
%%%
%%% File: serial_read_packet.m
%%%
%%% Description: get a single packet from the RoboSim 
%%% 
%%% Inputs: required - serial port handle
%%%         Optional - timeout (in seconds). Will default to "blocking" (ie, never timeout)
%%%
%%% Outputs: status of recieve. 
%%%          0 - good packet recieved
%%%          1 - no packet found within "timeout" or "retries" constraints
%%%          -1 - error on recieve
%%%
%%%  Change Log:
%%%
%%%     7/25/2015 - Chris Gerth
%%%       -Created
%%%        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [read_packet, ret_status] = serial_read_packet(s_fp, retries = 0)

  try
  
    %Attempt to get packet at least once. Retry "retires" number of times.
    for i=1:1:retries+1
        % read single characters to see if it's the packet start character
        header_char = srl_read(s_fp, 1);
        if(header_char == '~')
            %If So, pull the rest of the packet
            packet = srl_read(s_fp, 7); 
            %Assume good packet and write it.
            read_packet(1) = header_char;
            read_packet(2:8) = packet;
            ret_status = 0;
            return; %we have a packet, return
        end
    end
    
    %if we got here, we did not find a packet. sad day.
    read_packet = [0xDE,0xAD,0xBE,0xEF,0xDE,0xAD,0xBE,0xEF];
    ret_status = 1;


  catch err
    %if we got here, something wacko happened.
    disp("Warning: issue while getting serial packet:");
    disp(lasterr);
    read_packet = [0xDE,0xAD,0xBE,0xEF,0xDE,0xAD,0xBE,0xEF];
    ret_status = -1;
    return;
  end
    

end