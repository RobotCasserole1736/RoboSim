%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Copyright (C) 2015 FRC Team 1736 
%%%
%%% File: serial_close_port.m
%%%
%%% Description: Closes out a serial port. Behaves nicely if that port didn't actually exist in the first place.
%%% 
%%% Inputs: port handle
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

function ret_status = serial_close_port(s_fp)

    try
        % Close serial port, if at all possible.
        fclose(s_fp);
        ret_status = 0;
    catch err
        disp("Warning: issue while closing serial port");
        disp(lasterr);
        ret_status = -1;
    end   
    
    return;
        
end