%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Copyright (C) 2015 FRC Team 1736 
%%%
%%% File: serial_decode_packet.m
%%%
%%% Description: function to generate many outputs from a single packet
%%% 
%%% Inputs: a packet!
%%%
%%% Outputs: various important things
%%%
%%%  Change Log:
%%%
%%%     7/25/2015 - Chris Gerth
%%%       -Created
%%%        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%SUPER CRUCIAL PACKET FORMAT DOCUMENTATION
%Arduino->Plant Packet Definition:
% byte (0 rxed first, n rxed last)
% 0 - start of packet marker - always '~'
% 1 - bit-packed digital inputs
% 2 - motor 1 voltage - signed int8, 0.09375 V/bit (-12 to 12 V range)
% 3 - motor 2 voltage - signed int8, 0.09375 V/bit
% 4 - motor 3 voltage - signed int8, 0.09375 V/bit
% 5 - motor 4 voltage - signed int8, 0.09375 V/bit
% 6 - motor 5 voltage - signed int8, 0.09375 V/bit
% 7 - motor 6 voltage - signed int8, 0.09375 V/bit

function [digital_inputs, motor_voltages] = serial_decode_packet(packet)
    
    %initialize output arrays
    digital_inputs = zeros(1, 8); 
    motor_voltages = zeros(1, 6);
    
    %Make sure things are nice
    if(packet(1) ~= '~')
        warning("Attempt to decode invalid packet");
    end

    %get all digital input values
    for i = 1:1:8
        digital_inputs(i) = bitget(uint8(packet(2)), i);
    end
    
    %get all motor voltages
    for i=1:1:6
        %perform typecasting manually to ensure it works right.
        %wrap/saturate the value within the 8-bit signed range.
        %This is all 2's complement jazz. if that isn't meaningful
        %to you, just move along, nothing to see here.
        temp = double(packet(i+2));
        if(temp < -128)
            temp = -128;
        elseif(temp > 255)
            temp = -1;
        elseif(temp > 127)
            temp = temp - 256;
        end
        
        motor_voltages(i) = temp * 0.09375;
    end
          
end