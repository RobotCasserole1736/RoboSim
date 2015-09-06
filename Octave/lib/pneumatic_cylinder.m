% pneumatic_cylinder.m - model of a basic pneumatic cylinder. should make this into a class,
%                        or clone and modify for each unique cylinder
%
% Inputs - Front Pressure (kPa) - pressure presented to port near rod end of cylinder
%          Rear Pressure (kPa) - pressure presented to port near flat end of cylinder
%             --Therefore, if Front Press > Rear Press, rod will retract
%          Load force (N) - force presented to rod from external entities. Positive Load force will cause rod to retract.
%          reset - set to 1 to reset internal state variables back to default values.
%
% Outputs - Front Flow (L per s) - Air flow into the front pressure port
%           Rear Flow (L per s) - Air flow into the Rear pressure port
%           Rod Extension (m) - displacement of rod from fully retracted (0m)
%
% Config - Rod mass (kg) - mass of moving piston and rod
%        - Rod Cross-sectional Area (m^2)- Xsectional area of rod 
%        - Cylinder Bore (m^2) - xsectional area on inside of cylinder
%           --Pressure at rear port acts on a face of area = Cylinder Bore
%           --Pressure at front port acts on a face of area = Cylinder Bore - Rod Cross-sectional Area
%        - Rod Friction (N/(m/s)) - Kinetic coefficient of friction of motion of the rod/piston inside the cylinder
%        - Rod Stroke (m) - maximum extension length of rod from fully retracted
%
%     
%     
%  Rpress    |-------------------------------------------------------------------|    FPress      Rod XS area
%    Rflow-->|       ^                   |                                       |<--Fflow        |
%            |       |       F_Press_R-->|<--F_press_F                           |                v
%            |     bore                  |---------------------------------------+----------------------O  <-- F_load
%            |       |                   |            <--F_Fric-->               |                ^
%            |       v                   |                                       |                |
%            |-------------------------------------------------------------------|                         
% 
% Extension==|===================================================================|=====>
%            0 m                                                             <Rod Stroke> m
%
%    Pos. Rod Velocity -->
%                                    

function [front_flow_Lps, rear_flow_Lps, rod_extension_output_m] = pneumatic_cylinder(front_press_kPa, rear_press_kPa, load_force_N, reset)

% access the plant sample time global
global Ts;

%State variables
persistent rod_extension_m
persistent rod_velocity_mps

%User Constants
rod_mass_kg = 0.0025;
rod_xs_area_m2 = 0.005^2*pi; % 5mm radius
cyl_bore_m2 = 0.02^2*pi; %20mm radius
stroke_m = 0.25; 
fric_k = 0.002; %purely a guess...

%Reset if needed
if(reset)
	rod_extension_m = 0;
	rod_velocity_mps = 0;
end

%Calculate forces

%Force = pressure * area
R_press_force_N = rear_press_kPa/1000 * cyl_bore_m2;
F_press_force_N = front_press_kPa/1000 * (cyl_bore_m2 - rod_xs_area_m2);

%frictional force = vel*Kf
KFric_force_N = rod_velocity_mps * fric_k;

%Net force 
F_net_N = R_press_force_N - F_press_force_N - KFric_force_N - load_force_N;

%calculate motion. 
%rod_accel = F/mass
rod_accel_mps2 = F_net_N/rod_mass_kg;
%rod_vel ~= rod_vel_prev + accel * Ts
rod_velocity_mps = rod_velocity_mps + rod_accel_mps2 * Ts;
%rod_pos ~= rod_pos_prev + vel * Ts
rod_extension_m_new = rod_extension_m + rod_velocity_mps * Ts;

%adjust rod position based on max/min extension
%Also zero out velocity, since we hit a stop
if(rod_extension_m_new < 0)
	rod_extension_m_new = 0;
	rod_velocity_mps = 0;
elseif(rod_extension_m_new > stroke_m)
	rod_extension_m_new = stroke_m;
	rod_velocity_mps = 0;
end

%calculate flow outputs (delta volume)
%Factor of 1000 to convert cubic meters to litres
%Positive flow assumed INTO the cylinder
front_flow_Lps = (cyl_bore_m2 - rod_xs_area_m2) * (rod_extension_m - rod_extension_m_new) * 1000;
rear_flow_Lps = cyl_bore_m2 * (rod_extension_m_new - rod_extension_m) * 1000;

%Set position output
rod_extension_output_m = rod_extension_m_new;
%Store state
rod_extension_m = rod_extension_m_new;

