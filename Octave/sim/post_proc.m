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
plot(t,lmt,'-+b',t,lml,'-+r');
legend('torque','load');
subplot(3,1,2);
plot(t,lms,'-+g');
legend('speed');
subplot(3,1,3);
plot(t,lmv,'-+g');
legend('voltage');
set(gcf,'numbertitle','off','name','Left Motor')