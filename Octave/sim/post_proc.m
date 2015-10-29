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

% left motor plot
figure(2);
subplot(3,1,1);
plot(t,lmt,'-+b',t,rmt,'-+r');
title('Motor output torque (Nm)');
legend('Left', 'Right');
subplot(3,1,2);
plot(t,lms,'-+b',t,rms,'-+r');
title('Motor output shaft speed (rad/s)');
legend('Left', 'Right');
subplot(3,1,3);
plot(t,lmv,'-+b',t,rmv,'-+r');
title('Motor input voltages (V)');
legend('Left', 'Right');
set(gcf,'numbertitle','off','name','Motors')

% robot plot
figure(3);
subplot(3,1,1);
plot(t,rb_x_vel,'-+g',t,rb_y_vel,'-+r');
legend('X', 'Y');
title('Robot Velocity (m/s)');
subplot(3,1,2);
plot(-rb_y_pos,rb_x_pos,'-+r');
title('Robot Position Trace(m)');
subplot(3,1,3);
plot(t,rb_rot_vel,'-+r');
title('Robot Rotational Velocity(rad/s)');
set(gcf,'numbertitle','off','name','Robot')
