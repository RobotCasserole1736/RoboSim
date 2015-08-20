%post_proc.m
% Post Processing
%
% This runs once after the simulation.
%
% Created August 1, 2015 - Andrew Gurik & Chris Gerth
% 

%% Post Processing

% left motor plot
figure(2);
subplot(2,1,1);
plot(t,lmt,'-+b',t,lml,'-+r');
legend('torque','load');
subplot(2,1,2);
plot(t,lms,'-+g');
legend('speed');
set(gcf,'numbertitle','off','name','Left Motor')