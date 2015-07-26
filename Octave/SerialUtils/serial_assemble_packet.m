%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Copyright (C) 2015 FRC Team 1736 
%%%
%%% File: serial_assemble_packet.m
%%%
%%% Description: function to generate a single packet from many inputs
%%% 
%%% Inputs: various important things
%%%
%%% Outputs: a packet!
%%%
%%%  Change Log:
%%%
%%%     7/25/2015 - Chris Gerth
%%%       -Created
%%%        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%SUPER CRUCIAL PACKET FORMAT DOCUMENTATION
%Plant->Arduino Packet Definition:
% byte (0 txed first, n rxed last)
% 0 - start of packet marker - always '~'
% 1 - bit-packed digital outputs
% 2 - analog output 1 - 0.019607 volts/bit (0-5V range)
% 3 - analog output 2 - 0.019607 volts/bit (0-5V range)
% 4 - Quad Encoder 1 output MSB (1ms/bit)
% 5 - Quad Encoder 1 output LSB
% 6 - Quad Encoder 2 output MSB (1ms/bit)
% 7 - Quad Encoder 2 output LSB
% 8 - Quad Encoder 3 output MSB (1ms/bit)
% 9 - Quad Encoder 3 output LSB
% 10 - Quad Encoder 4 output MSB (1ms/bit)
% 11 - Quad Encoder 4 output LSB
%Note - quad encoder outputs are in ms per full period of quadrature output.
%Values are signed, where positive times yield forward motion, and negative
%times yield backward motion. Any specified period longer than 30 seconds
%(ie, value > 30,000 or < -30,000) will mean "Stopped"

function packet = serial_assemble_packet(digital_outputs, analog_outputs, quad_encoder_periods, quad_encoder_dirs)
    
    %Initialize outputs
    packet = uint8(zeros(1,12));
    
    %set start-of-packet character
    packet(1) = uint8('~');
    
    %assemble digital outputs
    for i=1:1:8
        packet(2) = bitset(packet(2), i, digital_outputs(i));
    end
    
    %assemble analog outputs
    packet(3) = uint8(analog_outputs(1)/0.019607);
    packet(4) = uint8(analog_outputs(2)/0.019607);
    
    for i = 1:1:4
        %The most annoying thing I have found to date about octave is that its bit operation functions
        %only work on positive integers. Maybe this is the way matlab works too. I am too lazy to see.
        %In any event, since it's not impossible and I guess I enjoy writing things like this, we'll
        %do the 2's complement magic thing and hopefully all will work out.
        if(quad_encoder_dirs(i))
            period_to_tx = double(quad_encoder_periods(i));
        else
            period_to_tx = -double(quad_encoder_periods(i));
        end
 
        if(period_to_tx > 0)
            temp = uint16(period_to_tx);
        else
            temp = uint16(double(2^16) + period_to_tx);
        end
        packet(2*(i-1)+5) = uint8(bitshift(bitand(temp, 0xFF00), -8, 16));
        packet(2*(i-1)+6) = uint8(bitand(temp, 0x00FF));
    
    end
    

end