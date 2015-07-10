clear;
clc;

%Constants, motor-specific.
%See http://www.usfirst.org/uploadedFiles/Robotics_Programs/FRC/Game_and_Season__Info/2011_Assets/Kit_of_Parts/Motor_Curves_Rev_A.pdf
Rc = 0.8; %ohms, for full CIM motor
Lc = 0.05; %henries, just a guess based on similarly sized motor typical values
Kt = 344/133; %oz-in/A - for CIM motor. Calculated from Stall Torque/Stall Current
Ki = (12-(2.7*Rc))/(5310*2*pi/60); %V/(rad/s). Calculated from Vemf@FreeSpeed/(2pi/60*RPM@FreeSpeed). Steady-state Vemf = Vs - I@FreeSpeed*Rc, for Vs = 12

SystemMomentOfInertia = 0.05; % oz-in^2 - just a guess the rotating member of CIM - model as 2.5lb, 1 in. radius solid cylinder
LoadTorque = 344; %Oz.In
Ts = 0.01; %10 ms sample rate


step_time = 5;
end_time = 30;
voltage = [zeros(1,step_time/Ts), 12*ones(1,(end_time-step_time)/Ts)]; %Step from 0 to 12V

num_samples = length(voltage);

%prealocate other variables
time = (0:1:num_samples-1)*Ts;
torque = ones(1,num_samples);
speed = zeros(1,num_samples);

for i = 1:1:num_samples-1
    torque(i+1) = torque(i) + Ts*(Kt/Lc * (voltage(i) - torque(i)*Rc/Kt - Ki*speed(i)));
    speed(i+1) = speed(i) + Ts*(1/SystemMomentOfInertia * (torque(i)-LoadTorque));
    
end

figure;
plot(time, torque);

figure;
plot(time, speed);



