clear;
clc;
clf;

%Constants, motor-specific.
%See http://files.andymark.com/CIM-motor-curve-am-0255.pdf
Rc = 0.2; %ohms, for full CIM motor. Didn't have an Ohmmeter that could measure this, so just kinda guessed.
Lc = 0.05; %henries, just a guess based on similarly sized motor typical values
Kt = 2.429/131.227; %Nm/A - for CIM motor. Calculated from Stall Torque/Stall Current
Ki = (12-(2.7*Rc))/(5310*2*pi/60); %V/(rad/s). Calculated from Vemf@FreeSpeed/(2pi/60*RPM@FreeSpeed). Steady-state Vemf = Vs - I@FreeSpeed*Rc, for Vs = 12


SystemMomentOfInertia = 1.13 * 0.0254^2; % kg-m^2 - just a guess the rotating member of CIM - model as 2.5lb, 1 in. radius solid cylinder
LoadTorque = 0; %Nm
Ts = 0.01; %50 ms sample rate


step_time = 1;
end_time = 10;
voltage = [zeros(1,step_time/Ts), 12*ones(1,(end_time-step_time)/Ts)]; %Step from 0 to 12V

num_samples = length(voltage);

%prealocate other variables
time = (0:1:num_samples-1)*Ts;
torque = zeros(1,num_samples);
speed = zeros(1,num_samples);

for i = 1:1:num_samples-1
    torque(i+1) = torque(i) + Ts*(Kt/Lc * (voltage(i) - torque(i)*Rc/Kt - Ki*speed(i)));
    speed(i+1) = speed(i) + Ts*(1/SystemMomentOfInertia * (torque(i)-LoadTorque));
    
end

subplot(3,1,1);
plot(time, voltage);
title("Voltage (V) vs. Time (S)");
subplot(3,1,2);
plot(time, torque);
title("Torque (Nm) vs. Time (S)");
subplot(3,1,3);
plot(time, speed*60/2/pi);
title("Speed (RPM) vs. Time (S)");
disp(speed(i)*60/2/pi)



