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

  packet = [0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00];
  read_packet = [0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00];
  checksum = 0x00;
  try
  
    %Attempt to get packet at least once. Retry "retires" number of times.
    for i=1:1:retries+1
        % read single characters to see if it's the packet start character
        header_char = srl_read(s_fp, 1);
        if(header_char == '~')
        
            %If So, pull the rest of the packet
            %Due to some very interesting interestingness of open-source software, srl_read() with multiple bytes 
            %seems to misbehave and return garbage if the whole packet is not there. Pulling each byte 
            %individually seems to fix this. Yes it's much less efficent, but maybe that gives the serial
            %link and driver time to catch up? Not quite certain. In the words of a great software engineer,
            %  "My software works; I have no idea why."
            
            %packet = srl_read(s_fp, 8); %BUGGY
            packet(1) = srl_read(s_fp, 1); 
            packet(2) = srl_read(s_fp, 1);
            packet(3) = srl_read(s_fp, 1);
            packet(4) = srl_read(s_fp, 1);
            packet(5) = srl_read(s_fp, 1);
            packet(6) = srl_read(s_fp, 1);
            packet(7) = srl_read(s_fp, 1);
            packet(8) = srl_read(s_fp, 1);
            
            %assemble output packet
            read_packet(1) = header_char;
            read_packet(2:8) = packet(1:7);
            
            %calculate checksum
            for(i = 1:1:8)
                checksum = bitxor(checksum, read_packet(i));
            end
            
            %mark packet bad if checksum test fails
            if(checksum != packet(8))
                disp("Warning: bad checksum on serial rxed packet");
                ret_status = 2;
            else
                ret_status = 0;
            end
            return; %we have a packet, return
        end
    end
    
    %if we got here, we did not find a packet. sad day.
    disp("Warning: no serial packet recieved");
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