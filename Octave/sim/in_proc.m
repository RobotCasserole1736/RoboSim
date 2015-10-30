%in_proc.m
% Input Processing
%
% This should run at the beginning of each simulation loop to read the inputs and populate model
% input interfaces.
%
% Created August 1, 2015 - Andrew Gurik & Chris Gerth
% 

% required physical inputs:
%   6x motor voltage
%   8x solenoid voltage
global s1
global use_serial


if(use_serial == 0)
	test_waveform_1_t = [0, 0.2, simTime];
	test_waveform_1_v = [0,  12,  12];
	test_waveform_2_t = [0, 0.2, simTime];
	test_waveform_2_v = [0,  8,  12];
    in = ...
    struct  (
            'motor_voltage',    [interp1(test_waveform_1_t, test_waveform_1_v, n),interp1(test_waveform_2_t, test_waveform_2_v, n),0,0,0,0],... % array of input motor voltages
            'solenoid_voltage', [0,0,0,0,0,0,0,0]   % array of input solenoid voltages
            );
else
    %read packet from RoboSim
	[rx_packet, read_ret_status] = serial_read_packet(s1,10);
    if(read_ret_status !=0 )
        disp("Warning - bad packet read from RoboSim!");
        rx_packet = old_rx_packet;
    end

    [digital_inputs, motor_voltages] = serial_decode_packet(rx_packet);
    in = ...
    struct  (
            'motor_voltage',    motor_voltages,... % array of input motor voltages
            'solenoid_voltage', digital_inputs.*12   % array of input solenoid voltages
            );
    old_rx_packet = rx_packet;
end