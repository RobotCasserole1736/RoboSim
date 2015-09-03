%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Copyright (C) 2015 FRC Team 1736 
%%%
%%% File: serial_write_packet.m
%%%
%%% Description: function to write a single serial packet to RoboSim
%%% 
%%% Inputs: serial port handle, packet data
%%%
%%% Outputs: success/fail
%%%
%%%  Change Log:
%%%
%%%     7/25/2015 - Chris Gerth
%%%       -Created
%%%        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function ret_status = serial_write_packet(s_fp, packet_to_write)

  try
    % Blocking write call, currently only accepts strings
    srl_write(s_fp, char(packet_to_write));
    ret_status = 0;
    return;
  catch err
    disp("Warning: issue while sending serial packet:");
    disp(lasterr);
    ret_status = -1;
    return;
  end
        
end