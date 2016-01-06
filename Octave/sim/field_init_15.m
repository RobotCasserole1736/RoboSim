% field_init_15.m
% 2015 Field Model and field drawing initalization
%
% Created July 20, 2015 - Andrew Gurik & Chris Gerth
% 

feild = ...
struct  (
        'half_width',           4.11,...               % distance from feild center to left/right walls (m)
        'half_height',          8.19,...               % distance from feild center to front/back (alliance station) walls (m)
        'axis_pad'   ,          0.2,...                % blank space drawn around the outside of the field
        'scratch',                   0
        );
        
        

%% Initialize Drawing
figure(1);
% set up figure axis
axis([-(feild.half_width+feild.axis_pad) (feild.half_width+feild.axis_pad) -(feild.half_height+feild.axis_pad) (feild.half_height+feild.axis_pad)], "equal", "nolabel", "manual", "tic", "on");
% draw field
rectangle('Position', [-(feild.half_width+0.1) -(feild.half_height+0.1) (feild.half_width+0.1)*2 (feild.half_height+0.1)*2],'FaceColor', [0.5,0.5,0.5], 'LineStyle', 'none'); %Outline
rectangle('Position', [-feild.half_width -feild.half_height feild.half_width*2  feild.half_height],'FaceColor', [1,0.75,0.75], 'LineStyle', 'none'); %Red alliance
rectangle('Position', [-feild.half_width 0 feild.half_width*2  feild.half_height],'FaceColor', [0.75,0.75,1], 'LineStyle', 'none'); %Blue alliance
rectangle('Position', [-feild.half_width -0.05 feild.half_width*2 0.1],'FaceColor', [0,0,0], 'LineStyle', 'none'); %Centerline



