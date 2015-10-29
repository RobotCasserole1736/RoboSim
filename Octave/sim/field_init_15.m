% field_init_15.m
% 2015 Field Model and field drawing initalization
%
% Created July 20, 2015 - Andrew Gurik & Chris Gerth
% 

feild = ...
struct  (
        'half_width',           2000,...             % distance from feild center to left/right walls (m)
        'half_height',          3000,...             % distance from feild center to front/back (alliance station) walls (m)
        'scratch',                   0
        );
        
        

%% Initialize Drawing
figure(1);
% set up figure axis
axis([-feild.half_width feild.half_width -feild.half_height feild.half_height], "equal", "nolabel", "manual", "tic", "on");
% draw field
rectangle("Position", [-feild.half_width feild.half_width -feild.half_height feild.half_height]);

