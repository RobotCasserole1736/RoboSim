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
plot(t,lmt,'-+b');
legend('Left motor output torque (Nm)');
subplot(3,1,2);
plot(t,lms,'-+g');
legend('Left motor output shaft speed (rad/s)');
subplot(3,1,3);
plot(t,lmv,'-+g');
legend('Left Motor input voltage (V)');
set(gcf,'numbertitle','off','name','Left Motor')

% robot plot
figure(3);
subplot(2,1,1);
plot(t,rb_x_vel,'-+b');
legend('Robot X Velocity (m/s)');
subplot(2,1,2);
plot(t,rb_x_pos,'-+g');
legend('Robot X Displacement (m)');
set(gcf,'numbertitle','off','name','Robot')
