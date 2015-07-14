clear;
clc;
clf;

%Constants, motor-specific.
%See http://files.andymark.com/CIM-motor-curve-am-0255.pdf
Rc = 0.3; %ohms, for full CIM motor. Didn't have an Ohmmeter that could measure this, so just kinda guessed.
Lc = 0.02; %henries, just a guess based on what made things look nice
Kt = 2.429/131.227; %Nm/A - for CIM motor. Calculated from Stall Torque/Stall Current
Ki = (12-(2.7*Rc))/(5310*2*pi/60); %V/(rad/s). Calculated from Vemf@FreeSpeed/(2pi/60*RPM@FreeSpeed). Steady-state Vemf = Vs - I@FreeSpeed*Rc, for Vs = 12

%The following are again total guesses, this data is not available anywhere I can find.
Kf = 0.25; %Kinetic rotational coefficent of friction in Nm-s for motor
Tfs = 0.2; %Static friction maximum torque magnititude
speed_mag_zero_limit = 10; %in rad/sec This and below define pratical deadzones for speed 


SystemMomentOfInertia = 0.555 * 0.0254^2; % kg-m^2 - just a guess the rotating member of CIM - model as 1.25lb, 1 in. radius solid cylinder
LoadTorque = 0; %Nm
Ts = 0.01; %50 ms sample rate


step_time = 1;
end_time = 10;
V_start = 0;
V_end = 12;
voltage = [V_start*ones(1,step_time/Ts), V_end*ones(1,(end_time-step_time)/Ts)]; %Step from V_start to V_end
%voltage = [V_start:(V_end-V_start)/(step_time/Ts-1):V_end, V_end*ones(1,(end_time-step_time)/Ts)]; %ramp from V_start to V_end from 0 to step_time, then hold V_end till end_time

num_samples = length(voltage);

%prealocate other variables
time = (0:1:num_samples-1)*Ts;
torque = zeros(1,num_samples);
speed = zeros(1,num_samples);

for i = 1:1:num_samples-1
    torque(i+1) = torque(i) + Ts*(Kt/Lc * (voltage(i) - torque(i)*Rc/Kt - Ki*speed(i)));
    
    %If motor is rotating, speed is increased by torque and decreased by friction
    if(abs(speed(i)) > speed_mag_zero_limit)
      speed(i+1) = speed(i) + Ts*(1/SystemMomentOfInertia * (torque(i)-LoadTorque) - Kf*speed(i) );
    %If motor is stopped  
    else
      %If torque has exceeded static friction, the motor may spin per normal equations
      if(abs(torque(i)) > Tfs )
        speed(i+1) = speed(i) + Ts*(1/SystemMomentOfInertia * (torque(i)-LoadTorque) - Kf*speed(i));
      %Else, motor sticks and speed remains zero
      else
        speed(i+1) = 0;
      end
    end
    
    
end

subplot(3,1,1);
plot(time, voltage);
title('Voltage (V) vs. Time (S)');
subplot(3,1,2);
plot(time, torque);
title('Torque (Nm) vs. Time (S)');
subplot(3,1,3);
plot(time, speed*60/2/pi);
title('Speed (RPM) vs. Time (S)');




