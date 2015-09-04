% Compressor_and_tank.m - model of an FRC compressor (Viair 090) and air tank
%
% Inputs - Compressor_enabled - 1 for compressor on, 0 for off.
%        - Outflow_rate - flow rate of air out of the air tank (usually small due to leaks, larger while pistons are moving)
%
% Outputs - System Pressure - pressure in air tank and present at outlet of system
%         - System Current - electrical current through compressor (varies as function of enablement and system PSI)
%
% Config - System Air temp - assumed constant, around 100 deg. F
%        - Tank size (volume)
%        - 
%

function [sys_press_kPa, comp_current_A] = compressor_and_tank(enabled, outflow_rate_L_per_s)

% access the plant sample time global
global Ts;

%State variables
persistent moles_air_stored

%User Constants
tank_volume_L = 14.15; %(in L. 0.5 ft^3 = 14.15L)
tank_air_temp_C = 37.77; %(in DegC. 100degF = 37.77degC)

%Viair 090 air compressor constants (from http://www.viaircorp.com/90C.html#tabs-2)
comp_perf_data_sys_press_psi = [0 10 20 30 40 50 60 70 80 90 100 110 120];
comp_perf_data_flow_ft3_per_min = [0.73 0.64 0.59 0.64 0.51 0.45 0.39 0.35 0.28 0.28 0.27 0.24 0.21];
comp_perf_data_current_A = [7 8 8 9 9 9 9 10 10 10 11 10 9];

%Physical constants
gas_const_r = 8.3144621; %(in L*kPa/(K*mol))
min_press_kpa = 101.325; %sea level atmospheric pressure - we cannot create a vacuum with a compressor.

%calculated constants
tank_air_temp_K = tank_air_temp_C + 274.15;
comp_perf_data_sys_press_kPa = comp_perf_data_sys_press_psi * 6.89475729;
comp_perf_data_flow_L_per_s = comp_perf_data_flow_ft3_per_min * 0.471947443;
min_moles_air = min_press_kpa * tank_volume_L / (gas_const_r * tank_air_temp_K); %(n = PV/rT)

%init - start at min moles (one atmosphere of pressure)
if(isempty(moles_air_stored))
	moles_air_stored = min_moles_air;
end

%calculate starting system pressure (P = nrT/V)
sys_starting_press_kPa = moles_air_stored * gas_const_r * tank_air_temp_K / (tank_volume_L);

%Calculate input volume of air based on compressor performance data
%Calculate current draw at the same time too.
if(enabled)
	volume_in = interp1(comp_perf_data_sys_press_kPa, comp_perf_data_flow_L_per_s, sys_starting_press_kPa) * Ts;
	comp_current_I = interp1(comp_perf_data_sys_press_kPa, comp_perf_data_flow_L_per_s, sys_starting_press_kPa);
else
	volume_in = 0;
	comp_current_I = 0;
end

%calc moles of air in (n = PV/rT)
moles_air_in = sys_starting_press_kPa * volume_in / (gas_const_r*tank_air_temp_K);

%calc moles of air out (n = PV/rT)
moles_air_out = sys_starting_press_kPa * outflow_rate_L_per_s / (gas_const_r*tank_air_temp_K);

%adjust internal state. Saturate at min_moles_air moles of air.
moles_air_stored = max(min_moles_air, moles_air_stored + moles_air_in - moles_air_out);

%Calculate output pressure based on new mole count (P = nrT/V)
sys_press_kPa = moles_air_stored * gas_const_r * tank_air_temp_K / (tank_volume_L);


end

