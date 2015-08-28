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

    persistent bad_pkt_ct = 0;
    %Attempt to get packet at least once. Retry "retires" number of times.
    % read single characters to see if it's the packet start character

    header_char = srl_read(s_fp, 1);
    for i = 1:1:retries+1
        disp(bad_pkt_ct)
        if(header_char == '~')
            %If So, pull the rest of the packet
            packet = srl_read(s_fp, 7); 

            %Assume good packet and write it.
            read_packet(1) = header_char;
            read_packet(2:8) = packet(1:7);
            ret_status = 0;
            return; %we have a packet, return
        end
        bad_pkt_ct = bad_pkt_ct + 1;
        srl_flush(s_fp);
        header_char = srl_read(s_fp, 1);
        pause(0);
    end
    
    %if we got here, we did not find a packet. sad day.
    read_packet = [0xDE,0xAD,0xBE,0xEF,0xDE,0xAD,0xBE,0xEF];
    ret_status = 1;



    %if we got here, something wacko happened.
    disp("Warning: issue while getting serial packet:");
    disp(lasterr);
    read_packet = [0xDE,0xAD,0xBE,0xEF,0xDE,0xAD,0xBE,0xEF];
    ret_status = -1;
    srl_flush(s_fp);
    return;

    

end