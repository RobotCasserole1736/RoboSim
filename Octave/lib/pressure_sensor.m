% Compressor_and_tank.m - model of the FRC Nasson Pressure sensor (http://team358.org/files/pneumatic/2014FRCPneumaticsManual.pdf)
%
% Inputs - System Pressure (kPa) - pneumatic pressure presented to sensor
%        - reset - set to 1 to set internal state variables back to init status.
%
% Outputs - contact_status - 1 for closed, 0 for open. Contacts open on high pressure.
%
% Config - high_trigger_kPa - Pressure at which the contacts should open.
%        - low_trigger_kPa - Pressure at which the contacts should close


function [contact_status] = pressure_sensor(sys_press_kPa, reset)

% access the plant sample time global
global Ts;

%State variables
persistent contact_state_internal

%User Constants
high_trigger_kPa = 792.897089; %Contacts open at 115psi (per http://team358.org/files/pneumatic/2014FRCPneumaticsManual.pdf)
low_trigger_kPa = 655.001943; %Contacts close at 95psi (per http://team358.org/files/pneumatic/2014FRCPneumaticsManual.pdf)

%Reset if needed
if(reset)
	contact_state_internal = 1;
end

if(sys_press_kPa > high_trigger_kPa)
	contact_state_internal = 0;
elseif(sys_press_kPa < low_trigger_kPa)
	contact_state_internal = 1;
end
%if neither condition met, contact state should stay unchanged.

%Return internal state as the contact status.
contact_status = contact_state_internal;