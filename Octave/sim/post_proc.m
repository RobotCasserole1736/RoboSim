%post_proc.m
% Post Processing
%
% This runs once after the simulation.
%
% Created August 1, 2015 - Andrew Gurik & Chris Gerth
% 
global s1
global use_serial

%%shut down robosim connection
if(use_serial)
    disp("Shutting down RoboSim...")

    disp("Closing serial port...")
    serial_close_port(s1);  
end

%% Post Processing

% motor plots
figure(2);
subplot(3,1,1);
plot(t,lmt,'-+b',t,rmt,'-+r');
title('Motor output torque (Nm)');
legend('Left', 'Right');
subplot(3,1,2);
plot(t,lms.*9.54929659643,'-+b',t,rms.*9.54929659643,'-+r');
title('Motor output shaft speed (RPM)');
legend('Left', 'Right');
subplot(3,1,3);
plot(t,lmv,'-+b',t,rmv,'-+r');
title('Motor input voltages (V)');
legend('Left', 'Right');
set(gcf,'numbertitle','off','name','Motors')

%electrical plots
figure(3);
subplot(3,1,1);
plot(t,rb_cur_draw,'-+b');
title('Total Current Draw (A)');
subplot(3,1,2);
plot(t,rb_sply_v,'-+b');
title('System Voltage (V)');
subplot(3,1,3);
plot(t,rb_bat_chg,'-+b');
title('Battery Charge (Ah)');
set(gcf,'numbertitle','off','name','Electrical')


% robot plot
figure(4);
subplot(3,1,1);
plot(t,rb_x_vel.*3.28084,'-+g',t,rb_y_vel.*3.28084,'-+r');
legend('X', 'Y');
title('Robot Velocity (ft/s)');
subplot(3,1,2);
plot(-rb_y_pos.*3.28084,rb_x_pos.*3.28084,'-+r');
title('Robot Position Trace(ft)');
subplot(3,1,3);
plot(t,rb_rot_vel.*9.54929659643,'-+r');
title('Robot Rotational Velocity(RPM)');
set(gcf,'numbertitle','off','name','Robot')


%pneumatic system plots 
figure(5);
subplot(1,1,1);
plot(t,rb_sys_press./6.89475729,'-+r');
legend('Tank Pressure (psi)');
title('Pneumatic System Pressure');
set(gcf,'numbertitle','off','name','Pneum')